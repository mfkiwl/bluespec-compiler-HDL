package MesaLpm;

export mkMesaLpm;

import FIFO::*;
import RAM::*;
import ClientServer::*;
import CompletionBuffer::*;
import GetPut::*;
import CGetPut::*;
import List::*;
import Connectable::*;

import Misc::*;
import LocalBus::*;
import Mesa_LocalBus::*;
import MesaDefs::*;
import MesaIDefs::*;
import Mesa_Lpm_reg::*;

// ----------------------------------------------------------------
// The LPM module is responsible for taking 32-bit IP addresses, looking up
// the destination (32-bit data) for each IP address in a table in an SRAM,
// and returning the destinations.
//
// The module is pipelined, i.e., IP addresses stream in, and results stream
// out (after some latency).  Results are returned in the same order as
// requests.
//
// The SRAM is also pipelined: addresses stream in, and data stream out
// (after some latency).  It can accept addresses and deliver data on every
// cycle.
//
// Performance metric: as long as IP lookup requests are available, the LPM
// module must keep the SRAM 100% utilized, i.e., it should issue a request
// into the SRAM on every cycle.
//
// ----------------------------------------------------------------

// ----------------------------------------------------------------
// ILpm is the interface to the LPM module, containing two
// sub-interfaces: mif and ram.  It is defined in the interface definition
// package, MesaIDefs, imported above.
//
// The LPM module sits between two other blocks:
//   * the MIF (Media Interface)
//   * the SRAM
//
// The MIF sends requests to the LPM module by calling
//     mif.put (LuRequest, LuTag)
// and retrieves results (some cycles later) by calling
//     (luResponse, luTag) <- mif.get
//
// The RAM gets addresses from the LPM by calling
//     sramAddr <- ram.get
// and sends result data (some cycles later) back to the LPM by calling
//     ram.put sramData
//
// ----------------------------------------------------------------

// ----------------------------------------------------------------
//
// The longest prefix match traverse a tree representation in
// memory. The first step is a table lookup, and after that it
// iterates until a leaf is reached.
//
// ----------------------------------------------------------------

typedef union tagged {
    Bit#(21) Pointer;
    Bit#(31) Leaf;
} TableType deriving (Eq, Bits);

// ----------------------------------------------------------------
//
// The first lookup consumes the first 16 bits of the IP address.  The
// following type is for the remainder: either two eight-bit chunks (after the
// first lookup) or just one (after the second).
//
// ----------------------------------------------------------------

typedef union tagged {
    Tuple2#(Bit#(8),Bit#(8)) L1;
    Bit#(8) L2;
    void L3;
} IP deriving (Eq, Bits);

// Latency is the total latency for Lpm; this includes all steps in
// the process and the memory latency.  If latency is to low then the
// external ram will not be fully utilized. If the latency is to high
// then unnecessary large FIFOs are created.

typedef 12 Latency;

// Longest prefix matching is done on several requests at the same
// time. A completion buffer ensures that the output is in the same
// order as the requests. The completion buffer limits the number of
// request worked on at the same time.

typedef Latency CompletionBufferSize;
typedef CBToken#(CompletionBufferSize) CompletionToken;

(* module_type = "PciExtModule" *)
module mkMesaLpm0(ILpm);
  (lbsCollect
   (module
       // registers for debugging purposes:
       Reg#(LuRequest) sliceRequestB32();
       mkRegU the_sliceRequestB32(sliceRequestB32);

       Reg#(LuTag) sliceRequestTag();
       mkRegU the_sliceRequestTag(sliceRequestTag);

       Reg#(LuResponse) sliceResponseB32();
       mkRegU the_sliceResponseB32(sliceResponseB32);

       Reg#(LuTag) sliceResponseTag();
       mkRegU the_sliceResponseTag(sliceResponseTag);

       // register module auto-generated by TRex:
       Mesa_Lpm_reg ctl();
       sysMesa_Lpm_reg the_ctl(ctl);

       Integer sz = valueOf(Latency);

       // the FIFOs for requests to and responses from the RAM:
       FIFO#(SramAddr) wsendRAMReq();
       mkSizedFIFO#(sz + 2) the_wsendRAMReq(wsendRAMReq);

       FIFO#(SramData) sramResp();
       mkSizedFIFO#(sz + 2) the_sramResp(sramResp);

       // The FIFO for input requests:
       FIFO#(Tuple2#(LuRequest, LuTag)) ififo();
       mkSizedFIFO#(2) the_ififo(ififo);

       // The FIFO for work in progress:
       FIFO#(Tuple3#(IP, LuTag, CompletionToken)) fifo();
       mkSizedFIFO#(sz + 2) the_fifo(fifo);

       // The FIFO for output responses:
       FIFO#(Tuple2#(LuResponse, LuTag)) ofifo();
       mkSizedFIFO#(2) the_ofifo(ofifo);

       // The Completion Buffer
       CompletionBuffer#(CompletionBufferSize, Tuple2#(LuResponse, LuTag)) completionBuffer();
       mkCompletionBuffer the_completionBuffer(completionBuffer);

       // All accesses start with a table lookup. This rule also allocates a
       // completion token.
       rule stage0;
	  let {ireq,ilutag} = ififo.first;
	  ififo.deq;
	  let tag <- completionBuffer.reserve.get();

	  // We send a request to the RAM, and also enqueue (for the next
	  // stage) the remainder of the address, the lookup-tag and the
	  // completion-buffer tag.  (Ln is the remainder after the nth
	  // lookup).
	  (fifo.enq)(tuple3(L1 (tuple2(ireq[15:8], ireq[7:0])), ilutag, tag));
	  (wsendRAMReq.enq)(zeroExtend(ireq[31:16]));
       endrule: stage0

       // Processing stops if we found a Leaf.
       rule stage1_Leaf (unpack(sramResp.first) matches tagged Leaf (v));
	  sramResp.deq;
	  let {ip,lutag,itag} = fifo.first;
	  fifo.deq;
	  completionBuffer.complete.put(tuple2(itag,tuple2(unpack({0,v}),lutag)));
       endrule: stage1_Leaf

       // If we found a pointer, a further lookup is necessary.  We also
       // enqueue the remainder of the address (Ln is the remainder after the
       // nth lookup).
       rule stage1_Pointer (unpack(sramResp.first) matches tagged Pointer (p));
	  sramResp.deq;
	  let {ip,lutag,itag} = fifo.first;
	  fifo.deq;
	  let nr = begin case (ip) matches
			    tagged L1 {b,c} :  (L2 (c));
			    tagged L2 {c}   :  (L3);
			    tagged L3       :  (?);  // never happens
			 endcase end;
	  let addr = begin case (ip) matches
			      tagged L1 {b,c} :  (p + zeroExtend(b));
			      tagged L2 {c}   :  (p + zeroExtend(c));
			      tagged L3       :  (?);  // never happens
			   endcase end;
	  (fifo.enq)(tuple3(nr,lutag,itag));
	  (wsendRAMReq.enq)(addr);
       endrule: stage1_Pointer

       // Finally we define the two interfaces:
       interface Server mif;
	  interface Put request;
	     method put(x);
		action
		   (ififo.enq)(x);
		   // record request for debugging purposes:
		   let {ipa,lutag} = x;
		   sliceRequestB32 <= ipa;
		   sliceRequestTag <= lutag;
		   // count requests, in a status register:
		   ctl.dbg_mif_request;
		endaction
	     endmethod: put
	     // or, apart from the status and debugging info:
	     // interface request = fifoToPut(ififo);
	  endinterface: request
	  interface Get  response;
	     method get() ;
		actionvalue
		   let resp <- completionBuffer.drain.get();
		   // record response for debugging purposes:
		   let {r,t} = resp;
		   sliceResponseB32 <= r;
		   sliceResponseTag <= t;
		   // count responses in status register
		   ctl.dbg_mif_response;
		   return(resp);
		endactionvalue
	     endmethod: get
	     // or, apart from the status and debugging info:
	     // interface response = fifoToGet(completionBuffer.drain);
	  endinterface: response
       endinterface: mif

       interface Client ram;
	  interface Get request;
	     method get();
		actionvalue
		   let req = wsendRAMReq.first;
		   wsendRAMReq.deq;
		   return (Read (req));
		endactionvalue
	     endmethod: get
	  endinterface: request
	  interface Put response = fifoToPut(sramResp);
	  endinterface: ram

   endmodule));
endmodule: mkMesaLpm0

// ----------------------------------------------------------------
//
// The remaining modules are bureaucracy to make the local bus connection
// explicit at the boundary of the separately synthesized module, and to make
// all the connections of that module fully registered.  This is very
// formulaic, and is repeated, mutatis mutandis, for all the separately
// synthesized components.
//
// ----------------------------------------------------------------

(* module_type = "PciAModule" *)
module mkMesaLpm(ILpm);
   (mkLBA(mkMesaLpm3));
endmodule: mkMesaLpm

(* module_type = "PciExtModule" *)
module mkMesaLpm3(ILpm);
   let {lb,cilpm} <- mkMesaLpm2;
   let {cc,s} <- (Module#(Tuple2#(CClient#(FDepth,
					   Tuple2#(LuRequest, LuTag),
					   Tuple2#(LuResponse, LuTag)),
				  Server#(Tuple2#(LuRequest, LuTag),
					  Tuple2#(LuResponse, LuTag)))))'(mkCClientServer);
   mkConnection(cc, cilpm.mif);

   // This module provides a pair of interfaces:
   interface fst = lb;
   interface ILpm snd;
      interface mif = s;
      interface ram =  cilpm.ram;
   endinterface: snd
endmodule: mkMesaLpm3

(* module_type = "PciExtModule" *)
module mkMesaLpm2(CILpm);
   (mkPciExtModule(v_mkMesaLpm));
endmodule: mkMesaLpm2

(* module_type = "CPciExtModule", synthesize *)
module v_mkMesaLpm(CILpm);
   (mkCPciExtModule(mkMesaLpm1));
endmodule: v_mkMesaLpm

(* module_type = "PciExtModule" *)
module mkMesaLpm1(CILpm);
   let {lb,ilpm} <- mkMesaLpm0;
   let {c,cs} <- mkClientCServer;
   mkConnection(c, ilpm.mif);

   // This module provides a pair of interfaces:
   interface fst = lb;
   interface CILpm snd;
      interface mif = cs;
      interface ram = ilpm.ram;
   endinterface: snd
endmodule: mkMesaLpm1

endpackage: MesaLpm

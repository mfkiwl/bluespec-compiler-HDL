//import GetPut::*;
//import ClientServer::*;
import FIFO::*;
//import Connectable::*;
import Vector::*;

// Hierarchy test for virtual class
typedef UInt#(14) I;
typedef UInt#(14) O;
typedef 3   SIZE;

(*synthesize, options ="-elab"*)
module sysTestBody ();
   Vector#(SIZE,Reg#(I)) rsssss ;
   for (Integer i = 0; i < valueOf(SIZE) ; i = i + 1) begin
      rsssss[i] <- mkRegU;

   end

   Vector#(4,Reg#(int)) aa = ? ;
   Vector#(4,Reg#(int)) bb = ? ;

   for (Integer i = 0 ; i < 4 ; i = i + 1) begin
     aa[i] <- mkRegU;
     bb[i] <- mkRegU;
   end

   // Vector#(SIZE,Server#(I,O))  ms <- replicateM(mkHierTest);
   // let x1 <- mkConnection(ms[0].request, ms[1].response);
   // let x2 <- mkConnection(ms[1].request, ms[2].response);
endmodule

// (*synthesize, options ="-elab"*)
// module mkHierTest (Server#(I,O) );
//    FIFO#(I) inf <- mkFIFO;
//    FIFO#(O) outf <- mkFIFO;

//    ClientServer#(I,O) cs <- mkRequestResponseBuffer;
//    let c1 <- mkConnection(tpl_2(cs), fifosToClient(inf, outf));

//    Client#(I,O) sss = tpl_1(cs);

//    RWire#(I) rw <- mkRWire;
//    PulseWire pw <- mkPulseWire;
//    Wire#(I) ww <- mkDWire(17);

//    rule tprocess;
//       I req <- sss.request.get;
//       sss.response.put(truncate(req));
//       rw.wset(req);
//       pw.send;
//       ww <= req;
//    endrule

//    return fifosToServer(inf, outf);
// endmodule

import FIFO::*;
import FIFOLevel::*;
import StmtFSM::*;
import Vector::*;

(* synthesize  *)
(* options = "-aggressive-conditions" *)
module sysGFIFOLevelTest();

   Vector#(8, FIFOLevelIfc#(Bit#(8), 5))  dut = newVector;
   dut[0] <- mkGFIFOLevel(True,  True,  True);
   dut[1] <- mkGFIFOLevel(True,  True,  False);
   dut[2] <- mkGFIFOLevel(True,  False, True);
   dut[3] <- mkGFIFOLevel(True,  False, False);
   dut[4] <- mkGFIFOLevel(False, True,  True);
   dut[5] <- mkGFIFOLevel(False, True,  False);
   dut[6] <- mkGFIFOLevel(False, False, True);
   dut[7] <- mkGFIFOLevel(False, False, False);

   Reg#(Bit#(32)) index <- mkReg(0);
   Wire#(Bit#(8))  data  <- mkWire;

   PulseWire       enq   <- mkPulseWire;
   PulseWire       deq   <- mkPulseWire;
   PulseWire       enqF  <- mkPulseWire;
   PulseWire       deqF  <- mkPulseWire;

   rule enqueue(enq);
      $display("Enqueueing %d : %h", index, data);
      dut[index].enq(data);
      enqF.send;
   endrule

   rule dequeue(deq);
      $display("Dequeueing %d : %h", index, dut[index].first);
      dut[index].deq;
      deqF.send;
   endrule

   rule lessthan;
      $display("LessThan: %b", dut[index].isLessThan(3));
   endrule

   rule greaterthan;
      $display("GreaterThan: %b", dut[index].isGreaterThan(2));
   endrule

   Stmt test =
   (seq
       index <= 0; // T, T, T
       action data <= 8'h01; enq.send; endaction
       action data <= 8'h02; enq.send; endaction
       action data <= 8'h03; enq.send; endaction
       action data <= 8'h04; enq.send; endaction
       action data <= 8'h05; enq.send; endaction
       action data <= 8'h06; enq.send; endaction
       action data <= 8'h07; deq.send; endaction
       action data <= 8'h08; deq.send; endaction
       action data <= 8'h09; deq.send; endaction
       action data <= 8'h0A; deq.send; endaction
       action data <= 8'h0B; deq.send; endaction
       action data <= 8'h0C; deq.send; endaction

       index <= 1; // T, T, F
       action data <= 8'h01; enq.send; endaction
       action data <= 8'h02; enq.send; endaction
       action data <= 8'h03; enq.send; endaction
       action data <= 8'h04; enq.send; endaction
       action data <= 8'h05; enq.send; endaction
       action data <= 8'h06; enq.send; endaction
       action data <= 8'h07; deq.send; endaction
       action data <= 8'h08; deq.send; endaction
       action data <= 8'h09; deq.send; endaction
       action data <= 8'h0A; deq.send; endaction
       action data <= 8'h0B; deq.send; endaction
       action data <= 8'h0C; deq.send; endaction


       index <= 2; // T, F, T
       action data <= 8'h01; enq.send; endaction
       action data <= 8'h02; enq.send; endaction
       action data <= 8'h03; enq.send; endaction
       action data <= 8'h04; enq.send; endaction
       action data <= 8'h05; enq.send; endaction
       action data <= 8'h06; enq.send; endaction
       action data <= 8'h07; deq.send; endaction
       action data <= 8'h08; deq.send; endaction
       action data <= 8'h09; deq.send; endaction
       action data <= 8'h0A; deq.send; endaction
       action data <= 8'h0B; deq.send; endaction
       action data <= 8'h0C; deq.send; endaction


       index <= 3; // T, F, F
       action data <= 8'h01; enq.send; endaction
       action data <= 8'h02; enq.send; endaction
       action data <= 8'h03; enq.send; endaction
       action data <= 8'h04; enq.send; endaction
       action data <= 8'h05; enq.send; endaction
       action data <= 8'h06; enq.send; endaction
       action data <= 8'h07; deq.send; endaction
       action data <= 8'h08; deq.send; endaction
       action data <= 8'h09; deq.send; endaction
       action data <= 8'h0A; deq.send; endaction
       action data <= 8'h0B; deq.send; endaction
       action data <= 8'h0C; deq.send; endaction


       index <= 4; // F, T, T
       action data <= 8'h01; enq.send; endaction
       action data <= 8'h02; enq.send; endaction
       action data <= 8'h03; enq.send; endaction
       action data <= 8'h04; enq.send; endaction
       action data <= 8'h05; enq.send; endaction
       action data <= 8'h06; enq.send; endaction
       action data <= 8'h07; deq.send; endaction
       action data <= 8'h08; deq.send; endaction
       action data <= 8'h09; deq.send; endaction
       action data <= 8'h0A; deq.send; endaction
       action data <= 8'h0B; deq.send; endaction
       action data <= 8'h0C; deq.send; endaction


       index <= 5; // F, T, F
       action data <= 8'h01; enq.send; endaction
       action data <= 8'h02; enq.send; endaction
       action data <= 8'h03; enq.send; endaction
       action data <= 8'h04; enq.send; endaction
       action data <= 8'h05; enq.send; endaction
       action data <= 8'h06; enq.send; endaction
       action data <= 8'h07; deq.send; endaction
       action data <= 8'h08; deq.send; endaction
       action data <= 8'h09; deq.send; endaction
       action data <= 8'h0A; deq.send; endaction
       action data <= 8'h0B; deq.send; endaction
       action data <= 8'h0C; deq.send; endaction


       index <= 6; // F, F, T
       action data <= 8'h01; enq.send; endaction
       action data <= 8'h02; enq.send; endaction
       action data <= 8'h03; enq.send; endaction
       action data <= 8'h04; enq.send; endaction
       action data <= 8'h05; enq.send; endaction
       action data <= 8'h06; enq.send; endaction
       action data <= 8'h07; deq.send; endaction
       action data <= 8'h08; deq.send; endaction
       action data <= 8'h09; deq.send; endaction
       action data <= 8'h0A; deq.send; endaction
       action data <= 8'h0B; deq.send; endaction
       action data <= 8'h0C; deq.send; endaction


       index <= 7; // F, F, F
       action data <= 8'h01; enq.send; endaction
       action data <= 8'h02; enq.send; endaction
       action data <= 8'h03; enq.send; endaction
       action data <= 8'h04; enq.send; endaction
       action data <= 8'h05; enq.send; endaction
       action data <= 8'h06; enq.send; endaction
       action data <= 8'h07; deq.send; endaction
       action data <= 8'h08; deq.send; endaction
       action data <= 8'h09; deq.send; endaction
       action data <= 8'h0A; deq.send; endaction
       action data <= 8'h0B; deq.send; endaction
       action data <= 8'h0C; deq.send; endaction


    endseq);

   mkAutoFSM(test);
endmodule

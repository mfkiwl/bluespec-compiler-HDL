// This test is identical to OneModule.bsv, except that the rules and state
// for the two clock domains are in separately-synthesized modules which
// take the clocks as inputs.

// This is different from TwoSubmodulesInputClock.bsv in that
// the clocks are coming as output clocks.

import Clocks::*;

// Clock periods
Integer p1 = 6;
Integer p2 = 4;

(* synthesize *)
module sysTwoSubmodulesInputClockOutputClock ();
   Clock clk1 <- mkAbsoluteClock(p1, p1);
   ClkSub clksub <- mkTwoSubmodulesInputClockOutputClock_ClkSub1;
   Clock clk2 = clksub.clk;

   mkTwoSubmodulesInputClockOutputClock_Sub1(clk1, clocked_by noClock, reset_by noReset);
   mkTwoSubmodulesInputClockOutputClock_Sub2(clk2, clocked_by noClock, reset_by noReset);
endmodule

// the initial value of the registers will be AA
Bit#(8) init_val = 8'hAA;

// function to make $stime the same for Bluesim and Verilog
function ActionValue#(Bit#(32)) adj_stime(Integer p);
   actionvalue
      let adj = (p + 1) / 2;
      let t <- $stime();
      if (genVerilog)
	 return (t + fromInteger(adj));
      else
	 return t;
   endactionvalue
endfunction

interface ClkSub;
   interface Clock clk;
endinterface

(* synthesize *)
module mkTwoSubmodulesInputClockOutputClock_ClkSub1 (ClkSub);
   Clock clk2 <- mkAbsoluteClock(p2, p2);
   interface Clock clk = clk2;
endmodule

(* synthesize *)
module mkTwoSubmodulesInputClockOutputClock_Sub1 (Clock clk, Empty e);
   // use RegU to avoid the need for a reset
   Reg#(Bit#(8)) rg1 <- mkRegU(clocked_by clk);

   rule r1;
      rg1 <= rg1 + 1;
      $display("(%d) rg1 = %h", adj_stime(p1), rg1);
   endrule

   rule stop (rg1 > (init_val + 17));
      $finish(0);
   endrule
endmodule

(* synthesize *)
module mkTwoSubmodulesInputClockOutputClock_Sub2 (Clock clk, Empty e);
   // use RegU to avoid the need for a reset
   Reg#(Bit#(8)) rg2 <- mkRegU(clocked_by clk);

   rule r2;
      rg2 <= rg2 + 1;
      $display("(%d) rg2 = %h", adj_stime(p2), rg2);
   endrule
endmodule


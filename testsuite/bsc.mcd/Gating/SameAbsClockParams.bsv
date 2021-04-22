// This example builds two clocks with the same parameters,
// to see whether they are interpreted as separate domains or not.

import Clocks::*;

// Clock period
Integer p1 = 8;

(* synthesize *)
module sysSameAbsClockParams ();
   Clock clk1 <- mkAbsoluteClock(p1, p1);
   Clock clk2 <- mkAbsoluteClock(p1, p1);

   // use RegU to avoid the need for a reset
   Reg#(Bit#(8)) rg1 <- mkRegU(clocked_by clk1);
   Reg#(Bit#(8)) rg2 <- mkRegU(clocked_by clk2);

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

   rule r1;
      rg1 <= rg1 + 1;
      $display("(%d) rg1 = %h", adj_stime(p1), rg1);
   endrule

   rule r2;
      rg2 <= rg2 + 1;
      $display("(%d) rg2 = %h", adj_stime(p1), rg2);
   endrule

   rule stop (rg1 > (init_val + 17));
      $finish(0);
   endrule

endmodule


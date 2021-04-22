// Test that the user cannot declare a port reset_by multiple times

import "BVI" MOD =
module mkMyReg ( Clock aClk, Reset aRst,
		 Clock bClk, Reset bRst,
		 Bool b,
		 Reg#(Bool) ifcout ) ;

   default_clock no_clock;
   no_reset;

   input_clock aClk1 (CLK1, (*unused*)CLK_GATE1) = aClk ;
   input_clock aClk2 (CLK2, (*unused*)CLK_GATE2) = bClk ;

   input_reset aRst1 (RST1) clocked_by(aClk1) = aRst;
   input_reset aRst2 (RST1) clocked_by(aClk2) = bRst;

   port B reset_by(r1) clocked_by(aClk2) reset_by(r2) = b;

   method       _write(D_IN) enable(EN) clocked_by(aClk1);
   method Q_OUT _read                   clocked_by(aClk1);

   //schedule _read  CF  _read  ;
   //schedule _read  SB  _write ;
   //schedule _write SBR _write ;
endmodule


package Bug;

////////////////////////////////////////////////////////////////////////////////
///
////////////////////////////////////////////////////////////////////////////////

interface VBug#(type n) ;
//   method Bit#(n) next();
   method ActionValue#(Bit#(n)) next();
endinterface

import "BVI" ConstrainedRandom =
module vmkBug#(Integer width) (VBug#(n));

   default_clock clk(CLK);
   parameter width = width;

//   method (* reg *)OUT next();
   method (* reg *)OUT next() enable(EN);

endmodule

endpackage

////////////////////////////////////////////////////////////////////////////////
///
////////////////////////////////////////////////////////////////////////////////


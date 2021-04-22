// Accellera Standard V2.8.1 Open Verification Library (OVL).
// Accellera Copyright (c) 2005-2014. All rights reserved.



`ifdef OVL_ASSERT_ON

 wire xzcheck_enable;

`ifdef OVL_XCHECK_OFF
  assign xzcheck_enable = 1'b0;
`else
  `ifdef OVL_IMPLICIT_XCHECK_OFF
    assign xzcheck_enable = 1'b0;
  `else
    assign xzcheck_enable = 1'b1;
  `endif // OVL_IMPLICIT_XCHECK_OFF
`endif // OVL_XCHECK_OFF

 generate
   case (property_type)
     `OVL_ASSERT_2STATE,
     `OVL_ASSERT: begin: assert_checks
                   assert_range_assert #(
                       .width(width),
                       .min(min),
                       .max(max))
                   assert_range_assert (
                       .clk(clk),
                       .reset_n(`OVL_RESET_SIGNAL),
                       .test_expr(test_expr),
                       .xzcheck_enable(xzcheck_enable));
                  end
     `OVL_ASSUME_2STATE,
     `OVL_ASSUME: begin: assume_checks
                   assert_range_assume #(
                       .width(width),
                       .min(min),
                       .max(max))
                   assert_range_assert (
                       .clk(clk),
                       .reset_n(`OVL_RESET_SIGNAL),
                       .test_expr(test_expr),
                       .xzcheck_enable(xzcheck_enable));
                  end
     `OVL_IGNORE: begin: ovl_ignore
                    //do nothing
                  end
     default: initial ovl_error_t(`OVL_FIRE_2STATE,"");
   endcase
 endgenerate

`endif

`ifdef OVL_COVER_ON
 generate
  if (coverage_level != `OVL_COVER_NONE)
   begin: cover_checks
                assert_range_cover #(
                       .width(width),
                       .min(min),
                       .max(max),
                       .OVL_COVER_SANITY_ON(OVL_COVER_SANITY_ON),
                       .OVL_COVER_CORNER_ON(OVL_COVER_CORNER_ON))
                assert_range_cover (
                       .clk(clk),
                       .reset_n(`OVL_RESET_SIGNAL),
                       .test_expr(test_expr));
   end
 endgenerate
`endif

`endmodule //Required to pair up with already used "`module" in file assert_range.vlib

//Module to be replicated for assert checks
//This module is bound to a PSL vunits with assert checks
module assert_range_assert (clk, reset_n, test_expr, xzcheck_enable);
       parameter width = 8;
       parameter min = 1;
       parameter max = 2;
       input clk, reset_n;
       input [width-1:0] test_expr;
       input xzcheck_enable;
endmodule

//Module to be replicated for assume checks
//This module is bound to a PSL vunits with assume checks
module assert_range_assume (clk, reset_n, test_expr, xzcheck_enable);
       parameter width = 8;
       parameter min = 1;
       parameter max = 2;
       input clk, reset_n;
       input [width-1:0] test_expr;
       input xzcheck_enable;
endmodule

//Module to be replicated for cover properties
//This module is bound to a PSL vunit with cover properties
module assert_range_cover (clk, reset_n, test_expr);
       parameter width = 8;
       parameter min = 1;
       parameter max = 2;
       parameter OVL_COVER_SANITY_ON = 1;
       parameter OVL_COVER_CORNER_ON = 1;
       input clk, reset_n;
       input [width-1:0] test_expr;
endmodule

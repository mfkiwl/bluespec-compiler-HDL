/*************************************************************************************************************
Assertion-Checker: assert_increment

Description: test_expr inrements at the rising clock-edge by a value not equal to the specified value.

Status: simulation should fail

Author: pktiwari@noida.interrasystems.com

Date: 02-17-2006

*************************************************************************************************************/

import OVLAssertions::*;

typedef enum {First_State, Second_State, Third_State, Fourth_State, Fifth_State} FSM_State deriving(Eq, Bits);

(* synthesize *)
module assertIncrement2 (Empty);

Reg#(FSM_State) state <- mkRegA(First_State);

Reg#(Bit#(3)) test_expr <- mkRegA(0);

let defaults = mkOVLDefaults;
defaults.value = 2; //increment value : 2
AssertTest_IFC#(Bit#(3)) assertInc <- bsv_assert_increment(defaults);

rule test(True);
    assertInc.test(test_expr); // test_expr : test_expr
endrule

rule every (True);
    case (state)
    First_State:
	begin
	    state <= Second_State;
		test_expr  <= 3'b010;
	end
	Second_State:
	begin
	    state <= Third_State;
		test_expr  <= 3'b110;
	end
	Third_State:
	begin
	    state <= Fourth_State;
	end
	Fourth_State:
	begin
	    state <= Fifth_State;
	end
	Fifth_State:
	begin
	    state <= First_State;
	    $finish(0);
	end
    endcase
endrule
endmodule

(* synthesize *)
module sysArrayInBounds1();
   Integer x[4] = {1, 2, 3, 4};
   Integer y = x[2];

   rule test;
      $display("%0d", y);
      $finish(0);
   endrule

endmodule

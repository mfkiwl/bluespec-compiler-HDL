package DropWhile;

import List :: *;

function Action displayabc (a abc) provisos (Bits #(a, sa));
    action
      $display ("%d", abc);
    endaction
endfunction



function Action display_list (List #(a) my_list) provisos (Bits # (a,sa));
     action
       joinActions ( map (displayabc, my_list));
     endaction
endfunction

function Bool f1 (Int #(4) a);
   if (a < 2)
       return True;
   else
       return False;
endfunction


function Bool f2 (Int #(4) a);
   return True;
endfunction

function Bool f3 (Int #(4) a);
   return False;
endfunction

module mkTestbench_DropWhile();
   List #(Int #(4)) my_list1 = Cons (0, Cons (1, Cons (2, Cons (0, Cons (1, Nil)))));
   List #(Int #(4)) my_list2 = Cons (2, Cons (0, Cons(1, Nil)));



   rule fire_once (True);
      $display ("Original List:");
      display_list (my_list1);
      $display ("Drops Initial Segment with elements < 2. New List:");
      display_list (dropWhile(f1, my_list1));
      if (dropWhile(f1, my_list1) != my_list2 || dropWhile (f2, my_list1) != Nil || dropWhile (f3, my_list1) != my_list1)
        $display ("Simulation Fails");
      else
        $display ("Simulation Passes");
      $finish(2'b00);
   endrule

endmodule : mkTestbench_DropWhile
endpackage : DropWhile

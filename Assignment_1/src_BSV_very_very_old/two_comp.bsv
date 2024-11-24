package two_comp;
interface Tc_ifc;
    method Bit#(32) tc(Bit#(32) a);
endinterface
(* synthesize *)
module mkTc(Tc_ifc);
    method Bit#(32) tc(Bit#(32) a);
        return ~a+1;
    endmethod
endmodule
endpackage

/*
package Tb;
(* synthesize *)
module mkTb(Empty);
    Tc_ifc tc <- mkTc;
    rule r1;
        let x <- tc.tc(8'h01);
        $display ("%b",x);
        $finish;
    endrule
endmodule
endpackage
*/
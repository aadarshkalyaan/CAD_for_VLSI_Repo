package tc;
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

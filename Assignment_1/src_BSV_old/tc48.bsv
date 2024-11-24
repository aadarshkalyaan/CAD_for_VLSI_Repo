package tc48;
interface Tc48_ifc;
    method Bit#(48) tc(Bit#(48) a);
endinterface
(* synthesize *)
module mkTc48(Tc48_ifc);
    method Bit#(48) tc(Bit#(48) a);
        return (~{1'b0,a}+1)[47:0];
    endmethod
endmodule
endpackage
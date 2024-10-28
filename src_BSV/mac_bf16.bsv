package mac_bf16;
import fp_add::*;
import bf_mul::*;
interface Mac_bf16_ifc;
    method Bit#(32) compute(Bit#(16) a, Bit#(16) b, Bit#(32) c);
endinterface
(* synthesize *)
module mkMac_bf16(Mac_bf16_ifc);
    Bf_mul_ifc mul <- mkBf_mul;
    Fp_add_ifc add <- mkFp_add;
    function Bit#(32) mac(Bit#(16) a, Bit#(16) b, Bit#(32) c);
        Bit#(32) z = mul.compute(a,b);
        Bit#(32) z1 = add.compute(z,c);
        return z1;
    endfunction
    method Bit#(32) compute(Bit#(16) a, Bit#(16) b, Bit#(32) c);
        return mac(a,b,c);
    endmethod
endmodule
endpackage
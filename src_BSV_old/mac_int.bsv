package mac_int;
import cla32::*;
import mul8 ::*;
interface Mac_int_ifc;
    method Bit#(32) compute(Bit#(8) a, Bit#(8) b, Bit#(32) c);
endinterface
(* synthesize *)
module mkMac_int(Mac_int_ifc);
    Mul8_ifc mul <- mkMul8;
    Cla32_ifc add <- mkCla32;
    function mac(Bit#(8) a, Bit#(8) b, Bit#(32) c);
        Bit#(16) z = mul.compute(a,b);
        Bit#(33) z1 = add.compute(signExtend(z),c,1'b0);
        return z1[31:0];
    endfunction
    method Bit#(32) compute(Bit#(8) a, Bit#(8) b, Bit#(32) c);
        return mac(a,b,c);
    endmethod
endmodule
endpackage
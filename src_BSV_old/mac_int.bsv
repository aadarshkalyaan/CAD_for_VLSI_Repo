package mac_int;
import cla_int32::*;
import int8_signed_multiplier_2 ::*;
interface MAC_INT_ifc;
    method Bit#(32) compute(Bit#(8) a, Bit#(8) b, Bit#(32) c);
endinterface
(* synthesize *)
module mkMAC_INT(MAC_INT_ifc);
    Multi_ifc mul <- mkMultiplier;
    Cla32_ifc add <- mkCla32Adder;
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
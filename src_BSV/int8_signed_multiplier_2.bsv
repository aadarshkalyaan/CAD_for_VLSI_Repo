package int8_signed_multiplier_2;
import cla_int16 ::*;
import two_comp ::*;

import DReg ::*;
typedef struct{
   Bit#(1) overflow;
   Bit#(8) sum;
} Output_Cla deriving(Bits,Eq);
// Module to multiply two 8-bit signed integers using shift-and-add
interface Multi_ifc;
    method Bit#(16) compute(Bit#(8) a, Bit#(8) b);
endinterface : Multi_ifc
(*synthesize*)
module mkMultiplier (Multi_ifc);
    Tc_ifc tc1 <- mkTc;
    Tc_ifc tc2 <- mkTc;
    Tc_ifc tc3 <- mkTc;
    Cla16_ifc cla0_16 <- mkCla16Adder;
    Cla16_ifc cla1_16 <- mkCla16Adder;
    Cla16_ifc cla2_16 <- mkCla16Adder;
    Cla16_ifc cla3_16 <- mkCla16Adder;
    Cla16_ifc cla4_16 <- mkCla16Adder;
    Cla16_ifc cla5_16 <- mkCla16Adder;
    Cla16_ifc cla6_16 <- mkCla16Adder;
    Cla16_ifc cla7_16 <- mkCla16Adder;
    function Bit#(16) shift_and_add (Bit#(8) a, Bit#(8) b);
        Bit#(16) result = 0;
        Bit#(1) is_negative = (a[7]^b[7]);
        if (a[7]==1) begin
            let x = tc1.tc(signExtend(a));
            a = x[7:0];
        end
        if (b[7]==1) begin
            let x = tc2.tc(signExtend(b));
            b = x[7:0];
        end
        Bit#(16) b1={8'b0,b};
        for (Integer i = 0; i < 8; i = i + 1) begin
            Bit#(17) out1;
            if (a[0] == 1) begin
                case(i) 
                0: out1 = cla0_16.compute(result, b1, 1'b0);
                1: out1 = cla1_16.compute(result, b1, 1'b0);
                2: out1 = cla2_16.compute(result, b1, 1'b0);
                3: out1 = cla3_16.compute(result, b1, 1'b0);
                4: out1 = cla4_16.compute(result, b1, 1'b0);
                5: out1 = cla5_16.compute(result, b1, 1'b0);
                6: out1 = cla6_16.compute(result, b1, 1'b0);
                7: out1 = cla7_16.compute(result, b1, 1'b0);
                endcase
                result = out1[15:0];
            end
            b1= b1<<1;
            a = a>>1;
        end
        if (is_negative==1'b1) begin
            let x = tc3.tc(signExtend(result));
            result = x[15:0];
        end
        return result;
    endfunction 
    method Bit#(16) compute(Bit#(8) a, Bit#(8) b);
    return shift_and_add(a,b);
    endmethod 
    endmodule
endpackage
 
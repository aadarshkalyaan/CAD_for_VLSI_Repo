package mac_bf16;
import fp32Add::*;
import bf16_mul::*;
typedef enum {Idle,Multiplying,WaitMulResult,Adding,Done} State deriving (Bits, Eq);
    
interface MAC_BF16_ifc;
    method Action start(Bit#(16) a, Bit#(16) b, Bit#(32) c);
    method Bit#(32) get_result() ;
endinterface
(* synthesize *)
module mkMAC_BF16(MAC_BF16_ifc);
    Mul_BF16_ifc mul <- mkbf16_mul;
    FP32_Add_ifc add <- mkFP32Add;
    
    Reg#(State) state <- mkReg(Idle);
    Reg#(Bit#(16)) reg_a <- mkReg(0);
    Reg#(Bit#(16)) reg_b <- mkReg(0);
    Reg#(Bit#(32)) reg_c <- mkReg(0);
    Reg#(Bit#(32)) reg_mac <- mkReg(0);
    rule r1 (state == Multiplying);
        mul.start(reg_a,reg_b);
        state<=WaitMulResult;
    endrule
    rule r2 (state == WaitMulResult);
        let z <- mul.get_result;
        add.start(z,reg_c);
        state <= Adding;
    endrule
    rule r3 (state == Adding);
        let x <- add.get_result;
        reg_mac <= x;
        state <= Done;
    endrule
    method Action start(Bit#(16) a, Bit#(16) b, Bit#(32) c);
        reg_a <= a;
        reg_b <= b;
        reg_c <= c;
        state <= Multiplying;
    endmethod
    method Bit#(32) get_result() if (state == Done);
        //state <= Idle;
        return reg_mac;
    endmethod
endmodule
endpackage
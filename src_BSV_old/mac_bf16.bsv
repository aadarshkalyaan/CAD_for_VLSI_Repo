package mac_bf16;
import fp_add::*;
import bf_mul::*;
typedef enum {Idle,Multiplying,WaitMulResult,Adding,Done} State deriving (Bits, Eq);
    
interface Mac_bf16_ifc;
    method Action start(Bit#(16) a, Bit#(16) b, Bit#(32) c);
    method Bit#(32) get_result() ;
endinterface
(* synthesize *)
module mkMac_bf16(Mac_bf16_ifc);
    Bf_mul_ifc mul <- mkBf_mul;
    Fp_add_ifc add <- mkFp_add;
    
    Reg#(State) state <- mkReg(Idle);
    Reg#(Bit#(16)) reg_a <- mkReg(0);
    Reg#(Bit#(16)) reg_b <- mkReg(0);
    Reg#(Bit#(32)) reg_c <- mkReg(0);
    Reg#(Bit#(32)) reg_mac <- mkReg(0);
    rule r1 (state == Multiplying);
        mul.start(reg_a,reg_b);
        state<=WaitMulResult;
        $display("macbf16 r1");
    endrule
    rule r2 (state == WaitMulResult);
        let z <- mul.get_result;
        add.start(z,reg_c);
        state <= Adding;
        $display("macbf16 r2 %b %b", z, reg_c);
    endrule
    rule r3 (state == Adding);
        let x <- add.get_result;
        reg_mac <= x;
        state <= Done;
        $display("macbf16 r3 %b", x);
    endrule
    method Action start(Bit#(16) a, Bit#(16) b, Bit#(32) c) if (state == Idle);
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
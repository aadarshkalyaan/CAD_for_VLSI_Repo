// fp32Add.bsv
package fp_add;

import FIFO ::*;
import SpecialFIFOs ::*;
import RegFile ::*;
import Vector ::*;
import cla8 ::*;
import umul8 ::*;
import tc ::*;
import tc48 ::*;
import cla48 ::*;

typedef struct {
    Bit#(1)  sign;
    Bit#(8)  exp;
    Bit#(23) mant;
} FP32 deriving(Bits, Eq);

typedef struct{
    FP32 a;
    FP32 b;
} AdderInput deriving(Bits,Eq);

interface Fp_add_ifc;
    method Action start(Bit#(32) a, Bit#(32) b);
    method ActionValue#(Bit#(32)) get_result();
endinterface

module mkFp_add(Fp_add_ifc);
    // Stage control registers
    Reg#(Bool) stage1_valid <- mkReg(False);
    Reg#(Bool) stage2_valid <- mkReg(False);
    
    // Pipeline registers for intermediate results
    Reg#(FP32) a_reg <- mkRegU;
    Reg#(FP32) b_reg <- mkRegU;
    Reg#(Bit#(49)) sum_reg <- mkRegU;
    Reg#(Bit#(1)) result_sign_reg <- mkRegU;
    Reg#(Bit#(8)) base_exp_reg <- mkRegU;
    
    // Input/Output FIFOs
    FIFO#(AdderInput) ififo <- mkFIFO();
    FIFO#(FP32) ofifo <- mkFIFO();

    // Submodules
    Tc_ifc tc0 <- mkTc;
    Tc48_ifc tc48 <- mkTc48;
    Umul8_ifc mul0 <- mkUmul8;
    Cla8_ifc cla0 <- mkCla8;
    Cla8_ifc cla1 <- mkCla8;
    Cla48_ifc cla48_0 <- mkCla48;
    Cla48_ifc cla48_1 <- mkCla48;
    Cla48_ifc cla48_2 <- mkCla48;

    function FP32 unpack_fp32(Bit#(32) p);
        return FP32 {
            sign: p[31],
            exp:  p[30:23],
            mant: p[22:0]
        };
    endfunction

    function Bit#(32) pack_fp32(FP32 unpacked);
        return {unpacked.sign, unpacked.exp, unpacked.mant};
    endfunction

    function Bit#(24) normalise(Bit#(50) z);
        let p = z;
        if (z[49]==1) p = p>>1;
        Bit#(24) mantissa = {1'b0,p[47:25]};
        Bit#(1) roundbit = p[24];
        Bit#(1) stickybit = |p[23:0];
        Bit#(24) result = {1'b0,p[47:25]};
        if ((roundbit & (stickybit | mantissa[0]))== 1'b1) begin
            result = cla48_2.compute({24'b0,mantissa},48'b1,1'b0)[23:0];
        end
        return result;
    endfunction

    // Stage 1: Input processing and alignment
    rule stage1_process (!stage1_valid && !stage2_valid);
        let inp = ififo.first();
        ififo.deq();
        
        let signA = inp.a.sign;
        let signB = inp.b.sign;
        let expA = inp.a.exp;
        let expB = inp.b.exp;
        let mantA = {1'b1, inp.a.mant};
        let mantB = {1'b1, inp.b.mant};
        //$display(" a %b  %b  %b",signA,expA,mantA);
        //$display(" b %b  %b  %b",signB,expB,mantB);
        // Determine larger operand
        Bool swap = False;
        if (expB > expA || (expB == expA && mantB > mantA)) begin
            swap = True;
        end
        //$display("swap %b",swap);
        // Store aligned operands
        let bExp = swap ? expB : expA;
        let sExp = swap ? expA : expB;
        let bMant = swap ? mantB : mantA;
        let sMant = swap ? mantA : mantB;
        let bSign = swap ? signB : signA;
        let sSign = swap ? signA : signB;
        let q = tc0.tc({24'b0,(sExp)});
        let q1 = cla0.compute(bExp,q[7:0],1'b0);
        UInt#(8) expdiff = unpack(q1[7:0]);
        Bit#(48) alignedSMant = {sMant, 24'b0} >> expdiff;
        Bit#(48) extendedBMant = {bMant, 24'b0};
        $display("expdiff %d",expdiff);
        // Store intermediate results
        a_reg <= FP32{sign: bSign, exp: bExp, mant: bMant[22:0]};
        b_reg <= FP32{sign: sSign, exp: sExp, mant: sMant[22:0]};
        let p = tc48.tc(alignedSMant);
        let m1 = cla48_0.compute(extendedBMant,alignedSMant,1'b0);
        let m2 = cla48_1.compute(extendedBMant,p,1'b0);
        sum_reg <= (signA == signB) ? m1:m2;
        //$display("sumreg  %b %b",m1,m2);        
        result_sign_reg <= bSign;
        base_exp_reg <= bExp;
        
        stage1_valid <= True;
    endrule

    // Stage 2: Normalization and final result
    rule stage2_process (stage1_valid && !stage2_valid);
        stage1_valid <= False;
        stage2_valid <= True;
        //$display("sumreg  %b",sum_reg); 
        Int#(2) expAdjust = 0;
        if (sum_reg[48]==1) expAdjust = expAdjust + 1;
        Bit#(24) normMant = normalise({sum_reg,1'b0});
        if (normMant[23] == 1) expAdjust = expAdjust + 1;

        Int#(9) finalExp = unpack(cla1.compute(base_exp_reg,{6'b0,pack(expAdjust)},1'b0));
        
        FP32 finalResult;
        finalResult = FP32 {
            sign: result_sign_reg,
            exp: truncate(pack(finalExp)),
            mant: normMant[22:0]
        };
     
        
        ofifo.enq(finalResult);
    endrule

    // Stage cleanup
    rule clear_stage2 (stage2_valid);
        stage2_valid <= False;
    endrule

    method Action start(Bit#(32) a, Bit#(32) b);
        ififo.enq(AdderInput{a:unpack_fp32(a), b:unpack_fp32(b)});
    endmethod
    
    method ActionValue#(Bit#(32)) get_result();
        let result = ofifo.first;
        ofifo.deq;
        return pack_fp32(result);
    endmethod
endmodule

endpackage

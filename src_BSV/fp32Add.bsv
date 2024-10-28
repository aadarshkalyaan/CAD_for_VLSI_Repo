// fp32Add.bsv
package fp32Add;

import FIFO ::*;
import SpecialFIFOs ::*;
import RegFile ::*;
import Vector ::*;
import cla_int8_without_start ::*;
import int8_unsigned_multiplier ::*;
import two_comp ::*;
import two_comp_48 ::*;
import cla_int48 ::*;

typedef struct {
    Bit#(1)  sign;
    Bit#(8)  exp;
    Bit#(23) mant;
} FP32 deriving(Bits, Eq);

typedef struct{
    FP32 a;
    FP32 b;
} AdderInput deriving(Bits,Eq);

interface FP32_Add_ifc;
    method Action start(Bit#(32) a, Bit#(32) b);
    method ActionValue#(Bit#(32)) get_result();
endinterface

module mkFP32Add(FP32_Add_ifc);
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
    Multi_ifc mul0 <- mkMultiplier;
    Cla_ifc cla0 <- mk_cla_add;
    Cla_ifc cla1 <- mk_cla_add;
    Cla48_ifc cla48_0 <- mkCla48Adder;
    Cla48_ifc cla48_1 <- mkCla48Adder;
    Cla48_ifc cla48_2 <- mkCla48Adder;

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
/*
// Testbench.bsv
package Testbench;

import fp32Add::*;
import FIFO::*;
import StmtFSM::*;

(* synthesize *)
module mkTestbench(Empty);
    FP32_Add_ifc adder <- mkFP32Add;
    Reg#(Bool) input_done <- mkReg(False);
    Reg#(Bool) test_done <- mkReg(False);
    Reg#(Bit#(32)) cycle <- mkReg(0);
    
    // Test vectors
    Vector#(4, Bit#(32)) test_inputs_a = vec(
        32'h40000000,  // 2.0
        32'h40400000,  // 3.0
        32'h40800000,  // 4.0
        32'h40A00000   // 5.0
    );
    
    Vector#(4, Bit#(32)) test_inputs_b = vec(
        32'h3F800000,  // 1.0
        32'h40000000,  // 2.0
        32'h40400000,  // 3.0
        32'h40800000   // 4.0
    );
    
    Reg#(Bit#(2)) input_idx <- mkReg(0);
    Reg#(Bit#(2)) output_idx <- mkReg(0);

    rule count_cycles;
        cycle <= cycle + 1;
        if (cycle > 100) begin
            $display("Test timeout!");
            $finish(0);
        end
    endrule

    rule send_inputs (!input_done);
        if (input_idx == 4) begin
            input_done <= True;
        end else begin
            adder.start(test_inputs_a[input_idx], test_inputs_b[input_idx]);
            input_idx <= input_idx + 1;
        end
    endrule

    rule get_results (!test_done);
        let result <- adder.get_result();
        $display("Result[%d] = %h", output_idx, result);
        
        if (output_idx == 3) begin
            test_done <= True;
            $display("Test completed successfully!");
            $finish(0);
        end else begin
            output_idx <= output_idx + 1;
        end
    endrule

endmodule

endpackage*/
package fp32_add;

// FP32 number structure (for internal use)
typedef struct {
    Bit#(1)  sign;
    Bit#(8)  exp;
    Bit#(23) mant;
} FP32 deriving(Bits, Eq);

// Interface using direct bits
interface FP32_Add;
    method Action start(Bit#(32) a, Bit#(32) b);
    method Bit#(32) getResult();
endinterface

// Module implementation
module mkFP32Add(FP32_Add);
    // Registers for operands and result
    Reg#(FP32) operandA <- mkRegU;
    Reg#(FP32) operandB <- mkRegU;
    Reg#(FP32) result <- mkRegU;
    Reg#(Bool) validResult <- mkReg(False);

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
    
    // Helper function to normalize mantissa
    function Tuple2#(Bit#(24), Integer) normalize(Bit#(24) mant, Integer exp);
        Integer shift = 0;
        Bit#(24) normalized = mant;
        
        while ((normalized != 0) && (normalized[23] != 1)) begin
            normalized = normalized << 1;
            shift = shift - 1;
        end
        
        return tuple2(normalized, shift);
    endfunction
    
    // Main addition rule
    rule add (validResult == False);
        // Extract components
        let signA = operandA.sign;
        let signB = operandB.sign;
        let expA = operandA.exp;
        let expB = operandB.exp;
        let mantA = {1'b1, operandA.mant}; // Add implicit 1
        let mantB = {1'b1, operandB.mant};
        
        // Determine larger operand
        Bool swap = False;
        if (expB > expA || (expB == expA && mantB > mantA)) begin
            swap = True;
        end
        
        // Align operands
        let bigExp = swap ? expB : expA;
        let smallExp = swap ? expA : expB;
        let bigMant = swap ? mantB : mantA;
        let smallMant = swap ? mantA : mantB;
        let bigSign = swap ? signB : signA;
        let smallSign = swap ? signA : signB;
        
        // Calculate exponent difference
        Int#(9) expDiff = zeroExtend(bigExp) - zeroExtend(smallExp);
        
        // Align smaller mantissa
        Bit#(48) alignedSmallMant = {smallMant, 24'b0} >> expDiff;
        Bit#(48) extendedBigMant = {bigMant, 24'b0};
        
        // Perform addition/subtraction
        Bit#(48) sumMant;
        Bit#(1) resultSign;
        if (signA == signB) begin
            sumMant = extendedBigMant + alignedSmallMant; //48 bit 
            resultSign = bigSign;
        end else begin
            sumMant = extendedBigMant - alignedSmallMant;
            resultSign = bigSign;
        end
        
        // Normalize result
        Bit#(24) normMant = truncate(sumMant >> 24);
        Integer expAdjust = 0;
        
        // Check if need to shift right (overflow case)
        if (normMant[23] == 1) begin
            normMant = normMant >> 1;
            expAdjust = expAdjust + 1;
        end else begin
            // Need to shift left (underflow case)
            let normResult = normalize(normMant, expAdjust);
            normMant = tpl_1(normResult);
            expAdjust = expAdjust + tpl_2(normResult);
        end
        
        // Calculate final exponent
        Integer finalExp = zeroExtend(bigExp) + expAdjust;
        
        // Handle special cases and create result
        FP32 finalResult;
        
        if (finalExp >= 255) begin
            // Overflow to infinity
            finalResult = FP32 {
                sign: resultSign,
                exp: 8'hFF,
                mant: 23'b0
            };
        end else if (finalExp <= 0) begin
            // Underflow to zero
            finalResult = FP32 {
                sign: resultSign,
                exp: 8'h00,
                mant: 23'b0
            };
        end else begin
            // Normal case
            finalResult = FP32 {
                sign: resultSign,
                exp: truncate(finalExp),
                mant: truncate(normMant[22:0])
            };
        end
        
        result <= finalResult;
        validResult <= True;
    endrule
    
    // Interface methods now using Bit#(32)
    method Action start(Bit#(32) a, Bit#(32) b);
        operandA <= unpack_fp32(a);
        operandB <= unpack_fp32(b);
        validResult <= False;
    endmethod
    
    method Bit#(32) getResult() if (validResult);
        return pack_fp32(result);
    endmethod
endmodule
endpackage
/*
// Testbench
module mkTb(Empty);
    FP32_Add adder <- mkFP32Add;
    Reg#(int) cycle <- mkReg(0);
    
    rule test;
        if (cycle == 0) begin
            // Test case: 1.5 + 2.75
            // 1.5  = 1.1     * 2^0  = 0x3FC00000
            // 2.75 = 1.0110  * 2^1  = 0x40300000
            Bit#(32) a = 32'h3FC00000;  // 1.5
            Bit#(32) b = 32'h40300000;  // 2.75
            adder.putOperands(a, b);
        end
        
        cycle <= cycle + 1;
        
        if (cycle == 2) begin
            let result = adder.getResult();
            // Print in hex and break down components
            $display("Input A:  %h", 32'h3FC00000);
            $display("Input B:  %h", 32'h40300000);
            $display("Result:   %h", result);
            $display("Result components:");
            $display("  Sign:     %b", result[31]);
            $display("  Exponent: %b", result[30:23]);
            $display("  Mantissa: %b", result[22:0]);
            $finish;
        end
    endrule
endmodule

endpackage
*/
/*
package Testbench ;
import fp32Add ::*;
module mkTestbench();
FP32_Add_ifc adder <- mkFP32Add;
    Reg#(int) cycle <- mkReg(0);
    
    rule test;
        if (cycle == 0) begin
            // Test case: 1.5 + 2.75
            // 1.5  = 1.1     * 2^0  = 0x3FC00000
            // 2.75 = 1.0110  * 2^1  = 0x40300000
            Bit#(32) a = 32'b01010110100110011101110000000000;  // 1.5
            Bit#(32) b = 32'b01000001110010101100001010010000;  // 2.75
            adder.start(a, b);
        end
        
        cycle <= cycle + 1;
        
        if (cycle == 2) begin
            let result <- adder.get_result();
            // Print in hex and break down components
            $display("Input A:  %b", 32'b01010110100110011101110000000000);
            $display("Input B:  %b", 32'b01000001110010101100001010010000);
            $display("Result:   %b", result);
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
/*// Testbench
package Testbench;
import pl_mul_8 ::*;
import Vector::*;

(* synthesize *)
module mkTestbench();
    Pl_mul_8_ifc adder <- mkpl_adder16();
    Reg#(Bit#(3)) testState <- mkReg(0);
    Reg#(Bit#(3)) out <- mkReg(0);
    
    // Test vectors
    Vector#(4, Tuple2#(Bit#(8), Bit#(8))) testVectors = newVector;
    testVectors[0] = tuple2(8'd34, 8'd68);  // Normal case
    testVectors[1] = tuple2(8'hFF, 8'd255);  // Max value + 1
    testVectors[2] = tuple2(8'h80, 8'h8);  // Overflow case
    testVectors[3] = tuple2(8'h43, 8'h85);  // Random values
    
    // Rule to feed test vectors
    rule feed_inputs (testState < 4);
        let test = testVectors[testState];
        let a = tpl_1(test);
        let b = tpl_2(test);
        adder.start(a,b);
        $display("Time %0t: %d Multiplying %d and %d", $time, testState, a, b);
        testState <= testState + 1;
    endrule
    
    // Rule to check results
    rule check_results;
        let result <- adder.get_result();
        $display("Time %0t: Result %d = %d", $time, out,result);
        out<=out+1;
		if (out == 3) begin
            $display("All test cases completed");
            $finish(0);
        end

    endrule
	endmodule
endpackage
*/
/*package Testbench;
import multiplier8 ::*;
typedef struct{
    Bit#(16) r;
  } MulOutput deriving(Bits, Eq);
(* synthesize *)
module mkTestbench (Empty);
	Multi_ifc mac_inst <- mkMultiplier;
	Reg#(Bit#(1)) inp_valid <- mkReg(1'b1);
	rule rl_go if(inp_valid==1'b1);
		mac_inst.start(8'hEE,8'h12);
		inp_valid<=1'b0;
	endrule
	rule rl_finish;
		let z <- mac_inst.get_result;
		$display ("Product = %b", z.r);
		$finish();
		
	endrule
endmodule: mkTestbench
endpackage*/

/*
package Testbench;
import bf16_mul ::*;
typedef struct{
    Bit#(16) r;
  } MulOutput deriving(Bits, Eq);
(* synthesize *)
module mkTestbench (Empty);
	Mul_BF16_ifc mac_inst <- mkbf16_mul;
	Reg#(Bit#(1)) inp_valid <- mkReg(1'b1);
	rule rl_go if(inp_valid==1'b1);
		mac_inst.start(16'b0100000100101100,16'b0100001000111000);
		inp_valid<=1'b0;
	endrule
	rule rl_finish;
		let z <- mac_inst.get_result;
		$display ("Product = %b", z);
		$finish();
		
	endrule
endmodule: mkTestbench
endpackage
*/

/*
package Testbench;
import mult ::*;
(* synthesize *)
module mkTestbench(Empty);
    Mul_ifc bm<- mkmul;
    rule r;
        bm.init(8'h02,8'h04);
	endrule
    rule r1;
        $display ("%b",bm.get_result);
        //$finish;
    endrule
endmodule
endpackage
*/
/*
package Testbench;
import booth_multiplier ::*;
(* synthesize *)
module mkTestbench(Empty);
    Boo_ifc bm<- mkboo;
    rule r;
        bm.init(8'h02,8'h04);
	endrule
    rule r1;
        let x = bm.get_result;
        $display ("%b",x);
        $finish;
    endrule
endmodule
endpackage
*/
/*
package Testbench;
import int8_signed_multiplier ::*;
import cla_int32::*;
(* synthesize *)
module mkTestbench (Empty);
	Cla32_ifc mac_inst <- mkCla32Adder;
	rule rl_go;
		let z = mac_inst.compute(32'hFFFFFFFF,32'h01,1'b0); //-18*-2 
		$display ("sum = %b", z);
		$finish();
	endrule
endmodule: mkTestbench
endpackage
*/

/*
package Testbench;
import int8_signed_multiplier_2 ::*;
(* synthesize *)
module mkTestbench (Empty);
	Multi_ifc mac_inst <- mkMultiplier;
	rule rl_go;
		let z = mac_inst.compute(8'h12,8'hEE); //-18*-2 
		$display ("Product = %d", z);
		$finish();	
	endrule
endmodule: mkTestbench
endpackage
//*/
/*
package Testbench;
import int8_signed_multiplier ::*;
import cla_int8::*;
(* synthesize *)
module mkTestbench (Empty);
	Cla_ifc mac_inst <- mk_cla_add;
	rule rl_go;
		mac_inst.start(8'hEE,8'hEE,1'b0);
	endrule
	rule rl_finish;
		let z = mac_inst.get_result;
		$display ("Sum = %b", z.sum);
		if (z.overflow == 1) begin
		$display ("Overflow = %b", z.overflow);
		end
		$finish();
		
	endrule
endmodule: mkTestbench
endpackage
*/

package Testbench;
import Top::*;
(* synthesize *)
module mkTestbench (Empty);
	Top_ifc mac_inst <- mkTop;
	rule rl_start;
		mac_inst.start(16'h412C,16'h54E5,32'h41CAC290,1'b1);
	endrule
	rule rl_finish;
		let z = mac_inst.get_result;
		$display ("Product = %b", z);
		$finish ();
	endrule
endmodule: mkTestbench
endpackage

//Yesterday it was working no?
//Yeah, one minute I'll check, maybe some small issue
/*
package Testbench;
import mac_bf16::*;
(* synthesize *)
module mkTestbench (Empty);
	MAC_BF16_ifc mac_inst <- mkMAC_BF16;
	rule rl_start;
		mac_inst.start(16'b0100000100100000,16'b0011111000100011,32'b00111111111101011110001101010101);
	endrule
	rule rl_finish;
		let z = mac_inst.get_result;
		$display ("Product = %b", z);
		$finish ();
	endrule
endmodule: mkTestbench
endpackage
*/
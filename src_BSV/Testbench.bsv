/*
package Testbench;
import top::*;
(* synthesize *)
module mkTestbench (Empty);
	Top_ifc mac_inst <- mkTop;
	rule rl_start;
		mac_inst.start(16'b0000000000100100,16'b0000000010000001,32'b11111111111111111111111000001001,1'b0);
	endrule
	rule rl_finish;
		let z = mac_inst.get_result;
		$display ("Product = %b", z);
		$finish ();
	endrule
endmodule
endpackage
*/
package Testbench;
import pl_mac_int::*;
import Vector::*;

(* synthesize *)
module mkTestbench();
    Pl_mac_int_ifc mac_inst <- mkPl_mac_int;
    Reg#(Bit#(4)) testState <- mkReg(0);
    Reg#(Bit#(4)) out <- mkReg(0);
    
    // Test vectors
    Vector#(10, Tuple3#(Bit#(8), Bit#(8), Bit#(32))) testVectors = newVector;
    testVectors[0] = tuple3(8'b01000001, 8'b01010100,32'b01000001110010101100001010010000);  // Normal case
    testVectors[1] = tuple3(8'b01001111, 8'b01010100,32'b01010100001111000110101010000000);  // Max value + 1
    testVectors[2] = tuple3(8'b01000010, 8'b01001011,32'b01001000000110111010010111100100);  // Overflow case
    testVectors[3] = tuple3(8'b01001100, 8'b01001111,32'b01010001100011110101110000101001);  // Random values
    testVectors[4] = tuple3(8'b01010000, 8'b01000010,32'b01001000110010101100000010000100);
    testVectors[5] = tuple3(8'b01000101, 8'b01010011,32'b01010010011000110101001111111001);
    testVectors[6] = tuple3(8'b01010000, 8'b01001011,32'b01001101010011001100110011001101);
    testVectors[7] = tuple3(8'b01010011, 8'b00111110,32'b01001001010001001001101110100110);
    testVectors[8] = tuple3(8'b01001011, 8'b01000010,32'b01001101010001001001101110100110);
    testVectors[9] = tuple3(8'b01000101, 8'b01001001,32'b01001010011111011111001110110111);
    
    // Rule to feed test vectors
    rule feed_inputs (testState < 10);
        let test = testVectors[testState];
        let a = tpl_1(test);
        let b = tpl_2(test);
        let c = tpl_3(test);
        mac_inst.start(a,b,c);
        $display("Time %0t: test %d  ", $time, testState);
        testState <= testState + 1;
        if (testState == 9) begin
            $display("All test cases completed");
            $finish(0);
        end

    endrule
    
    // Rule to check results
    rule check_results;
        let result <- mac_inst.get_result();
        $display("Time %0t: Result %d = %b", $time, out,result);
        out<=out+1;
		if (out == 9) begin
            $display("All test cases completed");
            $finish(0);
        end

    endrule
	endmodule
endpackage


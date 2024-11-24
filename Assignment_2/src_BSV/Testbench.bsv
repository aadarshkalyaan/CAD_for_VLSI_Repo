package Testbench;

import Vector::*;
import SystolicArray::*;
import StmtFSM::*;

(* synthesize *)
module mkTestbench(Empty);
    // Instantiate the systolic array
    SystolicArray_IFC dut <- mkSystolicArray();
    
    // Define a counter to track test progress
    Reg#(int) cycle <- mkReg(0);
    
    // Rule to increment cycle
    rule increment_cycle;
        cycle <= cycle + 1;
    endrule
    
    // Initialize C values
    rule init_c (cycle == 0);
        Vector#(4, Vector#(4, Bit#(32))) init_c = replicate(replicate(0));
        dut.initialise();
        $display("Cycle %0d: Initialized C values", cycle);
    endrule
    
    // Set S values
    rule set_s (cycle == 1);
        Vector#(4, Bit#(1)) s_vals = replicate(1);
        dut.input_S(s_vals);
        $display("Cycle %0d: Set S values", cycle);
    endrule
    
    // Input first column of B
    rule input_b1 (cycle == 2);
        Vector#(4, Bit#(16)) b_col = Vector::cons(1,
                                    Vector::cons(3,
                                    Vector::cons(0,
                                    Vector::cons(0, nil))));
        dut.input_B(b_col);
        $display("Cycle %0d: Input first B column", cycle);
    endrule
    
    // Input second column of B
    rule input_b2 (cycle == 3);
        Vector#(4, Bit#(16)) b_col = Vector::cons(2,
                                    Vector::cons(4,
                                    Vector::cons(0,
                                    Vector::cons(0, nil))));
        dut.input_B(b_col);
        $display("Cycle %0d: Input second B column", cycle);
    endrule
    
    // Input first row of A
    rule input_a1 (cycle == 4);
        Vector#(4, Bit#(16)) a_row = Vector::cons(1,
                                    Vector::cons(2,
                                    Vector::cons(0,
                                    Vector::cons(0, nil))));
        dut.input_A(a_row);
        $display("Cycle %0d: Input first A row", cycle);
    endrule
    
    // Input second row of A
    rule input_a2 (cycle == 5);
        Vector#(4, Bit#(16)) a_row = Vector::cons(3,
                                    Vector::cons(4,
                                    Vector::cons(0,
                                    Vector::cons(0, nil))));
        dut.input_A(a_row);
        $display("Cycle %0d: Input second A row", cycle);
    endrule
    
    // Get results
    rule get_results (cycle == 10);
        let result <- dut.get_result();
        $display("\nFinal Results:");
        for (Integer i = 0; i < 4; i = i + 1) begin
            $display("Row %0d: %0d %0d %0d %0d",
                i,
                result[i][0],
                result[i][1],
                result[i][2],
                result[i][3]);
        end
        $finish(0);
    endrule

endmodule

endpackage




// package Testbench;

// import MAC_Wrapper::*;
// import StmtFSM::*;

// (* synthesize *)
// module mkTestbench(Empty);
//     // Instantiate the DUT
//     MAC_Wrapper_IFC dut <- mkMAC_Wrapper;
    
//     // Test control register
//     Reg#(Bool) testDone <- mkReg(False);
//     Reg#(Bool) inputsSent <- mkReg(False);
    
//     // Test case - Integer MAC mode (s=0)
//     rule send_inputs (!inputsSent);
//         // Send inputs: a=5, b=3, c=1, s=0
//         // Expected result: (5 * 3) + 1 = 16
//         dut.enq_A(16'h0005);  // Using lower 8 bits = 5
//         dut.enq_B(16'h0003);  // Using lower 8 bits = 3
//         dut.enq_C(32'h0000_0001);
//         dut.enq_S(1'b0);
        
//         $display("Inputs sent: A=5, B=3, C=1, S=0");
//         inputsSent <= True;
//     endrule

//     rule receive_outputs (inputsSent && !testDone);
//         // Get pass-through values
//         let a_out <- dut.get_A_out();
//         let b_out <- dut.get_B_out();
//         let s_out <- dut.get_S_out();
//         let mac_result <- dut.get_MAC_result();
        
//         // Display results
//         $display("Pass-through values received:");
//         $display("A_out = %h", a_out);
//         $display("B_out = %h", b_out);
//         $display("S_out = %b", s_out);
//         $display("MAC result = %h", mac_result);
        
//         // Check results
//         if (mac_result == 32'h0000_0010)
//             $display("Test PASSED: MAC result correct");
//         else
//             $display("Test FAILED: Expected 16 (0x10), Got %h", mac_result);
            
//         testDone <= True;
//     endrule

//     rule finish (testDone);
//         $display("Test completed");
//         $finish(0);
//     endrule

// endmodule

// endpackage


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
// package Testbench;
// import mac_bf16::*;
// import Vector::*;

// (* synthesize *)
// module mkTestbench();
//     Mac_bf16_ifc mac_inst <- mkMac_bf16;
//     Reg#(Bit#(4)) testState <- mkReg(0);
//     Reg#(Bit#(4)) out <- mkReg(0);
    
//     // Test vectors
//     Vector#(10, Tuple3#(Bit#(16), Bit#(16), Bit#(32))) testVectors = newVector;
//     testVectors[0] = tuple3(16'b0100000100101100, 16'b0101010011100101,32'b01000001110010101100001010010000);  // Normal case
//     testVectors[1] = tuple3(16'b0100111111010001, 16'b0101010010001001,32'b01010100001111000110101010000000);  // Max value + 1
//     testVectors[2] = tuple3(16'b0100001000111000, 16'b0100101100010001,32'b01001000000110111010010111100100);  // Overflow case
//     testVectors[3] = tuple3(16'b0100110000000011, 16'b0100111111110000,32'b01010001100011110101110000101001);  // Random values
//     testVectors[4] = tuple3(16'b0101000001101110, 16'b0100001011000101,32'b01001000110010101100000010000100);
//     testVectors[5] = tuple3(16'b0100010110100000, 16'b0101001100100100,32'b01010010011000110101001111111001);
//     testVectors[6] = tuple3(16'b0101000010000011, 16'b0100101100101110,32'b01001101010011001100110011001101);
//     testVectors[7] = tuple3(16'b0101001110110100, 16'b0011111001101101,32'b01001001010001001001101110100110);
//     testVectors[8] = tuple3(16'b0100101100001111, 16'b0100001001000101,32'b01001101010001001001101110100110);
//     testVectors[9] = tuple3(16'b0100010110111100, 16'b0100100110011110,32'b01001010011111011111001110110111);
    
//     // Rule to feed test vectors
//     rule feed_inputs (testState < 10);
//         let test = testVectors[testState];
//         let a = tpl_1(test);
//         let b = tpl_2(test);
//         let c = tpl_3(test);
//         let result = mac_inst.compute(a,b,c);
//         $display(" %d result: %b ", testState,result);
//         testState <= testState + 1;
//         if (testState == 9) begin
//             $display("All test cases completed");
//             $finish(0);
//         end

//     endrule
    
    // Rule to check results
    /*rule check_results;
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
*/

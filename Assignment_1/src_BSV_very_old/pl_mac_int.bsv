package pl_mac_int;
import cla_int32::*;
import pl_mul_8::*;
interface MAC_INT_ifc;
    // Interface definition for the ripple carry adder
    method Action start(Bit#(8) a, Bit#(8) b, Bit#(32) c);
    method ActionValue#(Bit#(32)) get_result();
endinterface

(* synthesize *)
module mkMAC_INT(MAC_INT_ifc);
    Pl_mul_8_ifc mul <- mkpl_mul8;
    Cla32_ifc add <- mkCla32Adder;

    rule feed_inputs;
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
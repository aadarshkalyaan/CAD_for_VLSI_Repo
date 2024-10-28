package adder16;

import cla_int8_without_start::*;  // Import the 8-bit CLA module

interface Adder16_ifc;
    method Action inputData(Bit#(16) a, Bit#(16) b);
    method Bit#(17) getResult();
    method Bool busy();
endinterface

(* synthesize *)
module mkAdder16(Adder16_ifc);
    // Registers for inputs, intermediate results and state
    Reg#(Bit#(16)) a_reg <- mkReg(0);
    Reg#(Bit#(16)) b_reg <- mkReg(0);
    Reg#(Bit#(17)) result_reg <- mkReg(0);
    Reg#(Bool) computing <- mkReg(False);
    Reg#(Bool) lower_done <- mkReg(False);
    Reg#(Bit#(1)) carry_reg <- mkReg(0);
    
    // Instantiate single 8-bit CLA module
    Cla_ifc cla8 <- mk_cla_add; 
    
    // Rule to compute lower 8 bits
    rule compute_lower (!lower_done && computing);
        // Add lower 8 bits
        let a_lower = a_reg[7:0];
        let b_lower = b_reg[7:0];
        let sum_lower = cla8.compute(a_lower, b_lower, 1'b0);
        
        // Store carry and lower result
        carry_reg <= sum_lower[8];
        result_reg[7:0] <= sum_lower[7:0];
        lower_done <= True;
    endrule
    
    // Rule to compute upper 8 bits
    rule compute_upper (lower_done && computing);
        // Add upper 8 bits using stored carry
        let a_upper = a_reg[15:8];
        let b_upper = b_reg[15:8];
        let sum_upper = cla8.compute(a_upper, b_upper, carry_reg);
        
        // Store final result
        result_reg[16:8] <= {sum_upper[8], sum_upper[7:0]};
        lower_done <= False;
        computing <= False;
    endrule
    
    // Interface methods
    method Action inputData(Bit#(16) a, Bit#(16) b) if (!computing);
        a_reg <= a;
        b_reg <= b;
        computing <= True;
    endmethod
    
    method Bit#(17) getResult() if (!computing);
        return result_reg;
    endmethod
    
    method Bool busy();
        return computing;
    endmethod
endmodule


endpackage
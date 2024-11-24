// package SystolicArray;

// import FIFO::*;
// import MAC_Wrapper::*;
// import Vector::*;
// import SpecialFIFOs::*;
// typedef enum {Init, LoadingA, LoadingB, LoadingS, Processing, DoneProcessing} State deriving (Bits, Eq, FShow);

// interface SystolicArray_IFC;
//     // Input methods for matrix elements
//     method Action input_A(Vector#(4, Vector#(4,Bit#(16))) a_col);
//     method Action input_B(Vector#(4, Vector#(4,Bit#(16))) b_col);
//     method Action initialise;
//     method Action input_S(Bit#(1) s);
    
//     // Output methods
//     method ActionValue#(Vector#(4, Vector#(4, Bit#(32)))) get_result;
// endinterface
// (* synthesize *)
// module mkSystolicArray(SystolicArray_IFC);
    
//     MAC_Wrapper_IFC mac_array_00 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_01 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_02 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_03 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_10 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_11 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_12 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_13 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_20 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_21 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_22 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_23 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_30 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_31 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_32 <- mkMAC_Wrapper;
//     MAC_Wrapper_IFC mac_array_33 <- mkMAC_Wrapper;
//     FIFO#(Bit#(32)) result_fifo_0 <- mkFIFO;
//     FIFO#(Bit#(32)) result_fifo_1 <- mkFIFO;
//     FIFO#(Bit#(32)) result_fifo_2 <- mkFIFO;
//     FIFO#(Bit#(32)) result_fifo_3 <- mkFIFO;
//     FIFO#(Bit#(16)) a_fifo_0 <- mkFIFO;
//     FIFO#(Bit#(16)) a_fifo_1 <- mkFIFO;
//     FIFO#(Bit#(16)) a_fifo_2 <- mkFIFO;
//     FIFO#(Bit#(16)) a_fifo_3 <- mkFIFO;
//     Reg#(int) counter <- mkReg(30);
//     Reg#(State) state <- mkReg(Init);
//     Reg#(Bool) active <- mkReg(False);

//     // Rules for connecting MAC modules in the systolic array
//     rule pass_through(active && state == Processing);
//         mac_array_00.enqA(a_fifo_0.first);
//         mac_array_01.enqA(a_fifo_1.first);
//         mac_array_02.enqA(a_fifo_2.first);
//         mac_array_03.enqA(a_fifo_3.first);
//         a_fifo_0.deq;
//         a_fifo_1.deq;
//         a_fifo_2.deq;
//         a_fifo_3.deq;
        
//         // Row 0 propagation
//         let a2 <- mac_array_02.get_a_out; mac_array_03.enqA(a2);
//         let a1 <- mac_array_01.get_a_out; mac_array_02.enqA(a1);
//         let a0 <- mac_array_00.get_a_out; mac_array_01.enqA(a0);
        
//         // Row 1 propagation
//         let a5 <- mac_array_12.get_a_out; mac_array_13.enqA(a5);
//         let a4 <- mac_array_11.get_a_out; mac_array_12.enqA(a4);
//         let a3 <- mac_array_10.get_a_out; mac_array_11.enqA(a3);
        
//         // Row 2 propagation
//         let a8 <- mac_array_22.get_a_out; mac_array_23.enqA(a8);
//         let a7 <- mac_array_21.get_a_out; mac_array_22.enqA(a7);
//         let a6 <- mac_array_20.get_a_out; mac_array_21.enqA(a6);
        
//         // Row 3 propagation
//         let a11 <- mac_array_32.get_a_out; mac_array_33.enqA(a11);
//         let a10 <- mac_array_31.get_a_out; mac_array_32.enqA(a10);
//         let a9 <- mac_array_30.get_a_out; mac_array_31.enqA(a9);

//         // Column 0 MAC result propagation
//         let c2 <- mac_array_20.get_MAC_result; mac_array_30.enqC(c2);
//         let c1 <- mac_array_10.get_MAC_result; mac_array_20.enqC(c1);
//         let c0 <- mac_array_00.get_MAC_result; mac_array_10.enqC(c0);

//         // Column 1 MAC result propagation
//         let c5 <- mac_array_21.get_MAC_result; mac_array_31.enqC(c5);
//         let c4 <- mac_array_11.get_MAC_result; mac_array_21.enqC(c4);
//         let c3 <- mac_array_01.get_MAC_result; mac_array_11.enqC(c3);
        
//         // Column 2 MAC result propagation
//         let c8 <- mac_array_22.get_MAC_result; mac_array_32.enqC(c8);
//         let c7 <- mac_array_12.get_MAC_result; mac_array_22.enqC(c7);
//         let c6 <- mac_array_02.get_MAC_result; mac_array_12.enqC(c6);
        
//         // Column 3 MAC result propagation
//         let c11 <- mac_array_23.get_MAC_result; mac_array_33.enqC(c11);
//         let c10 <- mac_array_13.get_MAC_result; mac_array_23.enqC(c10);
//         let c9 <- mac_array_03.get_MAC_result; mac_array_13.enqC(c9);
        
//         // Collect MAC results from bottom row into result FIFOs
//         let r0 <- mac_array_30.get_MAC_result; result_fifo_0.enq(r0);
//         let r1 <- mac_array_31.get_MAC_result; result_fifo_1.enq(r1);
//         let r2 <- mac_array_32.get_MAC_result; result_fifo_2.enq(r2);
//         let r3 <- mac_array_33.get_MAC_result; result_fifo_3.enq(r3);
//         counter <= counter - 1;
//         if (counter == 0) state <= DoneProcessing;
//     endrule
//     // Input methods
//     method Action input_A(Vector#(4, Vector#(4,Bit#(16))) a_col) if (state == LoadingA);
//         for (int i = 0; i<4; i=i+1) begin
//             a_fifo_0.enq(a_col[i][0]);
//         end
//         for (int i = 0; i<5; i=i+1) begin
//             if (i==0)
//                 a_fifo_1.enq(0);
//             else
//                 a_fifo_1.enq(a_col[i-1][1]);
//         end
//         for (int i = 0; i<6; i=i+1) begin
//             if (i==0||i==1)
//                 a_fifo_2.enq(0);
//             else
//                 a_fifo_2.enq(a_col[i-2][2]);
//         end
//         for (int i = 0; i<7; i=i+1) begin
//             if (i==0||i==1||i==2)
//                 a_fifo_3.enq(0);
//             else
//                 a_fifo_3.enq(a_col[i-3][3]);
//         end
//         state <= Processing;
//     endmethod
    
//     method Action input_B(Vector#(4, Vector#(4,Bit#(16))) b_col) if (state == LoadingB);
//         mac_array_00.enqB(b_col[0][0]);
//         mac_array_10.enqB(b_col[1][0]);
//         mac_array_20.enqB(b_col[2][0]);
//         mac_array_30.enqB(b_col[3][0]);
//         mac_array_01.enqB(b_col[0][1]);
//         mac_array_11.enqB(b_col[1][1]);
//         mac_array_21.enqB(b_col[2][1]);
//         mac_array_31.enqB(b_col[3][1]);
//         mac_array_02.enqB(b_col[0][2]);
//         mac_array_12.enqB(b_col[1][2]);
//         mac_array_22.enqB(b_col[2][2]);
//         mac_array_32.enqB(b_col[3][2]);
//         mac_array_03.enqB(b_col[0][3]);
//         mac_array_13.enqB(b_col[1][3]);
//         mac_array_23.enqB(b_col[2][3]);
//         mac_array_33.enqB(b_col[3][3]);
//         state <= LoadingS;
//     endmethod
    
//     method Action initialise if (state == Init);
//         mac_array_00.enqC(0);
//         mac_array_10.enqC(0);
//         mac_array_20.enqC(0);
//         mac_array_30.enqC(0);
//         mac_array_01.enqC(0);
//         mac_array_11.enqC(0);
//         mac_array_21.enqC(0);
//         mac_array_31.enqC(0);
//         mac_array_02.enqC(0);
//         mac_array_12.enqC(0);
//         mac_array_22.enqC(0);
//         mac_array_32.enqC(0);
//         mac_array_03.enqC(0);
//         mac_array_13.enqC(0);
//         mac_array_23.enqC(0);
//         mac_array_33.enqC(0);
//         active <= True;
//         state <= LoadingB;
//     endmethod
    
//     method Action input_S(s) if (state == LoadingS);
//         mac_array_00.enqS(s);
//         mac_array_10.enqS(s);
//         mac_array_20.enqS(s);
//         mac_array_30.enqS(s);
//         mac_array_01.enqS(s);
//         mac_array_11.enqS(s);
//         mac_array_21.enqS(s);
//         mac_array_31.enqS(s);
//         mac_array_02.enqS(s);
//         mac_array_12.enqS(s);
//         mac_array_22.enqS(s);
//         mac_array_32.enqS(s);
//         mac_array_03.enqS(s);
//         mac_array_13.enqS(s);
//         mac_array_23.enqS(s);
//         mac_array_33.enqS(s);
//         state <= LoadingA;
//     endmethod
    
//     method ActionValue#(Vector#(4, Vector#(4, Bit#(32)))) get_result() if (state == DoneProcessing);
//         Vector#(4, Vector#(4, Bit#(32))) result;
//         for (Integer i = 0; i < 4; i = i + 1) begin
//             // Create a Vector by explicitly assigning each element
//             Vector#(4, Bit#(32)) row;
//             row[0] = result_fifo_0.first;
//             row[1] = result_fifo_1.first;
//             row[2] = result_fifo_2.first;
//             row[3] = result_fifo_3.first;
//             result[i] = row;
//             result_fifo_0.deq;
//             result_fifo_1.deq;
//             result_fifo_2.deq;
//             result_fifo_3.deq;
//         end
//         return result;
//     endmethod
// endmodule

// endpackage







package SystolicArray;

import FIFO::*;
import SpecialFIFOs::*;
import MAC_Wrapper::*;
import Vector::*;

// Interface for the 4x4 systolic array
interface SystolicArray_IFC;
    // Input methods for each column (4 columns)
    method Action enqA(Vector#(4, Bit#(16)) a_inputs);
    method Action enqB(Vector#(4, Bit#(16)) b_inputs);
    method Action enqS(Vector#(4, Bit#(1)) s_inputs);
    method Action enqC(Vector#(4, Bit#(32)) c_inputs);
    
    // Output methods for result collection
    method ActionValue#(Vector#(4, Bit#(32))) getMACResults();
    
    // Methods to get pass-through values (for debugging/verification)
    method ActionValue#(Vector#(4, Bit#(16))) getAOut();
    method ActionValue#(Vector#(4, Bit#(16))) getBOut();
    method ActionValue#(Vector#(4, Bit#(1))) getSOut();
endinterface

(* synthesize *)
module mkSystolicArray(SystolicArray_IFC);
    // Create a 4x4 array of MAC_Wrapper modules
    Vector#(4, Vector#(4, MAC_Wrapper_IFC)) mac_array <- replicateM(replicateM(mkMAC_Wrapper));
    
    // FIFOs for collecting outputs from the last row
    Vector#(4, FIFO#(Bit#(32))) result_fifos <- replicateM(mkPipelineFIFO);
    
    // FIFOs for pass-through values from the last row
    Vector#(4, FIFO#(Bit#(16))) a_out_fifos <- replicateM(mkPipelineFIFO);
    Vector#(4, FIFO#(Bit#(16))) b_out_fifos <- replicateM(mkPipelineFIFO);
    Vector#(4, FIFO#(Bit#(1))) s_out_fifos <- replicateM(mkPipelineFIFO);
    
    // Rules for connecting the MAC modules in systolic fashion
    for(Integer row = 0; row < 4; row = row + 1) begin
        for(Integer col = 0; col < 4; col = col + 1) begin
            // Forward connections within the array
            if (row < 3) begin
                // Connect A output to next row's A input
                rule connect_a_forward;
                    let a <- mac_array[row][col].get_a_out();
                    mac_array[row + 1][col].enqA(a);
                endrule
            end
            
            if (col < 3) begin
                // Connect B output to next column's B input
                rule connect_b_forward;
                    let b <- mac_array[row][col].get_b_out();
                    mac_array[row][col + 1].enqB(b);
                endrule
                
                // Connect S output to next column's S input
                rule connect_s_forward;
                    let s <- mac_array[row][col].get_s_out();
                    mac_array[row][col + 1].enqS(s);
                endrule
            end
            
            // Connect outputs from last row to output FIFOs
            if (row == 3) begin
                rule collect_outputs;
                    let mac_result <- mac_array[row][col].get_MAC_result();
                    let a_out <- mac_array[row][col].get_a_out();
                    let b_out <- mac_array[row][col].get_b_out();
                    let s_out <- mac_array[row][col].get_s_out();
                    
                    result_fifos[col].enq(mac_result);
                    a_out_fifos[col].enq(a_out);
                    b_out_fifos[col].enq(b_out);
                    s_out_fifos[col].enq(s_out);
                endrule
            end
        end
    end
    
    // Input methods
    method Action enqA(Vector#(4, Bit#(16)) a_inputs);
        // Feed A inputs to first row
        for(Integer col = 0; col < 4; col = col + 1) begin
            mac_array[0][col].enqA(a_inputs[col]);
        end
    endmethod
    
    method Action enqB(Vector#(4, Bit#(16)) b_inputs);
        // Feed B inputs to first column
        for(Integer row = 0; row < 4; row = row + 1) begin
            mac_array[row][0].enqB(b_inputs[row]);
        end
    endmethod
    
    method Action enqS(Vector#(4, Bit#(1)) s_inputs);
        // Feed S inputs to first column
        for(Integer row = 0; row < 4; row = row + 1) begin
            mac_array[row][0].enqS(s_inputs[row]);
        end
    endmethod
    
    method Action enqC(Vector#(4, Bit#(32)) c_inputs);
        // Feed C inputs to first column
        for(Integer row = 0; row < 4; row = row + 1) begin
            mac_array[row][0].enqC(c_inputs[row]);
        end
    endmethod
    
    // Output methods
    method ActionValue#(Vector#(4, Bit#(32))) getMACResults();
        Vector#(4, Bit#(32)) results;
        for(Integer i = 0; i < 4; i = i + 1) begin
            result_fifos[i].deq();
            results[i] = result_fifos[i].first();
        end
        return results;
    endmethod
    
    method ActionValue#(Vector#(4, Bit#(16))) getAOut();
        Vector#(4, Bit#(16)) a_outs;
        for(Integer i = 0; i < 4; i = i + 1) begin
            a_out_fifos[i].deq();
            a_outs[i] = a_out_fifos[i].first();
        end
        return a_outs;
    endmethod
    
    method ActionValue#(Vector#(4, Bit#(16))) getBOut();
        Vector#(4, Bit#(16)) b_outs;
        for(Integer i = 0; i < 4; i = i + 1) begin
            b_out_fifos[i].deq();
            b_outs[i] = b_out_fifos[i].first();
        end
        return b_outs;
    endmethod
    
    method ActionValue#(Vector#(4, Bit#(1))) getSOut();
        Vector#(4, Bit#(1)) s_outs;
        for(Integer i = 0; i < 4; i = i + 1) begin
            s_out_fifos[i].deq();
            s_outs[i] = s_out_fifos[i].first();
        end
        return s_outs;
    endmethod
endmodule

endpackage
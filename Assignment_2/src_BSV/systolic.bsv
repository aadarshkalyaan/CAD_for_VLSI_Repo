package SystolicArray;

import FIFO::*;
import SpecialFIFOs::*;
import MAC_Wrapper::*;
import Vector::*;
import RWire::*;

interface SystolicArray_IFC;
    method Action enqA(Vector#(4, Bit#(16)) a_inputs);
    method Action enqB(Vector#(4, Bit#(16)) b_inputs);
    method Action enqS(Vector#(4, Bit#(1)) s_inputs);
    method Action enqC(Vector#(4, Bit#(32)) c_inputs);
    method ActionValue#(Vector#(4, Bit#(32))) getMACResults();
    method ActionValue#(Vector#(4, Bit#(16))) getAOut();
    method ActionValue#(Vector#(4, Bit#(16))) getBOut();
    method ActionValue#(Vector#(4, Bit#(1))) getSOut();
endinterface

(* synthesize *)
module mkSystolicArray(SystolicArray_IFC);
    // Create a 4x4 array of MAC_Wrapper modules
    Vector#(4, Vector#(4, MAC_Wrapper_IFC)) mac_array <- replicateM(replicateM(mkMAC_Wrapper));
    
    // Output FIFOs for collecting final results
    Vector#(4, FIFO#(Bit#(32))) result_fifos <- replicateM(mkPipelineFIFO);
    Vector#(4, FIFO#(Bit#(16))) a_out_fifos <- replicateM(mkPipelineFIFO);
    Vector#(4, FIFO#(Bit#(16))) b_out_fifos <- replicateM(mkPipelineFIFO);
    Vector#(4, FIFO#(Bit#(1))) s_out_fifos <- replicateM(mkPipelineFIFO);
    
    // RWires for connecting MAC units
    Vector#(4, Vector#(3, RWire#(Bit#(16)))) a_wires <- replicateM(replicateM(mkRWire));
    Vector#(3, Vector#(4, RWire#(Bit#(16)))) b_wires <- replicateM(replicateM(mkRWire));
    Vector#(3, Vector#(4, RWire#(Bit#(1)))) s_wires <- replicateM(replicateM(mkRWire));
    
    // Rules for data propagation
    for(Integer row = 0; row < 4; row = row + 1) begin
        for(Integer col = 0; col < 4; col = col + 1) begin
            // Forward A values
            if (row < 3) begin
                (* fire_when_enabled, no_implicit_conditions *)
                rule forward_a;
                    let a <- mac_array[row][col].get_a_out();
                    a_wires[col][row].wset(a);
                endrule
                
                (* fire_when_enabled *)
                rule connect_a;
                    let maybe_a = a_wires[col][row].wget();
                    if (isValid(maybe_a)) begin
                        mac_array[row + 1][col].enqA(fromMaybe(?, maybe_a));
                    end
                endrule
            end
            
            // Forward B and S values
            if (col < 3) begin
                (* fire_when_enabled, no_implicit_conditions *)
                rule forward_b;
                    let b <- mac_array[row][col].get_b_out();
                    b_wires[row][col].wset(b);
                endrule
                
                (* fire_when_enabled, no_implicit_conditions *)
                rule forward_s;
                    let s <- mac_array[row][col].get_s_out();
                    s_wires[row][col].wset(s);
                endrule
                
                (* fire_when_enabled *)
                rule connect_b;
                    let maybe_b = b_wires[row][col].wget();
                    if (isValid(maybe_b)) begin
                        mac_array[row][col + 1].enqB(fromMaybe(?, maybe_b));
                    end
                endrule
                
                (* fire_when_enabled *)
                rule connect_s;
                    let maybe_s = s_wires[row][col].wget();
                    if (isValid(maybe_s)) begin
                        mac_array[row][col + 1].enqS(fromMaybe(?, maybe_s));
                    end
                endrule
            end
            
            // Collect outputs from last row
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
        for(Integer col = 0; col < 4; col = col + 1) begin
            mac_array[0][col].enqA(a_inputs[col]);
        end
    endmethod
    
    method Action enqB(Vector#(4, Bit#(16)) b_inputs);
        for(Integer row = 0; row < 4; row = row + 1) begin
            mac_array[row][0].enqB(b_inputs[row]);
        end
    endmethod
    
    method Action enqS(Vector#(4, Bit#(1)) s_inputs);
        for(Integer row = 0; row < 4; row = row + 1) begin
            mac_array[row][0].enqS(s_inputs[row]);
        end
    endmethod
    
    method Action enqC(Vector#(4, Bit#(32)) c_inputs);
        for(Integer row = 0; row < 4; row = row + 1) begin
            mac_array[row][0].enqC(c_inputs[row]);
        end
    endmethod
    
    method ActionValue#(Vector#(4, Bit#(32))) getMACResults();
        Vector#(4, Bit#(32)) results;
        for(Integer i = 0; i < 4; i = i + 1) begin
            results[i] = result_fifos[i].first();
            result_fifos[i].deq();
        end
        return results;
    endmethod
    
    method ActionValue#(Vector#(4, Bit#(16))) getAOut();
        Vector#(4, Bit#(16)) a_outs;
        for(Integer i = 0; i < 4; i = i + 1) begin
            a_outs[i] = a_out_fifos[i].first();
            a_out_fifos[i].deq();
        end
        return a_outs;
    endmethod
    
    method ActionValue#(Vector#(4, Bit#(16))) getBOut();
        Vector#(4, Bit#(16)) b_outs;
        for(Integer i = 0; i < 4; i = i + 1) begin
            b_outs[i] = b_out_fifos[i].first();
            b_out_fifos[i].deq();
        end
        return b_outs;
    endmethod
    
    method ActionValue#(Vector#(4, Bit#(1))) getSOut();
        Vector#(4, Bit#(1)) s_outs;
        for(Integer i = 0; i < 4; i = i + 1) begin
            s_outs[i] = s_out_fifos[i].first();
            s_out_fifos[i].deq();
        end
        return s_outs;
    endmethod
endmodule

endpackage
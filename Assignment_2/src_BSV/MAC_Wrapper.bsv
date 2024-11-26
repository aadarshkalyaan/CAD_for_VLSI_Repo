package MAC_Wrapper;
import FIFO::*;
import CAD_V1::*;
import SpecialFIFOs::*;

interface MAC_Wrapper_IFC;
    // Input methods
    method Action enqS(Bit#(1) s);
    method Action enqB(Bit#(16) b);
    method Action enqC(Bit#(32) c);
    method Action enqA(Bit#(16) a);
    
    // Pass-through output methods
    method ActionValue#(Bit#(16)) get_a_out();  
    
    // MAC computation output
    method ActionValue#(Bit#(32)) get_MAC_result();
endinterface

(* synthesize *)
module mkMAC_Wrapper(MAC_Wrapper_IFC);
    // Input FIFOs
    FIFO#(Bit#(32)) c_fifo <- mkPipelineFIFO;
    FIFO#(Bit#(16)) a_fifo <- mkPipelineFIFO;
    FIFO#(Bit#(1)) s_fifo <- mkPipelineFIFO;
    FIFO#(Bit#(16)) b_fifo <- mkPipelineFIFO;
    
    // Output FIFOs for pass-through
    FIFO#(Bit#(16)) a_out_fifo <- mkPipelineFIFO;
    // Output FIFO for MAC result
    FIFO#(Bit#(32)) mac_result_fifo <- mkPipelineFIFO;
    
    // Instantiate the MAC module
    TOP_IFC mac <- mkMAC();
    
    // Rule to handle pass-through and MAC computation
    
    rule process_inputs; //if(s_fifo.notEmpty && b_fifo.notEmpty && c_fifo.notEmpty && a_fifo.notEmpty);
        let s = s_fifo.first;
        let b = b_fifo.first;
        let c = c_fifo.first;
        let a = a_fifo.first;
        
        // Compute MAC result
        let mac_result = mac.get_MAC(a, b, c, s);
        
        // Enqueue to output FIFOs
        
        mac_result_fifo.enq(mac_result);
        
        // Dequeue from input FIFOs
        c_fifo.deq;
    endrule
    rule a_out;
        let a = a_fifo.first;
        a_out_fifo.enq(a);
        a_fifo.deq;
    endrule
    // Input methods
    method Action enqS(Bit#(1) s);
        // if(s_fifo.notEmpty()) begin
        //     s_fifo.deq;
        // end
        s_fifo.enq(s);
    endmethod
    
    method Action enqB(Bit#(16) b);
        // if(b_fifo.notEmpty()) begin
        //     b_fifo.deq;
        // end
        b_fifo.enq(b);
    endmethod
    
    method Action enqC(Bit#(32) c);// if(c_fifo.isEmpty) ;
        c_fifo.enq(c);
    endmethod
    
    method Action enqA(Bit#(16) a);// if(a_fifo.isEmpty);
        a_fifo.enq(a);
    endmethod
    
    // Pass-through output methods
    method ActionValue#(Bit#(16)) get_a_out();
        a_out_fifo.deq;
        return a_out_fifo.first;
    endmethod
    
    // MAC result output method
    method ActionValue#(Bit#(32)) get_MAC_result();
        mac_result_fifo.deq;
        return mac_result_fifo.first;
    endmethod
endmodule

endpackage
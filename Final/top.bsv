package top;
import mac_bf16::*;
import mac_int::*;
import FIFO::*;
import SpecialFIFOs::*;

interface Top_ifc:
    method Action start(Bit#(16) a, Bit#(16) b, Bit#(32) c, Bit#(1) s2);
    method ActionValue#(Bit#(32)) get_result();
endinterface

module mkTop (Top_ifc);
    // Instantiate the MAC modules
    Mac_bf16_ifc mac_bf16 <- mkMac_bf16;
    Mac_int_ifc mac_int32 <- mkMac_int;

    FIFO#(Bit#(65)) ififo <- mkPipelineFIFO();
    FIFO#(Bit#(32)) ofifo <- mkPipelineFIFO();
    
    
    // Stage 1: Process input selection
    rule r1;
        let x = ififo.first();
        if (x[0]==1) mac_bf16.start(x[64:49], x[48:33], x[32:1]);
        else begin
        ofifo.enq(mac_int32.compute(x[56:49], x[40:33], x[32:1]));
        ififo.deq;
        end
    endrule
    rule r2;
        ofifo.enq(mac_bf16.get_result());
        ififo.deq;
    endrule

    method Action start(Bit#(16) a, Bit#(16) b, Bit#(32) c, Bit#(1) s2);
        ififo.enq({a,b,c,s2});
    endmethod
    method ActionValue#(Bit#(32)) get_result();
        Bit#(32) rca_out = ofifo.first;
        ofifo.deq;
        return rca_out;
    endmethod
endmodule
endpackage
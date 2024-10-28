package mac_bf16;
import fp32Add::*;
import bf16_mul::*;
import FIFO::*;
import SpecialFIFOs::*;
//typedef enum {Idle,Multiplying,WaitMulResult,Adding,Done} State deriving (Bits, Eq);
    
interface MAC_BF16_ifc;
    method Action start(Bit#(16) a, Bit#(16) b, Bit#(32) c);
    method Bit#(32) get_result() ;
endinterface
(* synthesize *)
module mkMAC_BF16(MAC_BF16_ifc);
    Mul_BF16_ifc mul <- mkbf16_mul;
    FP32_Add_ifc add <- mkFP32Add;
    FIFO#(Bit#(32)) m_ififo <- mkPipelineFIFO();
    FIFO#(Bit#(32)) a_ififo <- mkPipelineFIFO();
    FIFO#(Bit#(32)) ofifo <- mkPipelineFIFO();
    
    rule r1;
        let inp = m_ififo.first();
        mul.start(inp[31:16],inp[15:0]);
        m_ififo.deq();
    endrule
    rule r2;
        let z <- mul.get_result;
        let c = a_ififo.first();
        add.start(z,c);
        a_ififo.deq();
    endrule
    rule r3;
        let x <- add.get_result;
        ofifo.enq(x);
    endrule
    method Action start(Bit#(16) a, Bit#(16) b, Bit#(32) c);
        m_ififo.enq({a,b})
        a_ififo.enq(c)
    endmethod
    method Bit#(32) get_result() if (state == Done);
        Bit#(32) out = ofifo.first();
        ofifo.deq();
        return out;
    endmethod
endmodule
endpackage
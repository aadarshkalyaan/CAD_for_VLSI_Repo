package pl_mac_int;
import FIFO::*;
import SpecialFIFOs::*;
import cla_int16::*;
import cla_int8_without_start::*;
interface MAC_INT_ifc;
    method Action start(Bit#(8) a, Bit#(8) b, Bit#(32) c);
    method ActionValue#(Bit#(33)) get_result(); //including overflow
endinterface
typedef struct {
  Bit#(8) val1;
  Bit#(16) val2;
  Bit#(16) res;
} StepFormat
deriving(Bits, Eq);
(* synthesize *)
module mkMAC_INT(MAC_INT_ifc);
 // Declare FIFO for the adder pipeline stages
 FIFO#(StepFormat) ififo <- mkPipelineFIFO();
 FIFO#(StepFormat) pfifo_1 <- mkPipelineFIFO();
 FIFO#(StepFormat) pfifo_2 <- mkPipelineFIFO();
 FIFO#(StepFormat) pfifo_3 <- mkPipelineFIFO();
 FIFO#(StepFormat) pfifo_4 <- mkPipelineFIFO();
 FIFO#(StepFormat) pfifo_5 <- mkPipelineFIFO();
 FIFO#(StepFormat) pfifo_6 <- mkPipelineFIFO();
 FIFO#(StepFormat) pfifo_7 <- mkPipelineFIFO();
 FIFO#(StepFormat) ofifo <- mkPipelineFIFO();
 
 FIFO#(Bit#(32)) add_ififo <- mkPipelineFIFO();
 FIFO#(Bit#(33)) add_pfifo_1 <- mkPipelineFIFO();
 FIFO#(Bit#(33)) add_ofifo <- mkPipelineFIFO();

 Cla16_ifc cla16_0 <- mkCla16Adder; 
 Cla16_ifc cla16_1 <- mkCla16Adder; 
 Cla16_ifc cla16_2 <- mkCla16Adder; 
 Cla16_ifc cla16_3 <- mkCla16Adder; 
 Cla16_ifc cla16_4 <- mkCla16Adder; 
 Cla16_ifc cla16_5 <- mkCla16Adder; 
 Cla16_ifc cla16_6 <- mkCla16Adder; 
 Cla16_ifc cla16_7 <- mkCla16Adder; 
 Cla16_ifc cla16_8 <- mkCla16Adder; 
 Cla16_ifc cla16_9 <- mkCla16Adder; 
 // Rule for adder pipeline stage-1
 rule rl_pipe_stage1;
   StepFormat inp_stage1 = ififo.first();
   Bit#(8) a = inp_stage1.val1;
   Bit#(16) b = inp_stage1.val2;
   Bit#(16) r = inp_stage1.res;
   Bit#(16) psum = inp_stage1.res;
   if (a[0]==1) begin
       psum = cla16_0.compute(b,r,1'b0)[15:0];
   end
   StepFormat out_stage1;
   out_stage1.val1 = inp_stage1.val1>>1;
   out_stage1.val2 = inp_stage1.val2<<1;
   out_stage1.res  = psum;

   ififo.deq();
   pfifo_1.enq(out_stage1);
 endrule : rl_pipe_stage1

 rule rl_pipe_stage2;
   StepFormat inp_stage1 = pfifo_1.first();
   Bit#(8) a = inp_stage1.val1;
   Bit#(16) b = inp_stage1.val2;
   Bit#(16) r = inp_stage1.res;
   Bit#(16) psum = inp_stage1.res;
   if (a[0]==1) begin
       psum = cla16_1.compute(b,r,1'b0)[15:0];
   end
   StepFormat out_stage1;
   out_stage1.val1 = inp_stage1.val1>>1;
   out_stage1.val2 = inp_stage1.val2<<1;
   out_stage1.res  = psum;

   pfifo_1.deq();
   pfifo_2.enq(out_stage1);
 endrule : rl_pipe_stage2

 rule rl_pipe_stage3;
   StepFormat inp_stage1 = pfifo_2.first();
   Bit#(8) a = inp_stage1.val1;
   Bit#(16) b = inp_stage1.val2;
   Bit#(16) r = inp_stage1.res;
   Bit#(16) psum = inp_stage1.res;
   if (a[0]==1) begin
       psum = cla16_2.compute(b,r,1'b0)[15:0];
   end
   StepFormat out_stage1;
   out_stage1.val1 = inp_stage1.val1>>1;
   out_stage1.val2 = inp_stage1.val2<<1;
   out_stage1.res = psum;

   pfifo_2.deq();
   pfifo_3.enq(out_stage1);
 endrule : rl_pipe_stage3

 rule rl_pipe_stage4;
   StepFormat inp_stage1 = pfifo_3.first();
   Bit#(8) a = inp_stage1.val1;
   Bit#(16) b = inp_stage1.val2;
   Bit#(16) r = inp_stage1.res;
   Bit#(16) psum = inp_stage1.res;
   if (a[0]==1) begin
       psum = cla16_3.compute(b,r,1'b0)[15:0];
   end
   StepFormat out_stage1;
   out_stage1.val1 = inp_stage1.val1>>1;
   out_stage1.val2 = inp_stage1.val2<<1;
   out_stage1.res  = psum;

   pfifo_3.deq();
   pfifo_4.enq(out_stage1);
 endrule : rl_pipe_stage4

 rule rl_pipe_stage5;
   StepFormat inp_stage1 = pfifo_4.first();
   Bit#(8) a = inp_stage1.val1;
   Bit#(16) b = inp_stage1.val2;
   Bit#(16) r = inp_stage1.res;
   Bit#(16) psum = inp_stage1.res;
   if (a[0]==1) begin
       psum = cla16_4.compute(b,r,1'b0)[15:0];
   end
   StepFormat out_stage1;
   out_stage1.val1 = inp_stage1.val1>>1;
   out_stage1.val2 = inp_stage1.val2<<1;
   out_stage1.res  = psum;

   pfifo_4.deq();
   pfifo_5.enq(out_stage1);
 endrule : rl_pipe_stage5

 rule rl_pipe_stage6;
   StepFormat inp_stage1 = pfifo_5.first();
   Bit#(8) a = inp_stage1.val1;
   Bit#(16) b = inp_stage1.val2;
   Bit#(16) r = inp_stage1.res;
   Bit#(16) psum = inp_stage1.res;
   if (a[0]==1) begin
       psum = cla16_5.compute(b,r,1'b0)[15:0];
   end
   StepFormat out_stage1;
   out_stage1.val1 = inp_stage1.val1>>1;
   out_stage1.val2 = inp_stage1.val2<<1;
   out_stage1.res  = psum;

   pfifo_5.deq();
   pfifo_6.enq(out_stage1);
 endrule : rl_pipe_stage2

 rule rl_pipe_stage7;
   StepFormat inp_stage1 = pfifo_6.first();
   Bit#(8) a = inp_stage1.val1;
   Bit#(16) b = inp_stage1.val2;
   Bit#(16) r = inp_stage1.res;
   Bit#(16) psum = inp_stage1.res;
   if (a[0]==1) begin
       psum = cla16_6.compute(b,r,1'b0)[15:0];
   end
   StepFormat out_stage1;
   out_stage1.val1 = inp_stage1.val1>>1;
   out_stage1.val2 = inp_stage1.val2<<1;
   out_stage1.res  = psum;

   pfifo_6.deq();
   pfifo_7.enq(out_stage1);
 endrule : rl_pipe_stage7

 rule rl_pipe_stage8;
   StepFormat inp_stage1 = pfifo_7.first();
   Bit#(8) a = inp_stage1.val1;
   Bit#(16) b = inp_stage1.val2;
   Bit#(16) r = inp_stage1.res;
   Bit#(16) psum = inp_stage1.res;
   if (a[0]==1) begin
       psum = cla16_7.compute(b,r,1'b0)[15:0];
   end
   StepFormat out_stage1;
   out_stage1.val1 = inp_stage1.val1>>1;
   out_stage1.val2 = inp_stage1.val2<<1;
   out_stage1.res  = psum;

   pfifo_7.deq();
   ofifo.enq(out_stage1);
 endrule : rl_pipe_stage8

 rule rl_pipe_stage9;
    StepFormat inp_stage1 = ofifo.first();
    Bit#(32) a = add_ififo.first();
    Bit#(16) r = inp_stage1.res;
    Bit#(17) p = cla16_8.compute(r,a[15:0],1'b0);
    add_ififo.deq()
    ofifo.deq();
    add_pfifo_1.enq({a[31:16],p}); //33 bits
  endrule : rl_pipe_stage9

rule rl_pipe_stage10;
    Bit#(33) a = add_pfifo_1.first();
    Bit#(17) fres = signExtend(a[32:17]);
    if (a[16]==1)  fres = cla16_9.compute(a[32:17],8'b0,1'b1);
    add_pfifo_1.deq()
    add_ofifo.enq({fres,a[15:0]});
  endrule : rl_pipe_stage10



 method Action start(Bit#(8) a, Bit#(8) b, Bit#(32) c);
    StepFormat inp;
    inp.val1 = a;
    inp.val2 = {8'b0,b};
    inp.res  = 16'b0;
    ififo.enq(inp);
    add_ififo.enq(c)
endmethod : start

method ActionValue#(Bit#(33)) get_result();
    Bit#(33) out = add_ofifo.first();
    add_ofifo.deq();
    return out;
endmethod 

    
endmodule
endmodule
endpackage
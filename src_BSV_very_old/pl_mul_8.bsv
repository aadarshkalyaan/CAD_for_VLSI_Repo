package pl_mul_8;

/******************
 * Package imports
 ******************/
import FIFO::*;
import SpecialFIFOs::*;
import cla_int16::*;
/************************
 * Structs and Interface
 ************************/
// Struct for adder input type
typedef struct {
  Bit#(8) val1;
  Bit#(16) val2;
  Bit#(16) res;
} StepFormat
deriving(Bits, Eq);

// Interface definition for the ripple carry adder
interface Pl_mul_8_ifc;
  method Action start(Bit#(8) a, Bit#(8) b);
  method ActionValue#(Bit#(16)) get_result();
endinterface

/*******************************************
 * Module definition for ripple carry adder
 *******************************************/
(* synthesize *)
module mkpl_mul8(Pl_mul_8_ifc);
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
  
  Cla16_ifc cla16_0 <- mkCla16Adder; 
  Cla16_ifc cla16_1 <- mkCla16Adder; 
  Cla16_ifc cla16_2 <- mkCla16Adder; 
  Cla16_ifc cla16_3 <- mkCla16Adder; 
  Cla16_ifc cla16_4 <- mkCla16Adder; 
  Cla16_ifc cla16_5 <- mkCla16Adder; 
  Cla16_ifc cla16_6 <- mkCla16Adder; 
  Cla16_ifc cla16_7 <- mkCla16Adder; 
  Cla16_ifc cla16_8 <- mkCla16Adder; 
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
  endrule : rl_pipe_stage6

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

  // Define the adder interface methods
  method Action start(Bit#(8) a, Bit#(8) b);
    StepFormat inp;
    inp.val1 = a;
    inp.val2 = {8'b0,b};
    inp.res  = 16'b0;
    ififo.enq(inp);
  endmethod : start

  method ActionValue#(Bit#(16)) get_result();
    StepFormat out = ofifo.first();
    ofifo.deq();
    return out.res;
  endmethod : get_result
endmodule

endpackage

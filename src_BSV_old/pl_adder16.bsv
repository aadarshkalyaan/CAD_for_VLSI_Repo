package pl_adder16;

/******************
 * Package imports
 ******************/
import FIFO::*;
import SpecialFIFOs::*;
import cla_int8_without_start::*;
/************************
 * Structs and Interface
 ************************/
// Struct for adder input type
typedef struct {
  Bit#(16) val1;
  Bit#(16) val2;
} AdderInput
deriving(Bits, Eq);

// Struct for the intermediate pipe stage
typedef struct {
  Bit#(8) val1;
  Bit#(8) val2;
  Bit#(9) sum;
} AdderPipeStage
deriving(Bits, Eq);

// Struct for adder output type
typedef struct {
  Bit#(1)  overflow;
  Bit#(16) sum;
} AdderResult
deriving(Bits, Eq);

// Interface definition for the ripple carry adder
interface Pl_adder16_ifc;
  method Action start(AdderInput inp);
  method ActionValue#(AdderResult) get_result();
endinterface

/*******************************************
 * Module definition for ripple carry adder
 *******************************************/
(* synthesize *)
module mkpl_adder16(Pl_adder16_ifc);
  // Declare FIFO for the adder pipeline stages
  FIFO#(AdderInput)     adder_ififo <- mkPipelineFIFO();
  FIFO#(AdderPipeStage) adder_pfifo <- mkPipelineFIFO();
  FIFO#(AdderResult)    adder_ofifo <- mkPipelineFIFO();
  
  Cla_ifc cla8_1 <- mk_cla_add; 
  Cla_ifc cla8_2 <- mk_cla_add; 
  // Rule for adder pipeline stage-1
  rule rl_pipe_stage1;
    AdderInput inp_stage1 = adder_ififo.first();
    Bit#(8)   inp_val1   = inp_stage1.val1[7:0];
    Bit#(8)   inp_val2   = inp_stage1.val2[7:0];
    Bit#(1)    cin        = 1'b0;
    Bit#(9)   psum       = cla8_1.compute(inp_val1, inp_val2, cin);

    AdderPipeStage out_stage1;
    out_stage1.val1 = inp_stage1.val1[15:8];
    out_stage1.val2 = inp_stage1.val2[15:8];
    out_stage1.sum  = psum;

    adder_ififo.deq();
    adder_pfifo.enq(out_stage1);
  endrule : rl_pipe_stage1

  // Rule for adder pipeline stage-2
  rule rl_pipe_stage2;
    AdderPipeStage inp_stage2 = adder_pfifo.first();
    Bit#(8)       inp_val1   = inp_stage2.val1;
    Bit#(8)       inp_val2   = inp_stage2.val2;
    Bit#(9)       psum_lsbs  = inp_stage2.sum;
    Bit#(1)        cin        = psum_lsbs[8];
    Bit#(9)       psum_msbs  = cla8_2.compute(inp_val1, inp_val2, cin);

    AdderResult out_stage2;
    out_stage2.overflow = psum_msbs[8];
    out_stage2.sum      = {psum_msbs[7:0], psum_lsbs[7:0]};

    adder_pfifo.deq();
    adder_ofifo.enq(out_stage2);
  endrule : rl_pipe_stage2

  // Define the adder interface methods
  method Action start(AdderInput inp);
    adder_ififo.enq(inp);
  endmethod : start

  method ActionValue#(AdderResult) get_result();
    AdderResult out = adder_ofifo.first();
    adder_ofifo.deq();
    return out;
  endmethod : get_result
endmodule

endpackage

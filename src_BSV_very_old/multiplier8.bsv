package multiplier8;
import FIFO         :: *;
import SpecialFIFOs :: *;
import cla_int16 ::*;
import two_comp ::*;

import DReg ::*;
  typedef struct{
    Bit#(16) a;
    Bit#(16) r;
  } AdderInput deriving(Bits, Eq);

  typedef struct{
    Bit#(16) r;
  } AdderOutput deriving(Bits, Eq);
  typedef struct{
    Bit#(8) a;
    Bit#(8) b;
  } MulInput deriving(Bits, Eq);
  typedef struct{
    Bit#(16) r;
  } MulOutput deriving(Bits, Eq);
// Module to multiply two 8-bit signed integers using shift-and-add
interface Multi_ifc;
    method Action start(Bit#(8) a, Bit#(8) b);
    method ActionValue#(MulOutput) get_result();
endinterface : Multi_ifc
(*synthesize*)
module mkMultiplier (Multi_ifc);
    FIFO#(MulOutput) ff_mul_out <- mkSizedFIFO(1);
    
    Reg#(Bit#(1)) sign <- mkReg(0);
    Reg#(Bit#(16)) multiplicand <- mkReg(0);   // 8-bit signed multiplicand
    Reg#(Bit#(8)) multiplier   <- mkReg(8'hF0);   // 8-bit signed multiplier
    Reg#(Bit#(16)) result     <- mkReg(0);

    Cla16_ifc cla0_16 <- mkCla16Adder;
    Tc_ifc tc1 <- mkTc;
    Tc_ifc tc2 <- mkTc;
    Tc_ifc tc3 <- mkTc;
    function MulInput tc(Bit#(8) a, Bit#(8) b);
        if (a[7]==1) begin
            let x = tc1.tc(signExtend(a));
            a = x[7:0];
        end
        if (b[7]==1) begin
            let x = tc2.tc(signExtend(b));
            b = x[7:0];
        end
        return MulInput{
            a: a,
            b: b
            };
    endfunction
    rule cycle_add (multiplier[0]==1); // * algorithm
      result <= cla0_16.compute(result,multiplicand, 1'b0)[15:0];
      multiplicand <= multiplicand << 1;
      multiplier <= multiplier >> 1;
    endrule: cycle_add
    rule cycle_shift (multiplier!=0 && multiplier[0]==0);
      multiplicand <= multiplicand << 1;
      multiplier <= multiplier >> 1;
    endrule: cycle_shift
    rule done (multiplier == 0); // output msg when done
      if (sign==1'b1) begin
        let x = tc3.tc(signExtend(result));
        $display("%b %d",sign,x[15:0]);
        ff_mul_out.enq(MulOutput{r:x[15:0]});
      end
      else ff_mul_out.enq(MulOutput{r:result});
      
    endrule: done
    method Action start (Bit#(8) a, Bit#(8) b);
        sign <= (a[7]^b[7]); 
        let x =tc(a,b);
        multiplicand<={8'b0,x.a};
        multiplier<=x.b;
        //ff_mul_inp.enq(tc(a,b));
    endmethod : start

    method ActionValue#(MulOutput) get_result();
      MulOutput rca_out = ff_mul_out.first;
      ff_mul_out.deq;
      return rca_out;
    endmethod : get_result
    endmodule
endpackage
    /*(*descending_urgency="r3,r2,r5"*)

    FIFO#(AdderInput)  ff_add_inp <- mkSizedFIFO(1);
    FIFO#(AdderOutput) ff_add_out <- mkSizedFIFO(1);
    FIFO#(MulInput)  ff_mul_inp <- mkSizedFIFO(1);
    /*rule r1;
        multiplicand<={8'b0,ff_mul_inp.first.a};
        multiplier<=ff_mul_inp.first.b;
        ff_mul_inp.deq;
        $display("r1 %b %b %b",multiplicand, multiplier, result);

    endrule

    rule r2 if(!(multiplier==8'b0)); //FIFO add_inp empty 
        if (multiplier[0]==1) begin
            ff_add_inp.enq(       
                AdderInput{
                a: multiplicand,
                r: result
              }
            );
        end
        multiplicand<=multiplicand<<1;
        multiplier<=multiplier>>1;
        $display("r2 %b %b %b",multiplicand, multiplier, result);
    endrule
    rule r3;//FF add_inp not empty and out is empty
        AdderInput i = ff_add_inp.first;
        AdderOutput o = AdderOutput{
          r: cla0_16.compute(i.a, i.r, 1'b0)[15:0]
        };
        ff_add_out.enq(o);
        result<=o.r;
        ff_add_inp.deq();
        $display("r3 %b %b %b %b %b",multiplicand, multiplier, result,o,i);
    endrule

    /*rule r4;
        result<=ff_add_out.first.r;
        ff_add_out.deq;
        ff_add_inp.deq;
        $display("r4 %b %b %b",multiplicand, multiplier, result);
    endrule
    rule r5 if(multiplier==8'b0);
        if (sign==1) begin
            let x = tc3.tc(signExtend(result));
            result <= x[15:0];
        end
        ff_mul_out.enq(MulOutput{r:result});
        $display("r5 %b %b %b",multiplicand, multiplier, result);
    endrule*/
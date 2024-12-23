package bf16_mul;
import cla_int8_without_start ::*;
import int8_unsigned_multiplier ::*;
import FIFO::*;
import SpecialFIFOs::*;
typedef struct{
    Bit#(1) sign;
    Bit#(8) exp;
    Bit#(7) mant;
  } BF16 deriving(Bits, Eq);
typedef struct{
    Bit#(1) sign;
    Bit#(8) exp;
    Bit#(23) mant;
  } FP32 deriving(Bits, Eq);
typedef struct{
    BF16 a;
    BF16 b;
} MulInput deriving(Bits,Eq);
interface Mul_BF16_ifc;
    method Action start(Bit#(16) a, Bit#(16) b);
    method ActionValue#(Bit#(32)) get_result();
endinterface

(* synthesize *)
module mkbf16_mul(Mul_BF16_ifc);
    FIFO#(MulInput) ififo <- mkPipelineFIFO();
    FIFO#(FP32) ofifo <- mkPipelineFIFO();

    Multi_ifc mul0 <- mkMultiplier;
    Cla_ifc cla0 <- mk_cla_add;  // Lowest 8 bits
    Cla_ifc cla1 <- mk_cla_add;
    Cla_ifc cla2 <- mk_cla_add;
    Cla_ifc cla3 <- mk_cla_add;
    Cla_ifc cla4 <- mk_cla_add;

    function Bit#(23) normalise(Bit#(17) z);
        let p = z;
        if (z[16]==1) p = p>>1;
        Bit#(15) mantissa = {p[14:0]}; //Holds oveflow also
        return {mantissa,8'b0};
    endfunction
    rule r1;
        MulInput inp= ififo.first();
        Bit#(16) z = mul0.compute({1'b1,inp.a.mant},{1'b1,inp.b.mant});
        Bit#(23) m = normalise({z,1'b0});
        Bit#(8) x = cla0.compute(inp.a.exp,8'h81,1'b0)[7:0];
        Bit#(8) y = cla1.compute(inp.b.exp,8'h81,1'b0)[7:0]; 
        Bit#(8) exp; 
        if (z[15]==1) begin
             exp = cla2.compute(x,y,1'b1)[7:0];
        end
        else exp = cla3.compute(x,y,1'b0)[7:0];
            
        if (exp[7]==1) $display("Underflow Improper inputs, Answer is not valid");
        Bit#(9) x1;
        x1 = cla4.compute(exp,8'h7F,1'b0);
        if (x1[8]==1) $display("Overflow Improper inputs, Answer is not valid");
        FP32 out;
        out.sign = (inp.a.sign^inp.b.sign);
        out.exp = x1[7:0];
        out.mant = m;
        ififo.deq();
        ofifo.enq(out);
    endrule

    method Action start (Bit#(16) a, Bit#(16) b);
        BF16 inp1;
        BF16 inp2;
        inp1.sign=a[15];
        inp1.exp=a[14:7];
        inp1.mant=a[6:0];
        inp2.sign=b[15];
        inp2.exp=b[14:7];
        inp2.mant=b[6:0];
        ififo.enq(MulInput{a:inp1,b:inp2});
    endmethod : start

    method ActionValue#(Bit#(32)) get_result(); //copy this
      FP32 rca_out = ofifo.first;
      ofifo.deq;
      return pack(rca_out);
    endmethod : get_result
endmodule
endpackage
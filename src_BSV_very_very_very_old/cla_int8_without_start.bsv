package cla_int8_without_start;
import DReg ::*;
typedef struct{
   Bit#(1) overflow;
   Bit#(8) sum;
} Output_Cla deriving(Bits,Eq);
interface Cla_ifc;
/* Load the values of A, B, and C */
   method Bit#(9) compute (Bit#(8) a, Bit#(8) b, Bit#(1) cin);
endinterface
(* synthesize *)
module mk_cla_add(Cla_ifc);
   method Bit#(9) compute (Bit#(8) a, Bit#(8) b, Bit#(1) cin);
       let gen = a & b;    // Generate a carry if both a and b are 1
       let propagate = a ^ b; 
       let carry = {
         gen[6] | (propagate[6] & (gen[5] | (propagate[5] & (gen[4] | (propagate[4] & (gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin))))))))))))),
         gen[5] | (propagate[5] & (gen[4] | (propagate[4] & (gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin))))))))))),
         gen[4] | (propagate[4] & (gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin))))))))),
         gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin))))))),
         gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin))))),
         gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin))),
         gen[0] | (propagate[0] & cin),
         cin
       };
       return {
         gen[7] | (propagate[7] & (gen[6] | (propagate[6] & (gen[5] | (propagate[5] & (gen[4] | (propagate[4] & (gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin))))))))))))))),
         propagate ^ carry};
   endmethod
endmodule
endpackage



package cla_int8;
import DReg ::*;
typedef struct{
   Bit#(1) overflow;
   Bit#(8) sum;
} Output_Cla deriving(Bits,Eq);
interface Cla_ifc;
/* Load the values of A, B, and C */
   method Action start(Bit#(8) a, Bit#(8) b, Bit#(1) c);
   method Output_Cla get_result();
endinterface
(* synthesize *)
module mk_cla_add(Cla_ifc);
/* Registers to store the input values*/
       Reg#(Bit#(8)) reg_A <- mkReg(0);    /* A will be used as int8 (lower 8 bits) or bf16*/
       Reg#(Bit#(8)) reg_B <- mkReg(0);    /* B will be used as int8 (lower 8 bits) or bf16*/
       Reg#(Bit#(1)) reg_C <- mkReg(0);
       Reg#(Bit#(9)) reg_sum <- mkReg(3);   /* MAC result for S1*/
       Reg#(Bool)    rg_inp_valid <- mkDReg(False);
       Reg#(Bool)    rg_out_valid  <- mkDReg(False);


       function Bit #(9) addCLA8(Bit #(8) a, Bit #(8) b, Bit #(1) cin);//, Bit #(1) result_carry);
         Bit #(8) gen;   // Carry generate (Gi)
         Bit #(8) propagate;  // Carry propagate (Pi)
         Bit #(8) carry = 0;      // Carry for each bit
         Bit #(8) sum;        // Sum output
         Bit #(1) result_carry;
         // Calculate generate (Gi) and propagate (Pi)
         gen = a & b;    // Generate a carry if both a and b are 1
         propagate = a ^ b;   // Propagate a carry if either a or b is 1
         
         // Compute carries for each bit
         carry[0] = cin;                    // The input carry for the 1st bit is the external carry input
         carry[1] = gen[0] | (propagate[0] & cin);
         carry[2] = gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin)));
         carry[3] = gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin)))));
         carry[4] = gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin)))))));
         carry[5] = gen[4] | (propagate[4] & (gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin)))))))));
         carry[6] = gen[5] | (propagate[5] & (gen[4] | (propagate[4] & (gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin)))))))))));
         carry[7] = gen[6] | (propagate[6] & (gen[5] | (propagate[5] & (gen[4] | (propagate[4] & (gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin)))))))))))));
         result_carry = gen[7] | (propagate[7] & (gen[6] | (propagate[6] & (gen[5] | (propagate[5] & (gen[4] | (propagate[4] & (gen[3] | (propagate[3] & (gen[2] | (propagate[2] & (gen[1] | (propagate[1] & (gen[0] | (propagate[0] & cin)))))))))))))));
         
         // Compute the sum for each bit
         sum = propagate ^ carry;
         
         return {result_carry,sum};
         
      endfunction
      rule result if(rg_inp_valid);
         let result_int32 = addCLA8(reg_A, reg_B, reg_C);// + reg_C;
         reg_sum <= result_int32;
         rg_out_valid <= True;        
      endrule
      method Action start (Bit#(8) a, Bit#(8) b, Bit#(1) c);
	   reg_A <= a;
	   reg_B <= b;
      reg_C <= c;
      rg_inp_valid <= True;
      endmethod : start
      method Output_Cla get_result() if(rg_out_valid);
         Output_Cla out;
         out.overflow = reg_sum[8];
         out.sum = reg_sum[7:0];
	     return out;
      //return extend((rg_out_valid? 1'b1: 1'b0));
      endmethod : get_result


endmodule
endpackage



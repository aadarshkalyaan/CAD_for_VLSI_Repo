package cla_int32;
import cla_int8_without_start::*;
import DReg::*;

// Interface for 32-bit adder
interface Cla32_ifc;
      method Bit#(33) compute(Bit#(32) a, Bit#(32) b, Bit#(1) cin);   // Start method with two 32-bit operands and carry-in
endinterface

(*synthesize*)
module mkCla32Adder(Cla32_ifc);
      // Instantiate four 8-bit CLA adders
      //Vector#(4, MyModule#(Bit#(8))) aModules <- replicateM(mk_cla_add);
      Cla_ifc cla0 <- mk_cla_add;  // Lowest 8 bits
      Cla_ifc cla1 <- mk_cla_add;  // Next 8 bits
      Cla_ifc cla2 <- mk_cla_add;  // Next 8 bits
      Cla_ifc cla3 <- mk_cla_add;  // Highest 8 bits
      // Register to store the result
      function loop_add (Bit#(32)a, Bit#(32) b, Bit#(1) cin); 
         Bit#(32) result = 0;
         Bit#(1) temp = cin;
         for (Integer i = 0; i<4 ; i= i+1) begin
            Bit#(9) z = 0;
            case (i)
            0 : z = cla0.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            1 : z = cla1.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            2 : z = cla2.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            3 : z = cla3.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            endcase
            result[8*i + 7:8*i] = z[7:0];
            temp = z[8];
         end
         return {temp,result};
      endfunction
      method Bit#(33) compute(Bit#(32) a, Bit#(32) b, Bit#(1) cin);
         
         return loop_add (a,b,cin);
      endmethod
endmodule
endpackage

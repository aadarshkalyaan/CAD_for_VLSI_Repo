package cla48;
import cla8::*;

// Interface for 32-bit adder
interface Cla48_ifc;
      method Bit#(49) compute(Bit#(48) a, Bit#(48) b, Bit#(1) cin);   // Start method with two 32-bit operands and carry-in
endinterface

(*synthesize*)
module mkCla48(Cla48_ifc);
      // Instantiate four 8-bit CLA adders
      //Vector#(4, MyModule#(Bit#(8))) aModules <- replicateM(mk_cla_add);
      Cla8_ifc cla0 <- mkCla8;  // Lowest 8 bits
      Cla8_ifc cla1 <- mkCla8;  // Next 8 bits
      Cla8_ifc cla2 <- mkCla8;  // Next 8 bits
      Cla8_ifc cla3 <- mkCla8;  // Highest 8 bits
      Cla8_ifc cla4 <- mkCla8; 
      Cla8_ifc cla5 <- mkCla8; 
      // Register to store the result
      function loop_add (Bit#(48)a, Bit#(48) b, Bit#(1) cin); 
         Bit#(48) result = 0;
         Bit#(1) temp = cin;
         for (Integer i = 0; i<6 ; i= i+1) begin
            Bit#(9) z = 0;
            case (i)
            0 : z = cla0.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            1 : z = cla1.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            2 : z = cla2.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            3 : z = cla3.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            4 : z = cla4.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            5 : z = cla5.compute(a[8*i + 7:8*i],b[8*i + 7:8*i],temp);
            endcase
            result[8*i + 7:8*i] = z[7:0];
            temp = z[8];
         end
         return {temp,result};
      endfunction
      method Bit#(49) compute(Bit#(48) a, Bit#(48) b, Bit#(1) cin);
         
         return loop_add (a,b,cin);
      endmethod
endmodule
endpackage
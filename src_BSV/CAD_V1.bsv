package CAD_V1;
import mac_int::*;
import mac_bf16 ::*;
interface TOP_IFC;
   method Bit#(32) get_MAC(Bit#(16) a, Bit#(16) b, Bit#(32) c, Bit#(1) s);
endinterface
(* synthesize *)
module mkMAC(TOP_IFC);

      /* Registers to hold the result   /* MAC result for S1*/
   Reg#(Bit#(32)) reg_MAC_fp32 <- mkReg(0);    /* MAC result for S2*/
   MAC_INT_ifc mac_int_inst <- mkMAC_INT;
   MAC_BF16_ifc mac_bf16_inst <- mkMAC_BF16;

          /* Method to get the MAC result (32-bit output)*/
          method Bit#(32) get_MAC(Bit#(16) a, Bit#(16) b, Bit#(32) c, Bit#(1) s);
             if (s==1)  /* Return fp32 MAC result in S2 mode*/
                    return mac_bf16_inst.compute(a,b,c);
             else  /* Return int32 MAC result in S1 mode*/
                    return mac_int_inst.compute(a[7:0],b[7:0],c);
       endmethod
endmodule
endpackage
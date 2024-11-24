package CAD_V1;
import mac_int::*;
import mac_bf16 ::*;
typedef enum {Idle,Int8,BF16,Calculating,Done}State deriving (Bits, Eq,FShow);
interface TOP_IFC;
       method Action start_MAC(Bit#(16) a, Bit#(16) b, Bit#(32) c, Bit#(1) s);
       method Bit#(32) get_MAC();
endinterface
(* synthesize *)
module mkMAC(TOP_IFC);
       Reg#(Bit#(32)) reg_MAC <- mkReg(0);    /* MAC result for S2*/
       MAC_INT_ifc mac_int_inst <- mkMAC_INT;
       MAC_BF16_ifc mac_bf16_inst <- mkMAC_BF16;
       Reg#(Bit#(1)) reg_s1_or_s2 <- mkReg(0);
       Reg#(Bit#(16)) reg_a <- mkReg(0);
       Reg#(Bit#(16)) reg_b <- mkReg(0);
       Reg#(Bit#(32)) reg_c <- mkReg(0);
       Reg#(State) state1 <- mkReg(Idle);
          /* Method to get the MAC result (32-bit output)*/
       rule r1 (state1 == Int8);
              let x=mac_int_inst.compute(reg_a[7:0],reg_b[7:0],reg_c);
              reg_MAC<=x;
              state1 <= Done;
              $display("r1", fshow(state1));
              $display("a %b", reg_a[7:0]);
              $display("b %b", reg_b[7:0]);
              $display("c %b", reg_c);
              $display("MAC %b", x);
              
       endrule
       rule r2 (state1 == BF16);
              state1 <= Calculating;
              mac_bf16_inst.start(reg_a,reg_b,reg_c);
              $display("r2 ", fshow(state1));
       endrule
       rule r3 (state1 == Calculating);
              reg_MAC <= mac_bf16_inst.get_result;
              state1 <= Done;
              $display("r3 ", fshow(state1));
       endrule
       method Action start_MAC(Bit#(16) a, Bit#(16) b, Bit#(32) c, Bit#(1) s) if (state1 == Idle);
              reg_s1_or_s2 <= s;
              reg_a <= a;
              reg_b <= b;
              reg_c <= c;
              if (s==0) state1 <= Int8;
              else state1 <= BF16;
       endmethod
       method Bit#(32) get_MAC() if (state1==Done);
              return reg_MAC;
       endmethod
endmodule
endpackage
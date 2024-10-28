package mult;
import two_comp::*;
import DReg::*;
interface Mul_ifc;
    method Action init(Bit#(8) x,Bit#(8) y);
    method Bit#(16) get_result();
endinterface
(* synthesize *)
module mkmul(Mul_ifc);
    Tc_ifc tc <- mkTc;
    Reg#(Bit#(16)) a <- mkReg(0);
    Reg#(Bit#(8)) m <- mkReg(0);
    Reg#(Bool) inp_v <- mkReg(False);
    Reg#(Bit#(16)) result <- mkReg(0);
    rule r1 (inp_v && m[0]==1 && m!=8'b0);
        let p = result+a;
        result<=p;
        a<= a<<1;
        m<= m>>1;
    endrule
    rule r2 (inp_v && m[0]==0 && m!=8'b0);
        a<= a<<1;
        m<= m>>1;
    endrule

    method Action init(Bit#(8) x,Bit#(8) y);
        a <= {8'b0,x};
        m <= y;
        inp_v<=True;
    endmethod
    method Bit#(16) get_result() if (m==8'b0);
        return result[15:0];
    endmethod
endmodule
endpackage
/*
package Tb;
(* synthesize *)
module mkTb(Empty);
    mul_ifc bm<- mkmul;
    rule r;
        bm.init(8'h02,8'h04);
    rule r1;
        let x <- bm.get_result;
        $display ("%b",x);
        $finish;
    endrule
endmodule
endpackage
*/
package booth_multiplier;
import two_comp::*;
import DReg::*;
interface Boo_ifc;
    method Action init(Bit#(8) x,Bit#(8) y);
    method Bit#(16) get_result();
endinterface
(* synthesize *)
module mkboo(Boo_ifc);
    Tc_ifc tc <- mkTc;
    Reg#(Bit#(8)) a <- mkReg(0);
    Reg#(Bit#(9)) q <- mkReg(0);
    Reg#(Bit#(8)) m <- mkReg(0);
    Reg#(Bit#(8)) mc <- mkReg(0);
    Reg#(Bool) inp_v <- mkReg(False);
    Reg#(Int#(4)) n <- mkReg(4'd8);
    Reg#(Bit#(17)) result <- mkReg(0);
    //(*descending_urgency = "r1 , r2 , r3"*)
    rule r1 (inp_v && (q[1:0]==2'b10));
        a<=a+mc;
        result <= ({a, q} >> 1);
        n<=n-1;
    endrule

    rule r2 (inp_v && (q[1:0]==2'b01));
        a<=a+m;
        result <= ({a, q} >> 1);
        n<=n-1;
    endrule
    
    rule r3(inp_v);
        result <= ({a, q} >> 1);
        n<=n-1;
    endrule
    


    method Action init(Bit#(8) x,Bit#(8) y);
        q <= {x,1'b0};
        m <= y;
        let y1 <- tc.tc(y);
        mc <= y1;
        inp_v<=True;
        result<={a,x,1'b0};
    endmethod
    method Bit#(16) get_result() if (n==0);
        return result[15:0];
    endmethod
endmodule
endpackage
/*
package Tb;
(* synthesize *)
module mkTb(Empty);
    boo_ifc bm<- mkboo;
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
package SystolicArray;

import FIFO::*;
import MAC_Wrapper::*;
import Vector::*;
import SpecialFIFOs::*;

typedef enum {Init, LoadingA, LoadingB, LoadingS, Processing, DoneProcessing} State deriving (Bits, Eq, FShow);

interface SystolicArray_IFC;
    // Input methods for matrix elements
    method Action input_A(Vector#(4,Vector#(4,Bit#(16))) a_col);
    method Action input_B(Vector#(4,Vector#(4,Bit#(16))) b_col);
    method Action input_S(Bit#(1) s);
    
    // Output methods
    method ActionValue#(Vector#(4,Vector#(4,Bit#(32)))) get_result();
endinterface
(* synthesize *)
module mkSystolicArray(SystolicArray_IFC);
    
    MAC_Wrapper_IFC mac_array_00 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_01 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_02 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_03 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_10 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_11 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_12 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_13 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_20 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_21 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_22 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_23 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_30 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_31 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_32 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_33 <- mkMAC_Wrapper;
    
    Vector#(4, Reg#(Bit#(16))) r1 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(16))) r2 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(16))) r3 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(16))) r0 <- replicateM(mkReg(0));

    Vector#(4, Reg#(Bit#(32))) o1 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(32))) o2 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(32))) o3 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(32))) o0 <- replicateM(mkReg(0));


    Reg#(UInt#(3)) cycle <- mkReg(0);
    Reg#(UInt#(3)) cycle_o <- mkReg(0);
    // Rules for connecting MAC modules in the systolic array

    rule transformMatrix;
        case (cycle)
            0: begin // First out clock cycle
                mac_array_00.enqA(r0[0]);
                cycle <= cycle + 1;
            end
            
            1: begin // Second clock cycle
                mac_array_00.enqA(r1[0]);
                mac_array_10.enqA(r0[1]);
                cycle <= cycle + 1;
            end
            
            2: begin // Third clock cycle
                mac_array_00.enqA(r2[0]);
                mac_array_10.enqA(r1[1]);
                mac_array_20.enqA(r0[2]);
                cycle <= cycle + 1;
            end
            
            3: begin // Fourth clock cycle
                mac_array_00.enqA(r3[0]);
                mac_array_10.enqA(r2[1]);
                mac_array_20.enqA(r1[2]);
                mac_array_30.enqA(r0[3]);
                cycle <= cycle + 1;
            end
            4: begin // fifth clock cycle
                mac_array_10.enqA(r3[1]);
                mac_array_20.enqA(r2[2]);
                mac_array_30.enqA(r1[3]);
                cycle <= cycle + 1;
            end
            
            5: begin // sixth clock cycle
                mac_array_20.enqA(r3[2]);
                mac_array_30.enqA(r2[3]);
                cycle <= cycle + 1;
            end
            
            6: begin // seventh clock cycle
                mac_array_30.enqA(r3[3]);
                cycle <= cycle + 1;
            end
        endcase
    endrule
        
    rule m00; // once A is enqued C is always 0 so start
        mac_array_00.enqC(32'b0);
    endrule
    rule m01;
        mac_array_01.enqC(32'b0);
        let x <- mac_array_00.get_a_out();
        mac_array_01.enqA(x);
    endrule
    rule m02;
        mac_array_02.enqC(32'b0);
        let x <- mac_array_01.get_a_out();
        mac_array_02.enqA(x);
    endrule
    rule m03;
        mac_array_03.enqC(32'b0);
        let x <- mac_array_02.get_a_out();
        mac_array_03.enqA(x);
    endrule
    rule m10;
        let x <- mac_array_00.get_MAC_result();
        mac_array_10.enqC(x);
    endrule
    rule m11;
        let x <- mac_array_01.get_MAC_result();
        let y <- mac_array_10.get_a_out();
        mac_array_11.enqC(x);
        mac_array_11.enqA(y);
    endrule
    rule m12;
        let x <- mac_array_02.get_MAC_result();
        let y <- mac_array_11.get_a_out();
        mac_array_12.enqC(x);
        mac_array_12.enqA(y);
    endrule
    rule m13;
        let x <- mac_array_03.get_MAC_result();
        let y <- mac_array_12.get_a_out();
        mac_array_13.enqC(x);
        mac_array_13.enqA(y);
    endrule
    rule m20;
        let x <- mac_array_10.get_MAC_result();
        mac_array_20.enqC(x);
    endrule
    rule m21;
        let x <- mac_array_11.get_MAC_result();
        let y <- mac_array_20.get_a_out();
        mac_array_21.enqC(x);
        mac_array_21.enqA(y);
    endrule
    rule m22;
        let x <- mac_array_12.get_MAC_result();
        let y <- mac_array_21.get_a_out();
        mac_array_22.enqC(x);
        mac_array_22.enqA(y);
    endrule
    rule m23;
        let x <- mac_array_13.get_MAC_result();
        let y <- mac_array_22.get_a_out();
        mac_array_23.enqC(x);
        mac_array_23.enqA(y);
    endrule
    rule m30;
        let x <- mac_array_20.get_MAC_result();
        mac_array_30.enqC(x);
    endrule
    rule m31;
        let x <- mac_array_21.get_MAC_result();
        let y <- mac_array_30.get_a_out();
        mac_array_31.enqC(x);
        mac_array_31.enqA(y);
    endrule
    rule m32;
        let x <- mac_array_22.get_MAC_result();
        let y <- mac_array_31.get_a_out();
        mac_array_32.enqC(x);
        mac_array_32.enqA(y);
    endrule
    rule m33;
        let x <- mac_array_23.get_MAC_result();
        let y <- mac_array_32.get_a_out();
        mac_array_33.enqC(x);
        mac_array_33.enqA(y);
    endrule

    rule transformOutput;
        case (cycle_o)
            0: begin // First clock cycle
                let x <- mac_array_30.get_MAC_result();
                o0[0]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            1: begin // Second clock cycle
                let x <- mac_array_31.get_MAC_result();
                let y <- mac_array_30.get_MAC_result();
                o1[0]<= y;
                o0[1]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            2: begin // Third clock cycle
                let x <- mac_array_32.get_MAC_result();
                let y <- mac_array_31.get_MAC_result();
                let z <- mac_array_30.get_MAC_result();
                o2[0]<= z;
                o1[1]<= y;
                o0[2]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            3: begin // Fourth clock cycle
                let x <- mac_array_33.get_MAC_result();
                let y <- mac_array_32.get_MAC_result();
                let z <- mac_array_31.get_MAC_result();
                let w <- mac_array_30.get_MAC_result();
                o3[0]<= w;
                o2[1]<= x;
                o1[2]<= y;
                o0[3]<= z;
                cycle_o <= cycle_o + 1;
            end
            4: begin // fifth clock cycle
                let x <- mac_array_33.get_MAC_result();
                let y <- mac_array_32.get_MAC_result();
                let z <- mac_array_31.get_MAC_result();
                o3[1]<= z;
                o2[2]<= y;
                o1[3]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            5: begin // sixth clock cycle
                let x <- mac_array_33.get_MAC_result();
                let y <- mac_array_32.get_MAC_result();
                o3[2]<= y;
                o2[3]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            6: begin // seventh clock cycle
                let x <- mac_array_33.get_MAC_result();
                o3[3]<= x;
                cycle_o <= cycle_o + 1;
            end
        endcase
    endrule
//Last layer for result

    // Input methods
    method Action input_A(Vector#(4, Vector#(4, Bit#(16))) a_col);
        for (Integer i = 0; i < 4; i = i + 1) begin
            r0[i] <= a_col[0][i];
            r1[i] <= a_col[1][i];
            r2[i] <= a_col[2][i];
            r3[i] <= a_col[3][i];
        end
    endmethod
    
    method Action input_B(Vector#(4,Vector#(4,Bit#(16))) b_col);
        mac_array_00.enqB(b_col[0][0]);
        mac_array_10.enqB(b_col[1][0]);
        mac_array_20.enqB(b_col[2][0]);
        mac_array_30.enqB(b_col[3][0]);
        mac_array_01.enqB(b_col[0][1]);
        mac_array_11.enqB(b_col[1][1]);
        mac_array_21.enqB(b_col[2][1]);
        mac_array_31.enqB(b_col[3][1]);
        mac_array_02.enqB(b_col[0][2]);
        mac_array_12.enqB(b_col[1][2]);
        mac_array_22.enqB(b_col[2][2]);
        mac_array_32.enqB(b_col[3][2]);
        mac_array_03.enqB(b_col[0][3]);
        mac_array_13.enqB(b_col[1][3]);
        mac_array_23.enqB(b_col[2][3]);
        mac_array_33.enqB(b_col[3][3]);
    endmethod

    
    method Action input_S(Bit#(1) s);
        mac_array_00.enqS(s);
        mac_array_10.enqS(s);
        mac_array_20.enqS(s);
        mac_array_30.enqS(s);
        mac_array_01.enqS(s);
        mac_array_11.enqS(s);
        mac_array_21.enqS(s);
        mac_array_31.enqS(s);
        mac_array_02.enqS(s);
        mac_array_12.enqS(s);
        mac_array_22.enqS(s);
        mac_array_32.enqS(s);
        mac_array_03.enqS(s);
        mac_array_13.enqS(s);
        mac_array_23.enqS(s);
        mac_array_33.enqS(s);
    endmethod
    
    method ActionValue#(Vector#(4,Vector#(4,Bit#(32)))) get_result() if(cycle_o==7);
        Vector#(4, Vector#(4, Bit#(32))) result;
        result[0]=map(readReg, o0);
        result[1]=map(readReg, o1);
        result[2]=map(readReg, o2);
        result[3]=map(readReg, o3);
        return result;
    endmethod
endmodule

endpackage

package SystolicArray;

import FIFO::*;
import MAC_Wrapper::*;
import Vector::*;
import SpecialFIFOs::*;

typedef enum {Init, LoadingA, LoadingB, LoadingS, Processing, DoneProcessing} State deriving (Bits, Eq, FShow);

interface SystolicArray_IFC;
    // Input methods for matrix elements
    method Action input_A(Vector#(4,Vector#(4,Bit#(16))) a_col);
    method Action input_B(Vector#(4,Vector#(4,Bit#(16))) b_col);
    method Action input_S(Bit#(1) s);
    
    // Output methods
    method ActionValue#(Vector#(4,Vector#(4,Bit#(32)))) get_result();
endinterface
(* synthesize *)
module mkSystolicArray(SystolicArray_IFC);
    
    MAC_Wrapper_IFC mac_array_00 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_01 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_02 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_03 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_10 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_11 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_12 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_13 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_20 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_21 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_22 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_23 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_30 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_31 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_32 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_33 <- mkMAC_Wrapper;
    
    Vector#(4, Reg#(Bit#(16))) r1 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(16))) r2 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(16))) r3 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(16))) r0 <- replicateM(mkReg(0));

    Vector#(4, Reg#(Bit#(32))) o1 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(32))) o2 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(32))) o3 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(32))) o0 <- replicateM(mkReg(0));


    Reg#(UInt#(3)) cycle <- mkReg(0);
    Reg#(UInt#(3)) cycle_o <- mkReg(0);
    // Rules for connecting MAC modules in the systolic array

    rule transformMatrix;
        case (cycle)
            0: begin // First out clock cycle
                mac_array_00.enqA(r0[0]);
                cycle <= cycle + 1;
            end
            
            1: begin // Second clock cycle
                mac_array_00.enqA(r1[0]);
                mac_array_10.enqA(r0[1]);
                cycle <= cycle + 1;
            end
            
            2: begin // Third clock cycle
                mac_array_00.enqA(r2[0]);
                mac_array_10.enqA(r1[1]);
                mac_array_20.enqA(r0[2]);
                cycle <= cycle + 1;
            end
            
            3: begin // Fourth clock cycle
                mac_array_00.enqA(r3[0]);
                mac_array_10.enqA(r2[1]);
                mac_array_20.enqA(r1[2]);
                mac_array_30.enqA(r0[3]);
                cycle <= cycle + 1;
            end
            4: begin // fifth clock cycle
                mac_array_10.enqA(r3[1]);
                mac_array_20.enqA(r2[2]);
                mac_array_30.enqA(r1[3]);
                cycle <= cycle + 1;
            end
            
            5: begin // sixth clock cycle
                mac_array_20.enqA(r3[2]);
                mac_array_30.enqA(r2[3]);
                cycle <= cycle + 1;
            end
            
            6: begin // seventh clock cycle
                mac_array_30.enqA(r3[3]);
                cycle <= cycle + 1;
            end
        endcase
    endrule
        
    rule m00; // once A is enqued C is always 0 so start
        mac_array_00.enqC(32'b0);
    endrule
    rule m01;
        mac_array_01.enqC(32'b0);
        let x <- mac_array_00.get_a_out();
        mac_array_01.enqA(x);
    endrule
    rule m02;
        mac_array_02.enqC(32'b0);
        let x <- mac_array_01.get_a_out();
        mac_array_02.enqA(x);
    endrule
    rule m03;
        mac_array_03.enqC(32'b0);
        let x <- mac_array_02.get_a_out();
        mac_array_03.enqA(x);
    endrule
    rule m10;
        let x <- mac_array_00.get_MAC_result();
        mac_array_10.enqC(x);
    endrule
    rule m11;
        let x <- mac_array_01.get_MAC_result();
        let y <- mac_array_10.get_a_out();
        mac_array_11.enqC(x);
        mac_array_11.enqA(y);
    endrule
    rule m12;
        let x <- mac_array_02.get_MAC_result();
        let y <- mac_array_11.get_a_out();
        mac_array_12.enqC(x);
        mac_array_12.enqA(y);
    endrule
    rule m13;
        let x <- mac_array_03.get_MAC_result();
        let y <- mac_array_12.get_a_out();
        mac_array_13.enqC(x);
        mac_array_13.enqA(y);
    endrule
    rule m20;
        let x <- mac_array_10.get_MAC_result();
        mac_array_20.enqC(x);
    endrule
    rule m21;
        let x <- mac_array_11.get_MAC_result();
        let y <- mac_array_20.get_a_out();
        mac_array_21.enqC(x);
        mac_array_21.enqA(y);
    endrule
    rule m22;
        let x <- mac_array_12.get_MAC_result();
        let y <- mac_array_21.get_a_out();
        mac_array_22.enqC(x);
        mac_array_22.enqA(y);
    endrule
    rule m23;
        let x <- mac_array_13.get_MAC_result();
        let y <- mac_array_22.get_a_out();
        mac_array_23.enqC(x);
        mac_array_23.enqA(y);
    endrule
    rule m30;
        let x <- mac_array_20.get_MAC_result();
        mac_array_30.enqC(x);
    endrule
    rule m31;
        let x <- mac_array_21.get_MAC_result();
        let y <- mac_array_30.get_a_out();
        mac_array_31.enqC(x);
        mac_array_31.enqA(y);
    endrule
    rule m32;
        let x <- mac_array_22.get_MAC_result();
        let y <- mac_array_31.get_a_out();
        mac_array_32.enqC(x);
        mac_array_32.enqA(y);
    endrule
    rule m33;
        let x <- mac_array_23.get_MAC_result();
        let y <- mac_array_32.get_a_out();
        mac_array_33.enqC(x);
        mac_array_33.enqA(y);
    endrule

    rule transformOutput;
        case (cycle_o)
            0: begin // First clock cycle
                let x <- mac_array_30.get_MAC_result();
                o0[0]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            1: begin // Second clock cycle
                let x <- mac_array_31.get_MAC_result();
                let y <- mac_array_30.get_MAC_result();
                o1[0]<= y;
                o0[1]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            2: begin // Third clock cycle
                let x <- mac_array_32.get_MAC_result();
                let y <- mac_array_31.get_MAC_result();
                let z <- mac_array_30.get_MAC_result();
                o2[0]<= z;
                o1[1]<= y;
                o0[2]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            3: begin // Fourth clock cycle
                let x <- mac_array_33.get_MAC_result();
                let y <- mac_array_32.get_MAC_result();
                let z <- mac_array_31.get_MAC_result();
                let w <- mac_array_30.get_MAC_result();
                o3[0]<= w;
                o2[1]<= x;
                o1[2]<= y;
                o0[3]<= z;
                cycle_o <= cycle_o + 1;
            end
            4: begin // fifth clock cycle
                let x <- mac_array_33.get_MAC_result();
                let y <- mac_array_32.get_MAC_result();
                let z <- mac_array_31.get_MAC_result();
                o3[1]<= z;
                o2[2]<= y;
                o1[3]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            5: begin // sixth clock cycle
                let x <- mac_array_33.get_MAC_result();
                let y <- mac_array_32.get_MAC_result();
                o3[2]<= y;
                o2[3]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            6: begin // seventh clock cycle
                let x <- mac_array_33.get_MAC_result();
                o3[3]<= x;
                cycle_o <= cycle_o + 1;
            end
        endcase
    endrule
//Last layer for result

    // Input methods
    method Action input_A(Vector#(4, Vector#(4, Bit#(16))) a_col);
        for (Integer i = 0; i < 4; i = i + 1) begin
            r0[i] <= a_col[0][i];
            r1[i] <= a_col[1][i];
            r2[i] <= a_col[2][i];
            r3[i] <= a_col[3][i];
        end
    endmethod
    
    method Action input_B(Vector#(4,Vector#(4,Bit#(16))) b_col);
        mac_array_00.enqB(b_col[0][0]);
        mac_array_10.enqB(b_col[1][0]);
        mac_array_20.enqB(b_col[2][0]);
        mac_array_30.enqB(b_col[3][0]);
        mac_array_01.enqB(b_col[0][1]);
        mac_array_11.enqB(b_col[1][1]);
        mac_array_21.enqB(b_col[2][1]);
        mac_array_31.enqB(b_col[3][1]);
        mac_array_02.enqB(b_col[0][2]);
        mac_array_12.enqB(b_col[1][2]);
        mac_array_22.enqB(b_col[2][2]);
        mac_array_32.enqB(b_col[3][2]);
        mac_array_03.enqB(b_col[0][3]);
        mac_array_13.enqB(b_col[1][3]);
        mac_array_23.enqB(b_col[2][3]);
        mac_array_33.enqB(b_col[3][3]);
    endmethod

    
    method Action input_S(Bit#(1) s);
        mac_array_00.enqS(s);
        mac_array_10.enqS(s);
        mac_array_20.enqS(s);
        mac_array_30.enqS(s);
        mac_array_01.enqS(s);
        mac_array_11.enqS(s);
        mac_array_21.enqS(s);
        mac_array_31.enqS(s);
        mac_array_02.enqS(s);
        mac_array_12.enqS(s);
        mac_array_22.enqS(s);
        mac_array_32.enqS(s);
        mac_array_03.enqS(s);
        mac_array_13.enqS(s);
        mac_array_23.enqS(s);
        mac_array_33.enqS(s);
    endmethod
    
    method ActionValue#(Vector#(4,Vector#(4,Bit#(32)))) get_result() if(cycle_o==7);
        Vector#(4, Vector#(4, Bit#(32))) result;
        result[0]=map(readReg, o0);
        result[1]=map(readReg, o1);
        result[2]=map(readReg, o2);
        result[3]=map(readReg, o3);
        return result;
    endmethod
endmodule

endpackage

package SystolicArray;

import FIFO::*;
import MAC_Wrapper::*;
import Vector::*;
import SpecialFIFOs::*;

typedef enum {Init, LoadingA, LoadingB, LoadingS, Processing, DoneProcessing} State deriving (Bits, Eq, FShow);

interface SystolicArray_IFC;
    // Input methods for matrix elements
    method Action input_A(Vector#(4,Vector#(4,Bit#(16))) a_col);
    method Action input_B(Vector#(4,Vector#(4,Bit#(16))) b_col);
    method Action input_S(Bit#(1) s);
    
    // Output methods
    method ActionValue#(Vector#(4,Vector#(4,Bit#(32)))) get_result();
endinterface
(* synthesize *)
module mkSystolicArray(SystolicArray_IFC);
    
    MAC_Wrapper_IFC mac_array_00 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_01 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_02 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_03 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_10 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_11 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_12 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_13 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_20 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_21 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_22 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_23 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_30 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_31 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_32 <- mkMAC_Wrapper;
    MAC_Wrapper_IFC mac_array_33 <- mkMAC_Wrapper;
    
    Vector#(4, Reg#(Bit#(16))) r1 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(16))) r2 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(16))) r3 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(16))) r0 <- replicateM(mkReg(0));

    Vector#(4, Reg#(Bit#(32))) o1 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(32))) o2 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(32))) o3 <- replicateM(mkReg(0));
    Vector#(4, Reg#(Bit#(32))) o0 <- replicateM(mkReg(0));


    Reg#(UInt#(3)) cycle <- mkReg(0);
    Reg#(UInt#(3)) cycle_o <- mkReg(0);
    // Rules for connecting MAC modules in the systolic array

    rule transformMatrix;
        case (cycle)
            0: begin // First out clock cycle
                mac_array_00.enqA(r0[0]);
                cycle <= cycle + 1;
            end
            
            1: begin // Second clock cycle
                mac_array_00.enqA(r1[0]);
                mac_array_10.enqA(r0[1]);
                cycle <= cycle + 1;
            end
            
            2: begin // Third clock cycle
                mac_array_00.enqA(r2[0]);
                mac_array_10.enqA(r1[1]);
                mac_array_20.enqA(r0[2]);
                cycle <= cycle + 1;
            end
            
            3: begin // Fourth clock cycle
                mac_array_00.enqA(r3[0]);
                mac_array_10.enqA(r2[1]);
                mac_array_20.enqA(r1[2]);
                mac_array_30.enqA(r0[3]);
                cycle <= cycle + 1;
            end
            4: begin // fifth clock cycle
                mac_array_10.enqA(r3[1]);
                mac_array_20.enqA(r2[2]);
                mac_array_30.enqA(r1[3]);
                cycle <= cycle + 1;
            end
            
            5: begin // sixth clock cycle
                mac_array_20.enqA(r3[2]);
                mac_array_30.enqA(r2[3]);
                cycle <= cycle + 1;
            end
            
            6: begin // seventh clock cycle
                mac_array_30.enqA(r3[3]);
                cycle <= cycle + 1;
            end
        endcase
    endrule
        
    rule m00; // once A is enqued C is always 0 so start
        mac_array_00.enqC(32'b0);
    endrule
    rule m01;
        mac_array_01.enqC(32'b0);
        let x <- mac_array_00.get_a_out();
        mac_array_01.enqA(x);
    endrule
    rule m02;
        mac_array_02.enqC(32'b0);
        let x <- mac_array_01.get_a_out();
        mac_array_02.enqA(x);
    endrule
    rule m03;
        mac_array_03.enqC(32'b0);
        let x <- mac_array_02.get_a_out();
        mac_array_03.enqA(x);
    endrule
    rule m10;
        let x <- mac_array_00.get_MAC_result();
        mac_array_10.enqC(x);
    endrule
    rule m11;
        let x <- mac_array_01.get_MAC_result();
        let y <- mac_array_10.get_a_out();
        mac_array_11.enqC(x);
        mac_array_11.enqA(y);
    endrule
    rule m12;
        let x <- mac_array_02.get_MAC_result();
        let y <- mac_array_11.get_a_out();
        mac_array_12.enqC(x);
        mac_array_12.enqA(y);
    endrule
    rule m13;
        let x <- mac_array_03.get_MAC_result();
        let y <- mac_array_12.get_a_out();
        mac_array_13.enqC(x);
        mac_array_13.enqA(y);
    endrule
    rule m20;
        let x <- mac_array_10.get_MAC_result();
        mac_array_20.enqC(x);
    endrule
    rule m21;
        let x <- mac_array_11.get_MAC_result();
        let y <- mac_array_20.get_a_out();
        mac_array_21.enqC(x);
        mac_array_21.enqA(y);
    endrule
    rule m22;
        let x <- mac_array_12.get_MAC_result();
        let y <- mac_array_21.get_a_out();
        mac_array_22.enqC(x);
        mac_array_22.enqA(y);
    endrule
    rule m23;
        let x <- mac_array_13.get_MAC_result();
        let y <- mac_array_22.get_a_out();
        mac_array_23.enqC(x);
        mac_array_23.enqA(y);
    endrule
    rule m30;
        let x <- mac_array_20.get_MAC_result();
        mac_array_30.enqC(x);
    endrule
    rule m31;
        let x <- mac_array_21.get_MAC_result();
        let y <- mac_array_30.get_a_out();
        mac_array_31.enqC(x);
        mac_array_31.enqA(y);
    endrule
    rule m32;
        let x <- mac_array_22.get_MAC_result();
        let y <- mac_array_31.get_a_out();
        mac_array_32.enqC(x);
        mac_array_32.enqA(y);
    endrule
    rule m33;
        let x <- mac_array_23.get_MAC_result();
        let y <- mac_array_32.get_a_out();
        mac_array_33.enqC(x);
        mac_array_33.enqA(y);
    endrule

    rule transformOutput;
        case (cycle_o)
            0: begin // First clock cycle
                let x <- mac_array_30.get_MAC_result();
                o0[0]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            1: begin // Second clock cycle
                let x <- mac_array_31.get_MAC_result();
                let y <- mac_array_30.get_MAC_result();
                o1[0]<= y;
                o0[1]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            2: begin // Third clock cycle
                let x <- mac_array_32.get_MAC_result();
                let y <- mac_array_31.get_MAC_result();
                let z <- mac_array_30.get_MAC_result();
                o2[0]<= z;
                o1[1]<= y;
                o0[2]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            3: begin // Fourth clock cycle
                let x <- mac_array_33.get_MAC_result();
                let y <- mac_array_32.get_MAC_result();
                let z <- mac_array_31.get_MAC_result();
                let w <- mac_array_30.get_MAC_result();
                o3[0]<= w;
                o2[1]<= x;
                o1[2]<= y;
                o0[3]<= z;
                cycle_o <= cycle_o + 1;
            end
            4: begin // fifth clock cycle
                let x <- mac_array_33.get_MAC_result();
                let y <- mac_array_32.get_MAC_result();
                let z <- mac_array_31.get_MAC_result();
                o3[1]<= z;
                o2[2]<= y;
                o1[3]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            5: begin // sixth clock cycle
                let x <- mac_array_33.get_MAC_result();
                let y <- mac_array_32.get_MAC_result();
                o3[2]<= y;
                o2[3]<= x;
                cycle_o <= cycle_o + 1;
            end
            
            6: begin // seventh clock cycle
                let x <- mac_array_33.get_MAC_result();
                o3[3]<= x;
                cycle_o <= cycle_o + 1;
            end
        endcase
    endrule
//Last layer for result

    // Input methods
    method Action input_A(Vector#(4, Vector#(4, Bit#(16))) a_col);
        for (Integer i = 0; i < 4; i = i + 1) begin
            r0[i] <= a_col[0][i];
            r1[i] <= a_col[1][i];
            r2[i] <= a_col[2][i];
            r3[i] <= a_col[3][i];
        end
    endmethod
    
    method Action input_B(Vector#(4,Vector#(4,Bit#(16))) b_col);
        mac_array_00.enqB(b_col[0][0]);
        mac_array_10.enqB(b_col[1][0]);
        mac_array_20.enqB(b_col[2][0]);
        mac_array_30.enqB(b_col[3][0]);
        mac_array_01.enqB(b_col[0][1]);
        mac_array_11.enqB(b_col[1][1]);
        mac_array_21.enqB(b_col[2][1]);
        mac_array_31.enqB(b_col[3][1]);
        mac_array_02.enqB(b_col[0][2]);
        mac_array_12.enqB(b_col[1][2]);
        mac_array_22.enqB(b_col[2][2]);
        mac_array_32.enqB(b_col[3][2]);
        mac_array_03.enqB(b_col[0][3]);
        mac_array_13.enqB(b_col[1][3]);
        mac_array_23.enqB(b_col[2][3]);
        mac_array_33.enqB(b_col[3][3]);
    endmethod

    
    method Action input_S(Bit#(1) s);
        mac_array_00.enqS(s);
        mac_array_10.enqS(s);
        mac_array_20.enqS(s);
        mac_array_30.enqS(s);
        mac_array_01.enqS(s);
        mac_array_11.enqS(s);
        mac_array_21.enqS(s);
        mac_array_31.enqS(s);
        mac_array_02.enqS(s);
        mac_array_12.enqS(s);
        mac_array_22.enqS(s);
        mac_array_32.enqS(s);
        mac_array_03.enqS(s);
        mac_array_13.enqS(s);
        mac_array_23.enqS(s);
        mac_array_33.enqS(s);
    endmethod
    
    method ActionValue#(Vector#(4,Vector#(4,Bit#(32)))) get_result() if(cycle_o==7);
        Vector#(4, Vector#(4, Bit#(32))) result;
        result[0]=map(readReg, o0);
        result[1]=map(readReg, o1);
        result[2]=map(readReg, o2);
        result[3]=map(readReg, o3);
        return result;
    endmethod
endmodule

endpackage


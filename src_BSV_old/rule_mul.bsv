package rule_mul;
    import cla_int8 ::*;
    import DReg ::*;
    // Module to multiply two 8-bit signed integers using shift-and-add
    interface Multi_ifc;
        method Action start(Bit#(8) a, Bit#(8) b);
        method Bit#(16) get_result();
    endinterface : Multi_ifc
    
    (*synthesize*)
    module mkMultiplier (Multi_ifc);
        Cla_ifc cla1 <- mk_cla_add;
        Cla_ifc cla2 <- mk_cla_add;
        
        // Declarations for the inputs
        Reg#(Bit#(16)) multiplicand <- mkReg(0);  // 8-bit signed multiplicand, extended to 16 bits
        Reg#(Bit#(8))  multiplier   <- mkReg(0);  // 8-bit signed multiplier
        Reg#(Bit#(16)) product      <- mkReg(0);  // 16-bit signed product
        Reg#(Bit#(1))  sign         <- mkReg(0);  // Sign of the result
        Reg#(Bool)     inp_valid    <- mkReg(False);
        Reg#(Bool)     r_valid      <- mkReg(True);
        Reg#(Bool)     comp1        <- mkDReg(False);
        Reg#(Bool)     comp2        <- mkDReg(False);
        Reg#(Bool)     product_valid <- mkDReg(False);
    
        (*descending_urgency = "r2,r3,r4,r1"*)
        
        // Rule to shift multiplicand and multiplier if they are valid and non-zero
        rule r1 if (multiplicand != 0 && multiplier != 0 && r_valid && !comp1 && !comp2);
            multiplicand <= multiplicand << 1;
            multiplier   <= multiplier >> 1;
        endrule
    
        // Rule to perform the addition when the LSB of the multiplier is 1
        rule r2 if (multiplier[0] == 1 && r_valid && !comp1 && !comp2);
            r_valid <= False;
            cla1.start(multiplicand[7:0], product[7:0], 1'b0);
            comp1 <= True;
        endrule
    
        // Rule to complete the first addition and trigger the second addition if needed
        rule r3 if (comp1 && !comp2);
            let p = cla1.get_result;
            product[7:0] <= p.sum;
            cla2.start(multiplicand[15:8], product[15:8], p.overflow);
            comp2 <= True;
        endrule
    
        // Rule to complete the second addition and update the product
        rule r4 if (comp2);
            let q = cla2.get_result;
            product[15:8] <= q.sum;
            r_valid <= True;
            multiplicand <= multiplicand << 1;  // Shift for the next round
            comp1 <= False;
            comp2 <= False;
        endrule
    
        // Rule to signal completion of multiplication
        rule r5 if (multiplier == 0 && inp_valid);
            product_valid <= True;
            inp_valid <= False;
        endrule
        
        // Start method for the multiplier
        method Action start (Bit#(8) a, Bit#(8) b);
            sign <= a[7] ^ b[7];  // XOR to determine the sign of the product
            if (a[7] == 1) begin
                Int#(8) x = -unpack(a);  // Convert a to positive if it's negative
                a = pack(x);
            end
            if (b[7] == 1) begin
                Int#(8) y = -unpack(b);  // Convert b to positive if it's negative
                b = pack(y);
            end
            multiplicand <= zeroExtend(a);  // Zero-extend to 16 bits
            multiplier   <= b;              // Assign multiplier
            inp_valid    <= True;
            product      <= 0;              // Clear the product at the start
        endmethod : start
    
        // Method to get the final product result
        method Bit#(16) get_result() if (product_valid);
            Bit#(16) m = product;
            if (sign == 1'b1) begin
                Int#(16) z = -unpack(m);  // Negate the product if the sign is negative
                m = pack(z);
            end
            return m;
        endmethod : get_result
    endmodule
    endpackage
    

/*
package rule_mul;
import cla_int8 ::*;
import DReg ::*;
// Module to multiply two 8-bit signed integers using shift-and-add
interface Multi_ifc;
    method Action start(Bit#(8) a, Bit#(8) b);
    method Bit#(16) get_result();
endinterface : Multi_ifc

(*synthesize*)
module mkMultiplier (Multi_ifc);
    Cla_ifc cla1 <- mk_cla_add;
Cla_ifc cla2 <- mk_cla_add;
    // Declarations for the inputs
    Reg#(Bit#(16)) multiplicand <- mkReg(0);   // 8-bit signed multiplicand
    Reg#(Bit#(8)) multiplier   <- mkReg(0);   // 8-bit signed multiplier
    Reg#(Bit#(16)) product     <- mkReg(0);   // 16-bit signed product
    Reg#(Bit#(1)) sign <- mkReg(0);
    Reg#(Bool) inp_valid       <- mkReg(False);
    Reg#(Bool) r_valid       <- mkReg(True);
    Reg#(Bool) comp1       <- mkDReg(False);
    Reg#(Bool) comp2       <- mkDReg(False);
    Reg#(Bool) product_valid   <- mkDReg(False);
    (*descending_urgency = "r2,r3,r4,r1"*)
    rule r1 if(multiplicand!=0 && multiplier!=0 && r_valid && !comp1 && !comp2);
        multiplicand<=multiplicand<<1;
        multiplier<=multiplier>>1;
    endrule
    rule r2 if(multiplier[0]==1 && r_valid);
        r_valid<=False;
        cla1.start(multiplicand[7:0],product[7:0],1'b0);
        comp1<=True;
        multiplier<=multiplier>>1;
    endrule
    rule r3 if(comp1);
        let p=cla1.get_result;
        product[7:0]<=p.sum;
        cla2.start(multiplicand[15:8],product[15:8],p.overflow);
        comp2<=True;
        r_valid<=False;
    endrule
    rule r4 if(comp2);
        let q=cla2.get_result;
        product[15:8]<=q.sum;
        r_valid<=True;
        multiplicand<=multiplicand<<1;
    endrule
    rule r5 if (multiplier==0 && inp_valid);
        product_valid<=True;
        inp_valid<=False;
    endrule
    
    method Action start (Bit#(8) a, Bit#(8) b);
            sign <= a[7]^b[7];
            if (a[7]==1) begin
                Int#(8) x = -unpack(a);
                a = pack(x);
            end
            if (b[7]==1) begin
                Int#(8) y = -unpack(b);
                b = pack(y);
            end
            multiplicand <= zeroExtend(a);
            multiplier   <= b;
            inp_valid    <= True;
    endmethod : start
    method Bit#(16) get_result() if(product_valid);
    Bit#(16) m=product;
    if (sign==1'b1) begin
        
        Int#(16) z = -unpack(m);
        m=pack(z);
    end
        return m;
    endmethod : get_result
endmodule
endpackage
 */
package int8_signed_multiplier;
//import cla_int8 ::*;

import DReg ::*;
typedef struct{
   Bit#(1) overflow;
   Bit#(8) sum;
} Output_Cla deriving(Bits,Eq);
// Module to multiply two 8-bit signed integers using shift-and-add
interface Multi_ifc;
    method Action start(Bit#(8) a, Bit#(8) b);
    method Bit#(16) get_result();
endinterface : Multi_ifc
(*synthesize*)
module mkMultiplier (Multi_ifc);
    // Declarations for the inputs
    Reg#(Bit#(8)) multiplicand <- mkReg(0);   // 8-bit signed multiplicand
    Reg#(Bit#(8)) multiplier   <- mkReg(0);   // 8-bit signed multiplier
    Reg#(Bit#(16)) product     <- mkReg(0);   // 16-bit signed product
    Reg#(Bool) inp_valid       <- mkDReg(False);
    Reg#(Bool) product_valid   <- mkDReg(False);
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
    function Bit#(16) shift_and_add (Bit#(8) a, Bit#(8) b);
        Bit#(16) result = 0;
        Bit#(1) is_negative = (a[7]^b[7]);
        if (a[7]==1) begin
            Int#(8) x = -unpack(a);
            a = pack(x);
        end
        if (b[7]==1) begin
            Int#(8) y = -unpack(b);
            b = pack(y);
        end
        Bit#(16) b1={8'b0,b};
        for (Integer i = 0; i < 8; i = i + 1) begin
            if (a[0] == 1) begin
                Bit#(9) out1 = addCLA8(result[7:0],b1[7:0],1'b0);
                result[7:0] = out1[7:0];
                Bit#(9) out2 = addCLA8(result[15:8],b1[15:8],out1[8]);
                result[15:8] = out2[7:0];
            end
            b1= b1<<1;
            a = a>>1;
        end
        if (is_negative==1'b1) begin
            Int#(16) z = -unpack(result);
            result = pack(z);
        end
        return result;
    endfunction : shift_and_add
    rule rl_multiplier if(inp_valid);
        product <= shift_and_add(multiplicand, multiplier);
        product_valid <= True;
    endrule
    method Action start (Bit#(8) a, Bit#(8) b);
            multiplicand <= a;
            multiplier   <= b;
            inp_valid    <= True;
    endmethod : start
    method Bit#(16) get_result() if(product_valid);
        return product;
    endmethod : get_result
    endmodule
endpackage
 
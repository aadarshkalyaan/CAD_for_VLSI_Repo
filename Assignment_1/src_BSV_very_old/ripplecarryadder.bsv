package ripplecarryadder;
    
    //Package imports
    import DReg ::*;

    //Custom structs
    typedef struct{
      Bit#(1) overflow;
      Bit#(32) sum;
    } AdderResult deriving(Bits, Eq);

    //Ripple carry adder interface
    interface RCA_ifc;
      method Action start(Bit#(32) a, Bit#(32) b);
      method AdderResult get_result();
    endinterface : RCA_ifc

    //Top-level module definition
    (*synthesize*)
    module mkRippleCarryAdder (RCA_ifc);
      //Registers/Wires usd in the design
      Reg#(Bit#(32)) rg_inp1 <- mkReg(0);
      Reg#(Bit#(32)) rg_inp2 <- mkReg(0);
      Reg#(Bool)     rg_inp_valid <- mkDReg(False);
      
      //Reg#(AdderResult) rg_out <- mkReg(unpack(0));
      Reg#(AdderResult) rg_out        <- mkReg(AdderResult{overflow: 0,
						           sum     : 0});
      Reg#(Bool)        rg_out_valid  <- mkDReg(False);
      function AdderResult ripple_carry_addition (
	Bit#(32) a,
	Bit#(32) b,
	Bit#(1)  cin
      );
	Bit#(32) sum;
	Bit#(33) carry = '0;
	
	carry[0] = cin;
	
	for (Integer i = 0; i < 32; i = i + 1) begin
	  sum  [i]   = (a[i] ^ b[i] ^ carry[i]);
	  carry[i+1] = (a[i] & b[i]) | (carry[i] & (a[i] ^ b[i]));
	end

	AdderResult out;
	out.sum      = sum;
	out.overflow = carry[32];

	return out;

	/*
	return AdderResult(
	  sum     : sum,
	  overflow: carry[33]
	);
	*/
      endfunction : ripple_carry_addition

      //Rule definitions
      rule rl_rca;
	rg_out       <= ripple_carry_addition(rg_inp1, rg_inp2, 1'b0);
  //$display ("rg_out = %b", rg_out);
	rg_out_valid <= True;
  //$display ("rg_out_valid = %b", rg_out_valid);
      endrule : rl_rca
      
      // Interface method definitions
      method Action start (Bit#(32) a, Bit#(32) b);
	rg_inp1 <= a;
	rg_inp2 <= b;
	rg_inp_valid <= True;
      endmethod : start

      method AdderResult get_result() if(rg_out_valid);
	return rg_out;
      endmethod : get_result

    endmodule : mkRippleCarryAdder

endpackage

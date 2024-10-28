/*
package Testbench;
import mult ::*;
(* synthesize *)
module mkTestbench(Empty);
    Mul_ifc bm<- mkmul;
    rule r;
        bm.init(8'h02,8'h04);
	endrule
    rule r1;
        $display ("%b",bm.get_result);
        //$finish;
    endrule
endmodule
endpackage
*/
/*
package Testbench;
import booth_multiplier ::*;
(* synthesize *)
module mkTestbench(Empty);
    Boo_ifc bm<- mkboo;
    rule r;
        bm.init(8'h02,8'h04);
	endrule
    rule r1;
        let x = bm.get_result;
        $display ("%b",x);
        $finish;
    endrule
endmodule
endpackage
*/
/*
package Testbench;
import int8_signed_multiplier ::*;
import cla_int32::*;
(* synthesize *)
module mkTestbench (Empty);
	Cla32_ifc mac_inst <- mkCla32Adder;
	rule rl_go;
		let z = mac_inst.compute(32'hFFFFFFFF,32'h01,1'b0); //-18*-2 
		$display ("sum = %b", z);
		$finish();
	endrule
endmodule: mkTestbench
endpackage
*/

/*
package Testbench;
import int8_signed_multiplier_2 ::*;
(* synthesize *)
module mkTestbench (Empty);
	Multi_ifc mac_inst <- mkMultiplier;
	rule rl_go;
		let z = mac_inst.compute(8'h12,8'hEE); //-18*-2 
		$display ("Product = %d", z);
		$finish();	
	endrule
endmodule: mkTestbench
endpackage
//*/
/*
package Testbench;
import int8_signed_multiplier ::*;
import cla_int8::*;
(* synthesize *)
module mkTestbench (Empty);
	Cla_ifc mac_inst <- mk_cla_add;
	rule rl_go;
		mac_inst.start(8'hEE,8'hEE,1'b0);
	endrule
	rule rl_finish;
		let z = mac_inst.get_result;
		$display ("Sum = %b", z.sum);
		if (z.overflow == 1) begin
		$display ("Overflow = %b", z.overflow);
		end
		$finish();
		
	endrule
endmodule: mkTestbench
endpackage
*/
///*
package Testbench;
import CAD_V1::*;
(* synthesize *)
module mkTestbench (Empty);
	TOP_IFC mac_inst <- mkMAC;
	rule rl_finish;
		let z = mac_inst.get_MAC(16'hEE,16'h01,32'h11,1'b0);
		$display ("Product = %b", z);
		$finish ();
	endrule
endmodule: mkTestbench
endpackage
//*/
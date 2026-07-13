/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M15
 Module Name  : alusrcb_mux
 File Name    : alusrcb_mux.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : Selects the second operand for the ALU.

 Date Created : 06.07.2026
 Version      :

 Inputs       : B_out, constant_4, ImmExt, ALUSrcB

 Outputs      : alu_src_b

==============================================================================
*/

module alusrcb_mux(B_out, ImmExt, ALUSrcB, alu_src_b);
	
	input [31:0] B_out, ImmExt;
	input [1:0] ALUSrcB;
	
	output reg [31:0] alu_src_b;
	
	always @ (*)
		begin
			case(ALUSrcB)
				2'b00 : alu_src_b = B_out;
				2'b01 : alu_src_b = 32'd4;
				2'b10 : alu_src_b = ImmExt;
			    default : alu_src_b = 32'b00;
			endcase
		end
 
endmodule 
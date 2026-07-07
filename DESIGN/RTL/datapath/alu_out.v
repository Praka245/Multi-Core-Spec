/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M10
 Module Name  : alu_out
 File Name    : alu_out.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : The ALUOut Register is a 32-bit temporary register that stores the output produced by the ALU.

 Date Created : 07.07.2026
 Version      :

 Inputs       : clk, reset, alu_result

 Outputs      : alu_out

==============================================================================
*/

module alu_out(clk, reset, alu_result,alu_out);

	input clk, reset;
	input [31:0] alu_result;
	output reg [31:0] alu_out;

	always@(posedge clk or negedge reset)
	begin
		if(!reset) alu_out <= 32'd0;
		else alu_out <= alu_result;
	end
	

endmodule
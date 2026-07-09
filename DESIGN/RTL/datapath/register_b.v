/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M7
 Module Name  : register_b
 File Name    : register_b.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  :  stores operand from rs2 used by ALU and  Unified Memory.


 Date Created : 07.07.2026
 Version      :

 Inputs       : clk,reset,read_data2

 Outputs      : b_out

==============================================================================
*/



module register_b (
		input clk,reset,
		input [31:0] read_data2,
		output reg [31:0] b_out);
		
		always@(posedge clk or negedge reset)
		begin
			if(!reset)
				b_out <= 32'd0;
			else
				b_out <= read_data2;
		end
endmodule


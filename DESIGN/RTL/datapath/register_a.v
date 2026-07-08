/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M06
 Module Name  : register_a
 File Name    : register_a.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : Holds this operand constant throughout the Execute, Memory, 
				and Write-Back stages of the current instruction.


 Date Created : 06.07.2026
 Version      : 1

 Inputs       : clk , reset , read_data1

 Outputs      : A_out

==============================================================================
*/

module register_a (clk , reset , read_data1, A_out);
	
	input clk , reset , AWrite , 
	input [31:0] read_data1,
	output reg [31:0] A_out;

always@(posedge clk or negedge reset) 
	begin 
		if(!reset)
		begin 
			A_out <= 32'd0;
		end 
		
		else begin 
			A_out <= read_data1;
		end 
	end 

endmodule 

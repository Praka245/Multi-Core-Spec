/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M04
 Module Name  : memory_data_register
 File Name    : memory_data_register.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : Temporarily stores the data read from the Unified Memory during Load (lw) instructions.


 Date Created : 07.07.2026
 Version      : 1

 Inputs       : clk, reset , 
			    [31:0]read_data1

 Outputs      : [31:0]mdr_out

==============================================================================
*/

module memory_data_register ( input clk, reset ,
input [31:0]read_data ,
output reg [31:0]mdr_out );

always@(posedge clk or negedge reset) 
	begin 
		if(!reset) 
			mdr_out <= 32'd0;
		else 
			mdr_out <= read_data;
	end 
	
endmodule 

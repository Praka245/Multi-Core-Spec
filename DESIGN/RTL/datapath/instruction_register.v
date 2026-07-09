
/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M3
 Module Name  : instruction register
 File Name    : instruction_register.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  :  stores instruction fetched from  Unified Memory .


 Date Created : 07.07.2026
 Version      :

 Inputs       : clk,reset,IRwrite,instruction_in

 Outputs      : instruction_out

==============================================================================
*/


module instruction_register (
		input clk,reset,
		input IRwrite,
		input [31:0] instruction_in,
		output reg [31:0] instruction_out);
		
		always@(posedge clk or negedge reset)
		begin
			if(!reset)
				instruction_out <= 32'd0;
			else if(IRwrite)
					instruction_out <= instruction_in;
			end
endmodule			
			
				
		
		
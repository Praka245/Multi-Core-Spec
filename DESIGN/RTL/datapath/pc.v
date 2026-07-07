/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M1
 Module Name  : pc
 File Name    : pc.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : It provides the address to the Unified Memory during the Instruction Fetch (IF) cycle and is updated with the 
				address of the next instruction at the end of the cycle.

 Date Created : 07.07.2026
 Version      :

 Inputs       : clk, reset, pc_write_enb, pc_next

 Outputs      : pc

==============================================================================
*/

module pc(clk, reset, pc_write_enb, pc_next, pc);

	input clk, reset, pc_write_enb;
	input [31:0] pc_next;
	
	output [31:0] pc;
	
	always @(posedge clk or negedge reset)
		begin 
			if(!reset) pc <= 32'b00;
			else if(pc_write_enb) pc <= pc_next;
			else pc <= pc;
		end 
	

endmodule 
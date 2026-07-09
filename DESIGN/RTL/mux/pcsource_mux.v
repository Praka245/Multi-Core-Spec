/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M16
 Module Name  : pcsource_mux
 File Name    : pcsource_mux.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : Selects the next value to be loaded into the Program Counter.

 Date Created : 06.07.2026
 Version      :

 Inputs       : alu_result, alu_out, PCSource 

 Outputs      : pc_next

==============================================================================
*/

module pcsource_mux(alu_result, alu_out, PCSource, pc_next);
	
	input [31:0] alu_result, alu_out;
	input PCSource ;
	
	output [31:0] pc_next;
	
	assign pc_next = (PCSource) ? alu_out : alu_result;
 
endmodule 
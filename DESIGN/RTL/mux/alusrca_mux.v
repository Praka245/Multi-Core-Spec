/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M14
 Module Name  : alusrca_mux
 File Name    : alusrca_mux.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : Selects the first operand for the ALU.

 Date Created : 06.07.2026
 Version      :

 Inputs       : pc, A_out, ALUSrcA

 Outputs      : alu_src_a

==============================================================================
*/

module alusrca_mux(pc, A_out, ALUSrcA, alu_src_a);
	
	input [31:0] pc, A_out;
	input ALUSrcA;
	
	output [31:0] alu_src_a;
	
	assign alu_src_a = (ALUSrcA) ? A_out : pc;
 
endmodule 
/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M13
 Module Name  : iord_mux
 File Name    : iord_mux.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : Selects the address supplied to the Unified Memory.


 Date Created : 06.07.2026
 Version      :

 Inputs       : pc, alu_out, IorD

 Outputs      : address

==============================================================================
*/

module iord_mux(pc, alu_out, IorD, address);
	
	input [31:0] pc, alu_out;
	input IorD;
	
	output [31:0] address;
	
	assign address = (IorD) ? alu_out : pc;
 
endmodule 
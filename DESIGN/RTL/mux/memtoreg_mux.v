/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M17
 Module Name  : memtoreg_mux
 File Name    : memtoreg_mux.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : Selects the data written back into the Register File.

 Date Created : 06.07.2026
 Version      :

 Inputs       : alu_out, mdr_out, MemtoReg

 Outputs      : write_data

==============================================================================
*/

module memtoreg_mux(alu_out, mdr_out, MemtoReg, write_data);
	
	input [31:0] alu_out, mdr_out;
	input MemtoReg ;
	
	output [31:0] write_data;
	
	assign write_data = (MemtoReg) ? mdr_out : alu_out;
 
endmodule 
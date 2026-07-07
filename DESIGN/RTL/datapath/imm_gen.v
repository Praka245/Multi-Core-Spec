/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M10
 Module Name  : imm_gen
 File Name    : imm_gen.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : The Immediate Generator (ImmGen) extracts the immediate field from the current instruction stored in the Instruction Register 
				(IR) and generates a 32-bit immediate value according to the RV32I instruction format.

 Date Created : 07.07.2026
 Version      :

 Inputs       : instruction

 Outputs      : ImmExt

==============================================================================
*/

module imm_gen(instruction,ImmExt);
	
	input [31:0] instruction;
	output reg [31:0] ImmExt;
	
	always @(*)
		case (instruction[6:0])
			
			// I - type
			7'b0010011 : ImmExt = {{20{instruction[31]}}, instruction[31:20]};
			
			// S - type 
			7'b0100011 : ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
			
			// B - type 
			7'b1100011 : ImmExt = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
			
			// U - type 
			7'b0110111 : ImmExt = {instruction[31:12], 12'd0};
			
			// J - type  (JAL)
			7'b1101111 : ImmExt = {{12{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
		
			// (JALR)
			7'b1100111 : ImmExt = {{20{instruction[31]}}, instruction[31:20]};
			
			default    : ImmExt = 32'd0;
		
		endcase 

endmodule

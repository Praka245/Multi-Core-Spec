/*
==============================================================================
 Project      : RV32I Multi-Cycle RISC-V Processor
 Module No    : M06
 Module Name  : register_file
 File Name    : register_file.v

 Core         : RV32I
 Architecture : Multi-Cycle
 ISA          : RV32I Base Integer ISA
 XLEN         : 32-bit

 Description  : Store operands and computation results during program execution.
                It provides two simultaneous read ports and one write port, 
				enabling the processor to read two source operands and write 
				one destination operand.


 Date Created : 07.07.2026
 Version      : 1

 Inputs       : clk , reset , RegWrite , 
			    [31:0]read_data1,
				[4:0]rs1,rs2,rd 

 Outputs      : [31:0]read_data1,read_data2

==============================================================================
*/

module register_file (input clk,reset,RegWrite ,
input [4:0]rs1,rs2,rd,
input [31:0]write_data,
output [31:0]read_data1,read_data2);

reg [31:0] register_file [0:31];
integer i=0;

always@(posedge clk or negedge reset) 
	begin
		if(!reset) 
			begin 
				for(i=0 ; i<32 ; i=i+1) 
				register_file[i]<=32'd0;
			end
		
		else if(RegWrite && rd!=5'd0) 
			register_file[rd]<=write_data;
	end
	
assign read_data1 = register_file[rs1];
assign read_data2 = register_file[rs2];

endmodule 

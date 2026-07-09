module unified_memory #(
	parameter DATA_WIDTH = 32,
	parameter ADDRESS_WIDTH = 32,
	parameter DEPTH = 1024 ) // 1024 LOCATIONS
	(
	input clk,reset,
	input MemRead,MemWrite,
	input [ADDRESS_WIDTH-1:0] address,
	input [DATA_WIDTH-1:0] write_data,
	output 	reg [DATA_WIDTH-1:0] read_data);
	
	
	integer i;
	
     reg [DATA_WIDTH-1:0] memory [0: DEPTH - 1];
	 
	always@(posedge clk)
	begin
		if(!reset)
		begin
			read_data <= 32'd0;
			for(i = 0; i<DEPTH; i = i+1)
			memory[i] <= 32'd0;
		end
		else if(MemRead&&!MemWrite)
			read_data <= memory[address[31:2]];
		else if(!MemRead&&MemWrite)
			memory[address[31:2]] <= write_data;
	end
	
endmodule

/*      31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 1098765432 10   
PC = 0	0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 00000000 00 
PC = 4	0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 00000001 00
PC = 8	0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 00000010 00
PC = 12	0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 00000011 00
PC = 16	0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 00000100 00
PC = 20	0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 00000101 00 
PC = 24	0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 00000110 00 
*/
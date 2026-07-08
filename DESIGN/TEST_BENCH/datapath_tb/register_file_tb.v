module register_file_tb;
reg clk,reset,RegWrite;
reg [4:0]rs1,rs2,rd;
reg [31:0]write_data;
wire [31:0]read_data1,read_data2;

register_file uut(clk,reset,RegWrite,rs1,rs2,rd,write_data,read_data1,read_data2);
integer i;

initial 
	begin 
		clk=1'b0;
		forever #1 clk=~clk;
	end 
	
task initialize;
	begin 
		reset=1'b0;
		rs1=5'b0;
		rs2=5'b0;
		rd=5'b0;
		write_data=32'd0;
		RegWrite=1'b0;
		i=16000;
	end 
endtask



task supply_input;
	begin 
		@(negedge clk);
		{rd,rs1,rs2}=i;
		{write_data}=i;
		i=i-1000;	
	end 
endtask

task write_register;
integer j;
begin 
	for(j=0; j<32; j=j+1) 
		begin 
			@(negedge clk);    // why negedge ? becuase the data_write happens only at the posedge 
			rd=j;              // if it is not given in the zero simulation time this for loop will be executed
			write_data=j;
		end
end
endtask
	
initial 
	begin 
		initialize;
		#5 reset=1'b1;
		RegWrite=1'b1;          //write enable asserted
		write_register;
		repeat (6) supply_input;
		#10 RegWrite=1'b0;      // write enable released 
		supply_input;
		#10 supply_input;
		#10 $finish;
	end 
	
	
endmodule 
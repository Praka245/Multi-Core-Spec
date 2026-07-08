module memory_data_register_tb ;
reg clk, reset ;
reg [31:0]read_data ;
wire[31:0]mdr_out;

memory_data_register uut(clk,reset,read_data,mdr_out);

initial 
	begin 
		clk=1'b0;
		forever #1 clk=~clk;
	end 
	
task initialize;
	begin 
		reset=1'b0;
		read_data=32'd0;
	end 
endtask

initial 
begin 
	initialize;
	#4 reset=1'b1;
	read_data=32'd12;
	#4 reset=1'b0;
	#4 reset=1'b1;
	read_data=32'd24;
	#4 $finish;
end 

endmodule 
	
	


module register_a_tb;
reg clk , reset , AWrite ; 
reg [31:0]read_data1 ;
wire [31:0]A_out ;

register_a uut(clk,reset,AWrite , read_data1 , A_out);


initial 
	begin 
		clk=1'b0;
		forever #1 clk=~clk;
	end 

task initialize;
	begin 
		reset=1'b0;
		AWrite=1'b0;
		read_data1=32'd0;
	end 
endtask

	

initial 
	begin 
		initialize;
		@(negedge clk);
		reset=1'b1;
		AWrite=1'b1;
		read_data1=32'd14;
		#2 reset=1'b0;
		   AWrite=1'b1;
		#2 reset=1'b1;
		   AWrite=1'b1;
		read_data1=32'd37;
		#2 $finish;	
	end 
	
endmodule
	
	
	
	
	
	
	
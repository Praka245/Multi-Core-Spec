module register_b_tb;

	reg clk,reset;
	reg [31:0] read_data2;
	wire [31:0] b_out;
	
	reg [31:0] expected = 32'd0;
	register_b uut (clk,reset,read_data2,b_out);

	
	initial begin
	clk =0;
	forever #5 clk = ~clk;
	end

	
	task reset_task();
	
	begin
		@(negedge clk)
		reset = 0;
		@(posedge clk)
		#1;
		if(expected == b_out)
		$display("reset is working ");
		else
		begin
			$display("reset is not working ");
			$stop;
		end
		@(negedge clk)
		reset = 1;
	end
	endtask
	
	
	
	task data_send();
	reg [31:0] reg1;
	begin
		
		repeat(10)
		begin
			@(negedge clk)
			reg1 = {$random} % 4294967296;
			read_data2 = reg1;
			@(posedge clk)
			#1;
			if(b_out == reg1)
			$display("register b is working");
			else
			begin
				$display("register b is not working");
				$stop;
			end
		end
	end
	endtask
	
	initial begin
		read_data2 = 32'd45;
		reset_task;
		data_send;
		#100;
		$finish;
	end
	initial begin
	$dumpfile("register_b.vcd");
	$dumpvars(0,register_b_tb);
	end
	
endmodule
	
			
		
		
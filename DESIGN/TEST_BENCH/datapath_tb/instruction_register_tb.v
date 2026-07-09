module instruction_reg_tb;
	reg clk,reset;
	reg IRwrite;
	reg [31:0] instruction_in;
	wire [31:0] instruction_out;
	
	instruction_register uut (clk,reset,IRwrite,instruction_in,instruction_out);
	
	initial begin
		clk =0;
		forever #5 clk = ~clk;
	end
	
	reg [31:0] expected =32'd0;
	
	task reset_task;
	begin
		@(negedge clk)
		reset = 0;
		@(posedge clk)
		#1;
		if (expected == instruction_out)
		$display("reset is working");
		else
		begin
			$display("reset is working");
			$stop;
		end
		@(negedge clk)
		reset = 1;
	end
	endtask

	integer seed = 200;
	task send_data;
		reg [31:0] reg1;
		reg [31:0] pre_data;
	begin
		repeat(20)
		begin
		pre_data = instruction_out;
		@(negedge clk)
		IRwrite = $random(seed)%2;
		reg1 = $random(seed) % 4294967296;
		instruction_in = reg1;
		@(posedge clk)
		#1;
		if(IRwrite)
		begin
			if(reg1 == instruction_out)
			$display("instruction register is working at %0t",$time);
			else
			begin
			$display("instruction register is not working at %0t",$time);
			$stop;
			end
		end
		else 
		begin
			if(pre_data == instruction_out)
			begin
			$display("instruction register IR = 0 is working at %0t",$time);
			pre_data = instruction_out;
			end
			else
			begin
			$display("instruction register IR = 0 is not working at %0t",$time);
			$stop;
			end
		end
	end
	end
	endtask
		
	initial begin
	reset_task;
	send_data;
	#10;
	$finish;
	end
	
	initial begin
	$dumpfile("instruction_reg.vcd");
	$dumpvars(0,instruction_reg_tb);
	end
	
endmodule

		
		
	
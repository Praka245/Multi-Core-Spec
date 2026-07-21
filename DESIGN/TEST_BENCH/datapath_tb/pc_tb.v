module pc_tb;
	reg clk,reset,pc_write_enb;
	reg [31:0] pc_next;
	wire [31:0] pc;
	integer error_count;
	
	pc uut (clk,reset,pc_write_enb,pc_next,pc);
	
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
		
	
	task reset_logic;
		begin
			@(negedge clk )
			reset = 0;
			pc_next = 0;
			pc_write_enb =0;
			@(posedge clk)
			#1;
			if(pc == 32'd0)
			$display("pc is reseting");
			else
			begin
			$display("pc not is reseting");
			error_count = error_count +1;
			end
			
			@(negedge clk )
			reset = 1;
		end
	endtask
	
	
	
	task stimulus;
	reg [31:0] pc_pre;
		begin
		repeat(20)
		begin
			@(negedge clk )
			pc_write_enb = $random;
			pc_pre = pc;
			pc_next = pc_next +3'd4;
			@(posedge clk)
			#1;
			if(pc_write_enb)
			begin
				if(pc == pc_next)
				begin
					$display("pc is incrementing");
					$display("passed");
				end
				else
				begin
					$display("failed at expected pc_next = %0h",pc_next);
					error_count = error_count +1;
				end
			end
			else
			begin
				if(pc == pc_pre)
				$display(" pc is stay in old state");
				else
				begin
					$display("pc is not stay in old state");
					error_count = error_count+1;
				end
			end
		end
	end
	endtask
	
	initial begin
		error_count =0;
		reset_logic;
		stimulus;
	    if(error_count == 0)
		$display("all passed");
		else
		$display("failed with error = %0d",error_count);
		
		$finish;
	end
	
	initial begin
		$dumpfile("SIM/pc.vcd");
		$dumpvars(0,pc_tb);
	end
endmodule

				
				
					
		
		
			
			
	
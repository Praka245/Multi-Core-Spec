module alusrcb_mux_tb;

	reg [31:0] B_out,ImmExt;
	reg [1:0] ALUSrcB;
	
	wire [31:0] alu_src_b;
	
	alusrcb_mux uut (B_out, ImmExt, ALUSrcB, alu_src_b);
	integer seed = 100;
	integer seed1 = 200;
    integer seed2 = 300;
	
	task stimulus ;
	begin
		repeat(20)
		begin
            #10;
			B_out    = $urandom(seed1);
            ImmExt   = $urandom(seed2);
			ALUSrcB  = $urandom %4;
            #1;
			
			$display("-----------------------");
            $display("B_out == %0d",B_out);
			$display("constant_4 == %0d",32'd4);
			$display("ImmExt == %0d",ImmExt);
            $display("ALUSrcB == %0d",ALUSrcB);
			#1;
			if(ALUSrcB == 2'b00)
			begin
				if(B_out == alu_src_b)
                begin
                $display("alu_src_b == %0d",alu_src_b);
				$display("b_out is selected");
                end
				else
				begin
				$display("b_out is not selected correctly");
				$stop;
				end
			end
			
			
			else if (ALUSrcB == 2'b01)
			begin
				if(alu_src_b == 32'd4)
                begin
                $display("alu_src_b == %0d",alu_src_b);
				$display("constant_4 is selected");
                end
				else
				begin
				$display("constant_4 is not selected correctly");
				$stop;
				end
			end
			
			else if (ALUSrcB == 2'b10)
			begin
				if(alu_src_b == ImmExt)
                begin
                $display("ImmExt == %0d",ImmExt);
				$display("ImmExt is selected");
                end
				else
				begin
				$display("ImmExt is not selected correctly");
				$stop;
				end
			end
			
			else 
			begin
				if(alu_src_b == 32'b00 )
                begin
                $display("alu_src_b == %0d",alu_src_b);
				$display("zero is displayed");
                end
				else
				begin
				$display("zero is not displayed");
				$stop;
				end
			end
			
			
		end
	end
    endtask
	
	initial
	begin
		ImmExt = 0;
		B_out =0;
		ALUSrcB =2'b01;
        #1;
            $display("-----------------------");
            $display("B_out == %0d",B_out);
			$display("constant_4 == %0d",32'd4);
			$display("ImmExt == %0d",ImmExt);
            $display("ALUSrcB == %0d",ALUSrcB);
			
			
            if(ALUSrcB == 2'b00)
			begin
				if(B_out == alu_src_b)
                begin
                $display("alu_src_b == %0d",alu_src_b);
				$display("b_out is selected");
                end
				else
				begin
				$display("b_out is not selected correctly");
				$stop;
				end
			end
			
			
			else if (ALUSrcB == 2'b01)
			begin
				if(alu_src_b == 32'd4)
                begin
                $display("alu_src_b == %0d",alu_src_b);
				$display("constant_4 is selected");
                end
				else
				begin
				$display("constant_4 is not selected correctly");
				$stop;
				end
			end
			
			else if (ALUSrcB == 2'b10)
			begin
				if(alu_src_b == ImmExt)
                begin
                $display("ImmExt == %0d",ImmExt);
				$display("ImmExt is selected");
                end
				else
				begin
				$display("ImmExt is not selected correctly");
				$stop;
				end
			end
			
			else 
			begin
				if(alu_src_b == 32'b00 )
                begin
                $display("alu_src_b == %0d",alu_src_b);
				$display("zero is displayed");
                end
				else
				begin
				$display("zero is not displayed");
				$stop;
				end
			end

		stimulus;
		#10;
        $finish;

	end

	initial begin
		$dumpfile("SIM/alusrcb_mux.vcd");
		$dumpvars(0,alusrcb_mux_tb);
	end
endmodule 

	
		
		
		
		
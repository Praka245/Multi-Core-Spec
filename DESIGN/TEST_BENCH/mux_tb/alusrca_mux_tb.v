module alusrca_mux_tb;

	reg [31:0] pc,A_out;
	reg ALUSrcA;
	
	wire [31:0] alu_src_a;
	
	alusrca_mux uut (pc, A_out, ALUSrcA, alu_src_a);
	integer seed = 100;
	integer seed1 = 200;
	
	task stimulus ;
	begin
		repeat(20)
		begin
            #10;
			pc       = $urandom(seed) ;
			A_out    = $urandom(seed1);
			ALUSrcA  = $urandom %2;
            #1;
			
			$display("-----------------------");
			$display("pc == %0d",pc);
			$display("A_out == %0d",A_out);
            $display("ALUSrcA == %0d",ALUSrcA);
			// #1;
			if(ALUSrcA)
			begin
				if(A_out == alu_src_a)
                begin
                $display("alu_src_a == %0d",alu_src_a);
				$display("a_out is selected");
                end
				else
				begin
				$display("a_out is not selected correctly");
				$stop;
				end
			end
			else
			begin
				if(pc == alu_src_a)
                begin
                $display("alu_src_a == %0d",alu_src_a);
				$display("pc is selected");
                end
				else
				begin
				$display("pc is not selected correctly");
				$stop;
				end
			end
			
		end
	end
    endtask
	
	initial
	begin
		pc = 0;
		A_out =2;
		ALUSrcA =0;
        #1;
             $display("-----------------------");
			 $display("pc == %0d",pc);
			 $display("A_out == %0d",A_out);
             $display("ALUSrcA == %0d",ALUSrcA);
             if(ALUSrcA)
			begin
				if(A_out == alu_src_a)
                begin
                $display("alu_src_a == %0d",alu_src_a);
				$display("a_out is selected");
                end
				else
				begin
				$display("a_out is not selected correctly");
				$stop;
				end
			end
			else
			begin
				if(pc == alu_src_a)
                begin
                $display("alu_src_a == %0d",alu_src_a);
				$display("pc is selected");
                end
				else
				begin
				$display("pc is not selected correctly");
				$stop;
				end
			end

		stimulus;
		#10;
        $finish;

	end

	initial begin
		$dumpfile("SIM/alusrca_mux.vcd");
		$dumpvars(0,alusrca_mux_tb);
	end
endmodule 

	
		
		
		
		
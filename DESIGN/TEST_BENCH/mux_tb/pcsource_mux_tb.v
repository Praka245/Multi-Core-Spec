module pcsource_mux_tb;

	reg [31:0] alu_result,alu_out;
	reg PCSource;
	
	wire [31:0] pc_next;
	
	pcsource_mux uut (alu_result, alu_out, PCSource, pc_next);
	integer seed = 100;
	integer seed1 = 200;
	
	task stimulus ;
	begin
		repeat(20)
		begin
            #10;
			alu_result  = $urandom(seed) ;
			alu_out  = $urandom(seed1);
			PCSource = $urandom %2;
            #1;
			
			$display("-----------------------");
			$display("alu_out == %0d",alu_out);
            $display("alu_result == %0d",alu_result);
            $display("PCSource == %0d",PCSource);
			#1;
		   if(pc_next !== (PCSource ? alu_out : alu_result))
			begin
                $display("pc_next == %0d",pc_next);
				$display("FAILED");
				$stop;
			end
			else
			begin
                $display("pc_next == %0d",pc_next);
				$display("PASSED");
			end
			
		end
	end
    endtask
	
	initial
	begin
		alu_result = 0;
		alu_out =2;
		PCSource =0;
        #1;
             $display("-----------------------");
			 $display("alu_out == %0d",alu_out);
             $display("alu_result == %0d",alu_result);
             $display("PCSource == %0d",PCSource);
             if(pc_next !== (PCSource ? alu_out : alu_result))
			begin
                $display("pc_next == %0d",pc_next);
				$display("FAILED");
				$stop;
			end
			else
			begin
                $display("pc_next == %0d",pc_next);
				$display("PASSED");
			end

		stimulus;
		#10;
        $finish;

	end

	initial begin
		$dumpfile("SIM/pcsource_mux.vcd");
		$dumpvars(0,pcsource_mux_tb);
	end
endmodule 

	
		
		
		
		
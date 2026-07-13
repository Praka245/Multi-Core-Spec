module iord_mux_tb;

	reg [31:0] pc,alu_out;
	reg IorD;
	
	wire [31:0] address;
	
	iord_mux uut (pc, alu_out, IorD, address);
	integer seed = 100;
	integer seed1 = 200;
	
	task stimulus ;
	begin
		repeat(20)
		begin
            #10;
			pc       = $urandom(seed) ;
			alu_out  = $urandom(seed1);
			IorD     = $urandom %2;
            #1;
			
			$display("-----------------------");
			$display("pc == %0d",pc);
			$display("alu_out == %0d",alu_out);
            $display("IorD == %0d",IorD);
			#1;
		   if(address !== (IorD ? alu_out : pc))
			begin
                $display("address == %0d",address);
				$display("FAILED");
				$stop;
			end
			else
			begin
                $display("address == %0d",address);
				$display("PASSED");
			end
			
		end
	end
    endtask
	
	initial
	begin
		pc = 0;
		alu_out =2;
		IorD =0;
        #1;
             $display("-----------------------");
			 $display("pc == %0d",pc);
			 $display("alu_out == %0d",alu_out);
             $display("IorD == %0d",IorD);
            if(address !== (IorD ? alu_out : pc))
			begin
				$display("FAILED");
				$stop;
			end
			else
			begin
				$display("PASSED");
			end

		stimulus;
		#10;
        $finish;

	end

	initial begin
		$dumpfile("SIM/iord_mux.vcd");
		$dumpvars(0,iord_mux_tb);
	end
endmodule 

	
		
		
		
		
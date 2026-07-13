module memtoreg_mux_tb;

	reg [31:0] mdr_out,alu_out;
	reg MemtoReg;
	
	wire [31:0] write_data;
	
	memtoreg_mux uut (alu_out, mdr_out, MemtoReg, write_data);
	integer seed = 100;
	integer seed1 = 200;
	
	task stimulus ;
	begin
		repeat(20)
		begin
            #10;
			mdr_out  = $urandom(seed) ;
			alu_out  = $urandom(seed1);
			MemtoReg = $urandom %2;
            #1;
			
			$display("-----------------------");
			$display("alu_out == %0d",alu_out);
            $display("mdr_out == %0d",mdr_out);
            $display("MemtoReg == %0d",MemtoReg);
			#1;
		   if(write_data !== (MemtoReg ? mdr_out : alu_out))
			begin
                $display("write_data == %0d",write_data);
				$display("FAILED");
				$stop;
			end
			else
			begin
                $display("write_data == %0d",write_data);
				$display("PASSED");
			end
			
		end
	end
    endtask
	
	initial
	begin
		mdr_out = 0;
		alu_out =2;
		MemtoReg =0;
        #1;
             $display("-----------------------");
			 $display("alu_out == %0d",alu_out);
             $display("mdr_out == %0d",mdr_out);
             $display("MemtoReg == %0d",MemtoReg);
            if(write_data !== (MemtoReg ? mdr_out : alu_out))
			begin
                $display("write_data == %0d",write_data);
				$display("FAILED");
				$stop;
			end
			else
			begin
                $display("write_data == %0d",write_data);
				$display("PASSED");
			end

		stimulus;
		#10;
        $finish;

	end

	initial begin
		$dumpfile("SIM/memtoreg_mux.vcd");
		$dumpvars(0,memtoreg_mux_tb);
	end
endmodule 

	
		
		
		
		
module unified_memory_tb;
    parameter DATA_WIDTH = 32;
	parameter ADDRESS_WIDTH = 32;	
	parameter DEPTH = 1024;
	reg clk,reset;
	reg MemRead,MemWrite;
	reg [ADDRESS_WIDTH-1:0] address;
	reg [DATA_WIDTH-1:0] write_data;
	wire [DATA_WIDTH-1:0] read_data;
	
	unified_memory uut (clk,reset,MemRead,MemWrite,address,write_data,read_data);
	
	initial begin 
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	
	
	task initialize;
	begin
	 @(negedge clk)
		MemWrite = 1;
		MemRead = 0;
		address = 32'd138;
		store_addr[0] = address;
		write_data = 32'd345;
	// @(posedge clk )
	// #1;
	end 
	endtask
	
	integer i;
	reg [31:0] expected = 32'd0;
	task reset_task;
	begin
		@(negedge clk)
		reset = 0;
		@(posedge clk)
		#1;
		for(i=0;i<1024;i = i+1)
		begin
			if (expected == read_data && expected == uut.memory[i])
				$display("reset is working");
			else
			begin
				$display("reset is working");
				$stop;
			end
		end
		@(negedge clk)
		reset = 1;
	end
	endtask
	
	integer j =1;
	integer k = 0;
	reg [31:0] store_addr[0:19];
	integer channel;
	integer seed  = 200;
	task send_data;
		reg [31:0] reg1;
	begin
	// @(negedge clk)
		repeat(20)
		begin
            @(negedge clk)
            if({$random}%2)
            begin
                MemWrite =1;
                MemRead =0;
                address = ({$random}  % DEPTH)<<2;
                store_addr[j] = address;
                j = j+1;
                //channel = $fopen("data.txt");
                //$fdisplay(channel,address);
                //$fclose(channel);
                //$readmemb("data.txt",store_addr);
            end
            else if (k<j)
            begin
                MemWrite =0;
                MemRead =1;
                address = store_addr[k];
                k = k+1;
                //address = ($urandom  % DEPTH);
            end
            else
            begin
                MemWrite =1;
                MemRead  =0;
                address = ({$random  % DEPTH})<<2;
                store_addr[j] = address;
                j = j+1;
            end
                reg1 = $random(seed) ;
                // address = ($urandom  % DEPTH)<<2;
                write_data = reg1;
            @(posedge clk)
            #1;
                    $display("---------------------------");
                    $display("Address     = %0d", address);
                    $display("Index       = %0d", address[31:2]);
                    $display("Write Data  = %h", reg1);
                    $display("Memory Data = %h", uut.memory[address[31:2]]);
                    $display("read_data   = %h",read_data);
            if(MemWrite)
            begin
                if(reg1 == uut.memory[address[31:2]])
                $display("unified memory write is working at %0t",$time);
                else
                begin
                $display("unified memory write is not working at %0t",$time);
                $stop;
                end
            end
            else if (MemRead) 
            begin
                if(uut.memory[address[31:2]] == read_data)
                begin
                $display("unified memory read  is working at %0t",$time);
                end
                else
                begin
                $display("unified memory read is not working at %0t",$time);
                $stop;
                end
            end
        end
	end
	endtask
	
	
		
	initial begin
	
	reset_task;
    initialize;
	send_data;
	#10;
	$finish;
	end
	
	initial begin
	$dumpfile("unified_memory.vcd");
	$dumpvars(0,unified_memory_tb);
	end
	
endmodule

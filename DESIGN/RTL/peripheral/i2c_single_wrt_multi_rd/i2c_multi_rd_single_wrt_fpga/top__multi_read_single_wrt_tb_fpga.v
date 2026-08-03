`timescale 1ns/1ps
module tb_probe;
    reg clk = 0;
    reg rst = 1;
    reg we = 0;
    reg [3:0] addr_out = 0;
    reg [3:0] addr = 0;
    reg [31:0] wdata = 0;
    wire [7:0] rdata;
    wire err, busy;
    wire sda, scl;
	wire done;
   // wire [2:0] byte_cnt;

    pullup(sda);
     pullup(scl);

    i2c_top dut(
        .clk(clk), .rst(rst), .we(we), .addr(addr),.addr_out(addr_out) ,.wdata(wdata),
        .rdata(rdata),.err(err), .busy(busy),.done(done),.sda(sda),.scl(scl)
    );

    parameter SLAVE_ADDR = 7'h53;
     i2c_slave_model #(
        .SLAVE_ADDR(SLAVE_ADDR)
    )  slave (
        .scl(scl),
        .sda(sda)
    );

    reg [13*8:1] state;  
    integer i =0;
    always #5 clk = ~clk;

    integer toggles;
    initial toggles = 0;
    always @(scl) toggles = toggles + 1;

     always @(dut.i2c_block.state)
		case(dut.i2c_block.state)
			5'b000 : state = "IDLE";
			5'b001 : state = "START1";
			5'b010 : state = "START2";
			5'b011 : state = "SLAVE_ADDR_W";
			5'b100 : state = "WAIT_ACK1";
			5'b101 : state = "ACK1";
			5'b110 : state = "REG_ADDR";
			5'b111 : state = "WAIT_ACK2";
            5'd8   : state = "ACK2";
            5'd9   : state = "WRITEDATA";
            5'd10  : state = "WAIT_ACK3";
            5'd11  : state = "ACK3";
            5'd12  : state = "RESTART";
            5'd13  : state = "SLAVE_ADDR_R";
            5'd14  : state = "WAIT_ACK4";
            5'd15  : state = "ACK4";
            5'd16  : state = "READDATA";
            5'd17  : state = "WAIT_ACK5";
            5'd18  : state = "ACK5";
            5'd19  : state = "STOP1";
            5'd20  : state = "STOP2";
            5'd21  : state = "ERROR";


			default : state = "IDLE";
		endcase


    task write_data;
    begin
          // set slave addr = 7'h50, write op (rwbar=0)
        @(negedge clk); we=1; addr=7'h4; wdata = {24'd0, 7'h53, 1'b0}; @(negedge clk); we=0;
        // set tx_data (register pointer) = 8'hA0
        @(negedge clk); we=1; addr=7'h5; wdata = 32'h00000008; @(negedge clk); we=0;
        @(negedge clk); we=1; addr=7'h8; wdata = 32'h0000002D; @(negedge clk); we=0;
        // kick off transaction
        @(negedge clk); we=1; addr=7'h9; wdata = 32'h00000000; @(negedge clk); we=0;
        @(negedge clk); we=1; addr=7'h0; wdata = 32'h1; @(negedge clk); we=0;
    end
    endtask
    task read_data;
    begin
        @(negedge clk); we=1; addr=7'h4; wdata = {24'd0, 7'h53, 1'b1}; @(negedge clk); we=0;
        // set tx_data (register pointer) = 8'hA0
        @(negedge clk); we=1; addr=7'h5; wdata = 32'h00000000; @(negedge clk); we=0;
        @(negedge clk); we=1; addr=7'h8; wdata = 32'h0000002D; @(negedge clk); we=0;
        // kick off transaction
        @(negedge clk); we=1; addr=7'h9; wdata = 32'h00000001; @(negedge clk); we=0;
        @(negedge clk); we=1; addr=7'h0; wdata = 32'h1; @(negedge clk); we=0;
    end
    endtask

    initial begin
        #20 rst = 0;
        #20;
        // set slave addr = 7'h50, write op (rwbar=0)
        write_data;
         wait(done)
       // #20000;
        read_data;

        // Run for a generous window and report state
        wait(done)
        //#20000;
        $display("TIME=%0t busy=%b err=%b done = %0b scl_toggle_count=%0d rdata=%h", $time, busy, err, done,toggles, rdata);
        if (busy)
            $display("RESULT: STUCK - busy never cleared, transaction never completed");
        if (toggles == 0)
            $display("RESULT: SCL NEVER TOGGLED - clock generator never activated");
        $display("POWER_CTL = %h", slave.power_ctl);
        addr_out = 4'h0;

        $finish;
    end

    // initial begin
    // #200000;

//     for(i=0;i<4;i=i+1)
//         $display("memory[%0d] = %h", i, dut.i2c_block.memory[i]);
// end
    

    initial begin
        $dumpfile("i2c_top_tb.vcd");
        $dumpvars(0, tb_probe);
    end
endmodule
module i2c (
	input   clk, 
	//input   scl_hi,
    input   rst,
	input   we,
	input   phase_low,
    input   phase_high,
    input   phase_fall,
	input   phase_rise,
	input [3:0] addr,
	input [31:0] wdata,
	input [3:0] addr_out,
	//output reg [31:0] rdata,
	output  [7:0] rdata,
	output reg scl_trig,
	output reg sda_oe,
	output reg err,
	output reg busy,
	output reg done,
	input sda_in,
	input oled_control
    //input [2:0] byte_cnt
	);
	
    reg rwbar;
    reg [4:0] state;
	reg [7:0] tx_data;
	reg [6:0] slv_reg;
	reg [2:0] bit_cnt;
	reg [7:0] shift_reg;
    reg [6:0] slv_addr;
    reg [2:0] byte_cnt_reg,count;
    reg [7:0] memory[0:15];
	reg [7:0] data_reg;
	reg [7:0] command_reg;
	reg [7:0] init_cmd [0:30];
	reg [7:0] pix_mem [0:1023];
	reg [5:0] cmd_cnt;
	reg [9:0] pix_cnt;

    
	integer i;

	parameter TOTAL_CMD = 31,TOTAL_PIX = 1024;

	localparam IDLE         = 5'd0,
			   START1       = 5'd1,	
			   START2       = 5'd2,
			   SLAVE_ADDR_W = 5'd3,
			   WAIT_ACK1    = 5'd4,
			   ACK1         = 5'd5,
			   CONTROL_BYTE = 5'd6,
			   WAIT_ACK2    = 5'd7,
			   ACK2         = 5'd8,
			   WRITE_CMD    = 5'd9,
			   WAIT_ACK3    = 5'd10,
			   ACK3         = 5'd11,                                               
			   REG_ADDR     = 5'd12,
			   WAIT_ACK4    = 5'd13,
			   ACK4         = 5'd14,
			   WRITEDATA    = 5'd15,
			   WAIT_ACK5    = 5'd16,
			   ACK5         = 5'd17,  
			   RESTART      = 5'd18,
			   SLAVE_ADDR_R = 5'd19,
			   WAIT_ACK6    = 5'd20,
			   ACK6         = 5'd21,
			   READDATA     = 5'd22,
			   WAIT_ACK7    = 5'd23,
			   ACK7         = 5'd24,
			   STOP1        = 5'd25,
			   STOP2        = 5'd26,
			   ERROR        = 5'd27;
	
	reg we_d;

	always @(posedge clk or posedge rst) begin
		if (rst)
			we_d <= 1'b0;
		else
			we_d <= we;
	end

	wire we_pulse = we & ~we_d;

	assign rdata = memory[addr_out];

		initial begin
			// Display OFF
			init_cmd[0]  = 8'hAE;

			// Set Display Clock Divide Ratio
			init_cmd[1]  = 8'hD5;
			init_cmd[2]  = 8'h80;

			// Set Multiplex Ratio (1/64)
			init_cmd[3]  = 8'hA8;
			init_cmd[4]  = 8'h3F;

			// Set Display Offset
			init_cmd[5]  = 8'hD3;
			init_cmd[6]  = 8'h00;

			// Set Start Line = 0
			init_cmd[7]  = 8'h40;

			// Enable Charge Pump
			init_cmd[8]  = 8'h8D;
			init_cmd[9]  = 8'h14;

			// Segment Remap
			init_cmd[10] = 8'hA1;

			// COM Scan Direction (Remapped)
			init_cmd[11] = 8'hC8;

			// COM Pins Hardware Configuration
			init_cmd[12] = 8'hDA;
			init_cmd[13] = 8'h12;

			// Contrast Control
			init_cmd[14] = 8'h81;
			init_cmd[15] = 8'hCF;

			// Pre-charge Period
			init_cmd[16] = 8'hD9;
			init_cmd[17] = 8'hF1;

			// VCOMH Deselect Level
			init_cmd[18] = 8'hDB;
			init_cmd[19] = 8'h40;

			// Resume RAM Content Display
			init_cmd[20] = 8'hA4;

			// Normal Display (Not Inverted)
			init_cmd[21] = 8'hA6;

			// Horizontal Addressing Mode
			init_cmd[22] = 8'h20;
			init_cmd[23] = 8'h00;

			// Column Address
			init_cmd[24] = 8'h21;
			init_cmd[25] = 8'h00;
			init_cmd[26] = 8'h7F;

			// Page Address
			init_cmd[27] = 8'h22;
			init_cmd[28] = 8'h00;
			init_cmd[29] = 8'h07;

			// Display ON
			init_cmd[30] = 8'hAF;
		end
   

   initial  $readmemh("pixel_data.mem",pix_mem);
	
	always @(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			sda_oe   <= 0;
			done     <= 1'b0;
			scl_trig <= 0; 
			state    <= IDLE;
			busy     <= 0;
			err      <= 0;
			shift_reg<= 0;
			bit_cnt  <= 0;
			slv_addr <= 0;
			rwbar    <= 0;
			tx_data  <= 0;
			done     <= 0;
			byte_cnt_reg <= 0;
			count    <= 0;
			data_reg <= 0;
			command_reg <= 0;
			pix_cnt  <=0;
			cmd_cnt  <=0;
			for(i=0;i<16;i = i+1)
			memory[i] <= 0;
		end
		else begin
			
			if (we_pulse) begin
                case (addr)
                    4'h4:  begin slv_addr <= wdata[7:1]; rwbar <= wdata[0]; //rd_two <= wdata[8] 
					       end
					4'h5 : data_reg <= wdata[7:0];  //data to be written to the slave device
					4'h6 : command_reg <= wdata[7:0]; //command byte register
                    4'h8:  tx_data  <= wdata[7:0];  //register_address
                    4'h9:  byte_cnt_reg <= wdata[2:0];  //multi byte read count 
                    4'h0: begin
                        if (wdata[0] && !busy) begin
                            busy    <= 1'b1;
                            state   <= START1;
							err     <= 0;
							done    <= 0;
							cmd_cnt <=0; 
							pix_cnt <=0; 
							count   <=0;
                        end
                    end
                    default: begin end
                endcase
            end
			
			if (busy) begin
				case(state)
					START1 : begin
						sda_oe <= 0;
						scl_trig <= 1'b1;
						state <= START2;
					end
					
					START2 : begin
						if(phase_high)
						begin
							sda_oe    <= 1'b1;
							shift_reg <= {slv_addr,1'b0};
							bit_cnt   <= 3'd7;
							state     <= SLAVE_ADDR_W;
						end
					end
					
					SLAVE_ADDR_W : begin
					
						if (phase_low)
						begin
							sda_oe <= ~shift_reg[7];
						end
						
						else if(phase_rise)
						begin
							shift_reg <= {shift_reg[6:0], 1'b0};
							if (bit_cnt == 3'd0) state <= WAIT_ACK1;
                            else bit_cnt <= bit_cnt - 1;
						end
						
					end
					
					WAIT_ACK1 : begin
						if(phase_low)
					     state <= ACK1;
						end
					
					ACK1 : begin
						sda_oe <= 0;
						if(phase_high) begin
							if (sda_in)
								state <= ERROR;
							else begin
								if(oled_control)
								begin
									shift_reg <= command_reg;
									bit_cnt   <= 3'd7;
									state     <= CONTROL_BYTE;
								end
								else
								begin
									shift_reg <= tx_data;
									bit_cnt   <= 3'd7;
									state     <= REG_ADDR;
								end
								
							end
						end
					end

					CONTROL_BYTE : begin
						if(phase_low)
						begin
							sda_oe <= ~shift_reg[7];
							if(bit_cnt == 3'd0) state <= WAIT_ACK2;
							else bit_cnt <= bit_cnt-1;
						end
						else if(phase_rise)  
						begin
							shift_reg <= {shift_reg[6:0],1'b0};
						end
					end
					
					WAIT_ACK2 : begin
						if(phase_low)
					     state <= ACK2;
						end
					
					ACK2 : begin
					    sda_oe <= 0;
						if(phase_high)
						begin
							if(sda_in)
							   state <= ERROR;
							else
							begin
								bit_cnt   <= 3'd7;
								if(command_reg == 8'h00)
								begin
									shift_reg <= init_cmd[0];
									state     <= WRITE_CMD;
								end
								else if(command_reg == 8'h40)
								begin
									shift_reg <= pix_mem[0];
									state     <= WRITEDATA;
								end
								else state <= ERROR;
							end
						end
						end

					WRITE_CMD : begin
						if(phase_low)
						begin
							sda_oe <= ~shift_reg[7];
							if (bit_cnt == 3'd0) state <= WAIT_ACK3;
                            else bit_cnt <= bit_cnt - 1;
						end
						else if(phase_rise)
						begin
							shift_reg <= {shift_reg[6:0], 1'b0};
							
						end
					end

					WAIT_ACK3 : begin
						if(phase_low)
					     state <= ACK3;
						end
					
					ACK3 : begin
						sda_oe <= 1'b0;
						if(phase_high)
						begin
						   if(sda_in)
								state <= ERROR;
						    else if (cmd_cnt == TOTAL_CMD-1)
								state <= STOP1;
							else
							begin
								cmd_cnt   <= cmd_cnt +1;
								bit_cnt   <= 3'd7;
								shift_reg <= init_cmd[cmd_cnt+1];
								state     <= WRITE_CMD;
							end
						end
					end

					REG_ADDR : begin
					    if(phase_low)
						begin
							sda_oe <= ~shift_reg[7];
							if (bit_cnt == 3'd0) state <= WAIT_ACK4;
                            else bit_cnt <= bit_cnt - 1;
						end
						else if(phase_rise)
						begin
							shift_reg <= {shift_reg[6:0], 1'b0};
							
						end
					end
					
					WAIT_ACK4 : begin
						if(phase_low)
					     state <= ACK4;
						end
					
					ACK4 : begin
					    sda_oe <= 0;
						if(phase_high)
						begin
							if(sda_in)
							   state <= ERROR;
							else
							begin
								if (rwbar) begin
									state <= RESTART;
								end
								else begin
									bit_cnt   <= 3'd7;
									shift_reg <= pix_mem[0];
									state     <= WRITEDATA;
								end
							end
						end
					end
					
					WRITEDATA : begin
						if(phase_low)
						begin
							sda_oe <= ~shift_reg[7];
							if (bit_cnt == 3'd0) state <= WAIT_ACK5;
                            else bit_cnt <= bit_cnt - 1;
						end
						else if(phase_rise)
						begin
							shift_reg <= {shift_reg[6:0], 1'b0};
						end
					end

					WAIT_ACK5 : begin
						if(phase_low)
					     state <= ACK5;
						end
					
					ACK5 : begin
						sda_oe <= 1'b0;
						if(phase_high)
						begin
						   if(sda_in)
								state <= ERROR;
						    else if (pix_cnt == TOTAL_PIX-1)
								state <= STOP1;
							else
							begin
								pix_cnt   <= pix_cnt +1;
								bit_cnt   <= 3'd7;
								shift_reg <= pix_mem[pix_cnt+1];
								state     <= WRITEDATA;
							end
						end

					end
					RESTART : begin
						if(phase_high)
						begin
							sda_oe    <= 1'b1;
							shift_reg <= {slv_addr,rwbar};
							bit_cnt   <= 3'd7;
							state     <= SLAVE_ADDR_R;
						end
					end
					
					SLAVE_ADDR_R : begin
						
						if (phase_low)
						begin
							sda_oe <= ~shift_reg[7];
							if (bit_cnt == 3'd0) state <= WAIT_ACK6;
                            else bit_cnt <= bit_cnt - 1;
						end
						else if(phase_rise)
						begin
							shift_reg <= {shift_reg[6:0], 1'b0};
							
						end
					end
					
					WAIT_ACK6 : begin
						if(phase_low)
					     state <= ACK6;
						end
					
					ACK6 : begin
						sda_oe <= 1'b0;
						if(phase_high)
						begin
						   state <= sda_in ? ERROR :READDATA;
						   bit_cnt <= 3'd7;
						end
					end
					
					READDATA : begin
					    if(phase_high)
						begin
						    shift_reg <= {shift_reg[6:0], sda_in};
							if (bit_cnt == 3'd0) state <= WAIT_ACK7;
                            else bit_cnt <= bit_cnt - 1;
						end
						 if (phase_fall&& bit_cnt != 3'd0)
        					sda_oe <= 1'b0;   
					end
					
					WAIT_ACK7:
					begin
						if (phase_low) begin
							if (count == byte_cnt_reg-1)
								sda_oe <= 1'b0;   // NACK
							else
								sda_oe <= 1'b1;   // ACK

							state <= ACK7;
						end
					end
						
					ACK7 : begin

						// Release SDA
						// Finish ACK cycle
						if (phase_high) begin
							memory[count] <= shift_reg;

							if (count == byte_cnt_reg-1)
								state <= STOP1;
							else begin
								count   <= count + 1;
								bit_cnt <= 3'd7;
								shift_reg <= 8'd0;
								state   <= READDATA;
							end
						end
					end
				
				
			        STOP1 : begin
						if(phase_rise)
							sda_oe <= 1;
						else if (phase_high)
						begin
							state <= STOP2;
							sda_oe <= 0;
						end
					end
					
					STOP2 : begin
						if (phase_high)
						begin
							busy  <= 1'b0;
							done  <= 1'b1; 
							state <= IDLE;
							scl_trig <= 0;
						end
					end
					
					ERROR : begin
						err <= 1;
						sda_oe <= 1'b0;
						state <= STOP1;
					end
				default : state <= IDLE;
			endcase
		    end
		end
	end
endmodule
	
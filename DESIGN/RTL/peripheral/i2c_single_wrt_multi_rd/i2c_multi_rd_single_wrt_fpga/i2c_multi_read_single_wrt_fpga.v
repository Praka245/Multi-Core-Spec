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
	input sda_in
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
    
	integer i;

	localparam IDLE         = 5'd0,
			   START1       = 5'd1,	
			   START2       = 5'd2,
			   SLAVE_ADDR_W = 5'd3,
			   WAIT_ACK1    = 5'd4,
			   ACK1         = 5'd5,
			   REG_ADDR     = 5'd6,
			   WAIT_ACK2    = 5'd7,
			   ACK2         = 5'd8,
			   WRITEDATA    = 5'd9,
			   WAIT_ACK3    = 5'd10,
			   ACK3         = 5'd11,  
			   RESTART      = 5'd12,
			   SLAVE_ADDR_R = 5'd13,
			   WAIT_ACK4    = 5'd14,
			   ACK4         = 5'd15,
			   READDATA     = 5'd16,
			   WAIT_ACK5    = 5'd17,
			   ACK5         = 5'd18,
			   STOP1        = 5'd19,
			   STOP2        = 5'd20,
			   ERROR        = 5'd21;
	
	reg we_d;

always @(posedge clk or posedge rst) begin
    if (rst)
        we_d <= 1'b0;
    else
        we_d <= we;
end

wire we_pulse = we & ~we_d;

assign rdata = memory[addr_out];
   
	
	always @(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			sda_oe   <= 0;
//			rdata    <= 0;
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
			for(i=0;i<16;i = i+1)
			memory[i] <= 0;
		end
		else begin
			
			if (we_pulse) begin
                case (addr)
                    4'h4:  begin slv_addr <= wdata[7:1]; rwbar <= wdata[0]; //rd_two <= wdata[8] 
					       end
					4'h5 : data_reg <= wdata[7:0];  //data to be written to the slave device
                    4'h8:  tx_data  <= wdata[7:0];  //register_address
                    4'h9:  byte_cnt_reg <= wdata[2:0];  //multi byte read count 
                    4'h0: begin
                        if (wdata[0] && !busy) begin
                            busy    <= 1'b1;
                            state   <= START1;
							err     <= 0;
							done    <= 0;
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
								shift_reg <= tx_data;
								bit_cnt   <= 3'd7;
								state     <= REG_ADDR;
							end
						end
					end
					
					REG_ADDR : begin
					    if(phase_low)
						begin
							sda_oe <= ~shift_reg[7];
							if (bit_cnt == 3'd0) state <= WAIT_ACK2;
                            else bit_cnt <= bit_cnt - 1;
						end
						else if(phase_rise)
						begin
							shift_reg <= {shift_reg[6:0], 1'b0};
							
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
								if (rwbar) begin
									state <= RESTART;
								end
								else begin
									bit_cnt   <= 3'd7;
									shift_reg <= data_reg;
									state     <= WRITEDATA;
								end
							end
						end
						  // state <= sda_in ? ERROR : rwbar ? RESTART : WRITEDATA;
						end
					
					WRITEDATA : begin
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
						   state <= sda_in ? ERROR : STOP1;
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
							if (bit_cnt == 3'd0) state <= WAIT_ACK4;
                            else bit_cnt <= bit_cnt - 1;
						end
						 if (phase_fall&& bit_cnt != 3'd0)
        					sda_oe <= 1'b0;   
					end
					
					WAIT_ACK5:
					begin
						if (phase_low) begin
							if (count == byte_cnt_reg-1)
								sda_oe <= 1'b0;   // NACK
							else
								sda_oe <= 1'b1;   // ACK

							state <= ACK5;
						end
					end
						
					ACK5 : begin

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
	
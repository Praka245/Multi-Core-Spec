// ============================================================================
// Module Name: i2c_slave_model
// Description: Synthesizable I2C Slave with dynamic sensor_data input.
//              Uses dedicated asynchronous flag detectors for START/STOP 
//              conditions so that `state` and registers have strictly ONE driver.
// ============================================================================
module i2c_slave_model
#(
    parameter SLAVE_ADDR = 7'h53  // 7-bit I2C Slave Address
)
(
    input        scl,          // I2C Clock Line
    inout        sda      // I2C Data Line   // Dynamic 8-bit sensor input (Switches)
);

  reg [7:0] reg_addr;
  reg [7:0] power_ctl;
  reg [7:0] data_format;
  // Open-drain output driver for SDA
  reg sda_drive;
  assign sda = sda_drive ? 1'b0 : 1'bz;

  reg bus_ready;   // goes high once scl/sda are first seen at a clean idle '1'
                    // (masks the simulation-only X glitch before the master's
                    // own reset settles -- a real bus never starts at X)
  initial begin
    state      = 3'd0;
    bit_idx    = 3'd7;
    start_flag = 1'b0;
    stop_flag  = 1'b0;
    matched    = 1'b0;
    is_read    = 1'b0;
    sda_drive  = 1'b0;
    bus_ready  = 1'b0;
    power_ctl  = 8'h00;
    data_format = 8'h00;
  end

  always @(posedge scl or posedge sda)
    if (scl === 1'b1 && sda === 1'b1) bus_ready <= 1'b1;

  // FSM State Encoding
  localparam ST_IDLE     = 3'd0;
  localparam ST_ADDR     = 3'd1; 
  localparam ST_ADDR_ACK = 3'd2; 
  localparam ST_WR_BYTE  = 3'd3; 
  localparam ST_WR_ACK   = 3'd4; 
  localparam ST_RD_BYTE  = 3'd5; 
  localparam ST_RD_ACK   = 3'd6; 
  localparam ST_WR_DATA  = 3'd7;
  localparam ST_WR_DATA_ACK = 4'd8;
  reg [3:0] state;
  reg [2:0] bit_idx;      
  reg [7:0] shift_in;     
  reg [7:0] cur_read_byte;
  reg       is_read;       
  reg       matched;       

  // ==========================================================================
  // START & STOP CONDITION DETECTION (Dedicated single-driver flip-flops)
  // ==========================================================================
  reg start_flag;
  reg stop_flag;

  // Set start_flag on falling edge of SDA while SCL is high; clear when SCL goes low
  always @(negedge sda or negedge scl) begin
    if (!scl || !bus_ready)
      start_flag <= 1'b0;
    else
      start_flag <= 1'b1;
  end

  // Set stop_flag on rising edge of SDA while SCL is high; clear when SCL goes low
  always @(posedge sda or negedge scl) begin
    if (!scl || !bus_ready)
      stop_flag <= 1'b0;
    else
      stop_flag <= 1'b1;
  end

  wire start_or_stop = start_flag | stop_flag;

  // ==========================================================================
  // MAIN STATE MACHINE (Single-driver logic on posedge SCL or START/STOP async)
  // ==========================================================================
  always @(posedge scl or posedge start_or_stop) begin
    if (start_or_stop) begin
      if (stop_flag) begin
        state    <= ST_IDLE;
        bit_idx  <= 3'd7;
        matched  <= 1'b0;
      end 
      else if (start_flag) begin
        state    <= ST_ADDR;
        bit_idx  <= 3'd7;
        shift_in <= 8'h00;
        matched  <= 1'b0;
      end
    end 
    else begin
      // Synchronous SCL clock domain transitions
      case (state)
        ST_ADDR: begin
          shift_in <= {shift_in[6:0], sda};
          if (bit_idx == 3'd0) begin
            is_read  <= sda;
            matched <= ({shift_in[6:0], sda} >> 1) == SLAVE_ADDR;
            state    <= ST_ADDR_ACK;
          end
          else begin
            bit_idx  <= bit_idx - 1'b1;
          end
        end

        ST_ADDR_ACK: begin
          if (matched) begin
            if (is_read) begin
              case (reg_addr)

              8'h00: cur_read_byte <= 8'h04;
              8'h01: cur_read_byte <= 8'h10;
              8'h02: cur_read_byte <= 8'h55;
              8'h03: cur_read_byte <= 8'hAA;
              8'h2D: cur_read_byte <= power_ctl;
              8'h31: cur_read_byte <= data_format;
              

              default: cur_read_byte <= 8'h00;

            endcase 
              state         <= ST_RD_BYTE;
              bit_idx       <= 3'd7;
            end
            else begin
              state   <= ST_WR_BYTE;
              bit_idx <= 3'd7;
            end
          end
          else begin
            state <= ST_IDLE;
          end
        end

        ST_WR_BYTE:
        begin
            shift_in <= {shift_in[6:0], sda};

            if (bit_idx == 0) begin
                reg_addr <= {shift_in[6:0], sda};   // Save register address
                state <= ST_WR_ACK;
            end
            else
                bit_idx <= bit_idx - 1;
        end

         ST_WR_ACK:
            begin
                bit_idx <= 3'd7;
                state   <= ST_WR_DATA;
            end
          ST_WR_DATA:
          begin
              shift_in <= {shift_in[6:0], sda};

              if(bit_idx==0)
              begin

                  case(reg_addr)

                      8'h2D:
                          power_ctl <= {shift_in[6:0],sda};

                      8'h31:
                          data_format <= {shift_in[6:0],sda};

                      default:
                          ;

                  endcase

                  state <= ST_WR_DATA_ACK;

              end
              else
                  bit_idx <= bit_idx - 1;

          end
          ST_WR_DATA_ACK: 
          begin
              state <= ST_IDLE;
          end

          ST_RD_BYTE: begin
          if (bit_idx == 3'd0) begin
            state <= ST_RD_ACK;
          end
          else begin
            bit_idx <= bit_idx - 1'b1;
          end
        end

//        ST_RD_ACK: begin
//     if (sda) begin
//         // Master NACK
//         state <= ST_IDLE;
//     end
//     else begin
//         state   <= ST_RD_BYTE;
//         bit_idx <= 3'd7;
//     end
// end

ST_RD_ACK: begin
    if (sda) begin
        // Master NACK
        state <= ST_IDLE;
    end
    else begin
        // Increment register pointer
        reg_addr <= reg_addr + 1'b1;

        // Load next register
        case(reg_addr + 1'b1)
            8'h00: cur_read_byte <= 8'h04;
            8'h01: cur_read_byte <= 8'h10;
            8'h02: cur_read_byte <= 8'h55;
            8'h03: cur_read_byte <= 8'hAA;
            default: cur_read_byte <= 8'h00;
        endcase

        bit_idx <= 3'd7;
        state   <= ST_RD_BYTE;
    end
end

        default: state <= ST_IDLE;
      endcase
    end
  end

  // ==========================================================================
  // SDA OUTPUT CONTROL (Single-driver logic on negedge SCL)
  // ==========================================================================
  always @(negedge scl or posedge start_or_stop) begin
    if (start_or_stop) begin
      sda_drive <= 1'b0; // Release line on START/STOP
    end 
    else begin
      case (state)
        ST_ADDR_ACK: sda_drive <= matched;
        ST_WR_ACK:   sda_drive <= matched;
        ST_RD_BYTE:  sda_drive <= !cur_read_byte[bit_idx];
        ST_WR_DATA_ACK: sda_drive <= 1'b1;
        default:     sda_drive <= 1'b0;
      endcase
    end
  end

endmodule
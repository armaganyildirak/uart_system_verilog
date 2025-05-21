module uart_rx (
    input wire clk,
    input wire rst_n,
    input wire rx,
    input wire baud_tick,
    output reg [7:0] rx_data,
    output reg data_valid
);

    // States for RX state machine
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    
    reg [1:0] state;
    reg [2:0] bit_idx;        // We need to count 0-7 (8 bits)
    reg [7:0] rx_shift_reg;   // Store the actual data bits
    
    // Synchronize the rx input
    reg rx_sync1, rx_sync2;
    wire rx_i;
    
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end
    
    assign rx_i = rx_sync2;  // Synchronized input

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data_valid <= 0;
            rx_data <= 0;
            bit_idx <= 0;
            rx_shift_reg <= 0;
        end else begin
            // Default value for data_valid
            data_valid <= 0;
            
            case (state)
                IDLE: begin
                    if (!rx_i) begin // Start bit detected
                        state <= START;
                    end
                end
                
                START: begin
                    if (baud_tick) begin
                        // Middle of the start bit
                        if (!rx_i) begin // Confirm it's still low
                            state <= DATA;
                            bit_idx <= 0;
                            rx_shift_reg <= 0; // Clear shift register
                        end else begin
                            // False start, go back to idle
                            state <= IDLE;
                        end
                    end
                end
                
                DATA: begin
                    if (baud_tick) begin
                        // Sample in the middle of each data bit
                        rx_shift_reg[bit_idx] <= rx_i;  // LSB first
                        
                        if (bit_idx == 7) begin
                            // Received all 8 data bits
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end
                end
                
                STOP: begin
                    if (baud_tick) begin
                        // Middle of the stop bit
                        if (rx_i) begin // Verify stop bit is high
                            rx_data <= rx_shift_reg;
                            data_valid <= 1; // Data is valid for one cycle
                        end
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
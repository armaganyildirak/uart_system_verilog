module uart_tx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    input  wire       baud_tick,
    output reg        tx,
    output reg        busy,
    output reg        fifo_rd_en
);

    // State machine states
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam SENDING = 2'b10;
    
    reg [1:0] state;
    reg [3:0] bit_idx;  // Bits 0-7 data, 8 stop bit
    reg [7:0] data_buffer;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
             // Idle state is high
            tx <= 1;
            busy <= 0;
            fifo_rd_en <= 0;
            bit_idx <= 0;
            data_buffer <= 0;
            state <= IDLE;
        end else begin
            // Default state for fifo_rd_en
            fifo_rd_en <= 0;
            
            case (state)
                IDLE: begin
                    tx <= 1; // Ensure idle state is high
                    if (tx_start && !busy) begin
                        fifo_rd_en <= 1; // Request data from FIFO
                        state <= LOAD;
                        busy <= 1;
                    end
                end
                
                LOAD: begin
                    // Data is now available from FIFO after one cycle
                    data_buffer <= tx_data;  // Store the data
                    tx <= 0;                 // Start bit
                    bit_idx <= 0;
                    state <= SENDING;
                end
                
                SENDING: begin
                    if (baud_tick) begin
                        if (bit_idx < 8) begin
                            // Send data bits (LSB first)
                            tx <= data_buffer[bit_idx];
                            bit_idx <= bit_idx + 1;
                        end else if (bit_idx == 8) begin
                            // Send stop bit
                            tx <= 1;
                            bit_idx <= bit_idx + 1;
                        end else begin
                            // Transmission complete
                            tx <= 1;  // Keep line high when idle
                            busy <= 0;
                            state <= IDLE;
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
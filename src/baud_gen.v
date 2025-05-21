module baud_gen (
    input  wire clk,
    input  wire rst_n,
    output reg  baud_tick
);

    // For 100MHz clock and 9600 baud rate:
    // 100MHz / 9600 = 10,416.67 cycles per bit
    // Using 5208 for half bit period (to sample in the middle)
    localparam BAUD_DIV = 5208; 
    reg [12:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            baud_tick <= 0;
        end else if (cnt == BAUD_DIV - 1) begin
            cnt <= 0;
            baud_tick <= 1;
        end else begin
            cnt <= cnt + 1;
            baud_tick <= 0;
        end
    end
endmodule
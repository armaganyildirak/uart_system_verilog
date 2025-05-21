module uart_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  tx_data_in,
    input  wire        tx_wr_en,
    output wire        tx_full,
    output wire        tx,
    input  wire        rx,
    output wire        rx_data_valid,
    output wire [7:0]  rx_data_out,
    output wire        rx_empty,
    input  wire        rx_rd_en      // Input to control RX FIFO read
);

    wire baud_tick;
    wire tx_fifo_empty;
    wire tx_fifo_rd_en;
    wire tx_busy;
    wire [7:0] tx_fifo_data_out;

    wire rx_fifo_wr_en;
    wire [7:0] rx_fifo_data_in;
    wire rx_data_valid_internal;

    // Baud rate generator
    baud_gen baud_inst (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );

    // TX FIFO
    fifo #(.WIDTH(8), .DEPTH(16)) tx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(tx_wr_en),
        .rd_en(tx_fifo_rd_en),
        .data_in(tx_data_in),
        .data_out(tx_fifo_data_out),
        .empty(tx_fifo_empty),
        .full(tx_full),
        .count()
    );

    // UART Transmitter
    uart_tx uart_tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(~tx_fifo_empty),  // Start when there's data in the FIFO
        .tx_data(tx_fifo_data_out),
        .baud_tick(baud_tick),
        .tx(tx),
        .busy(tx_busy),
        .fifo_rd_en(tx_fifo_rd_en)
    );

    // UART Receiver
    uart_rx uart_rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .baud_tick(baud_tick),
        .rx_data(rx_fifo_data_in),
        .data_valid(rx_data_valid_internal)
    );

    // RX FIFO
    fifo #(.WIDTH(8), .DEPTH(16)) rx_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(rx_data_valid_internal),
        .rd_en(rx_rd_en),
        .data_in(rx_fifo_data_in),
        .data_out(rx_data_out),
        .empty(rx_empty),
        .full(),
        .count()
    );

    assign rx_data_valid = rx_data_valid_internal;

endmodule
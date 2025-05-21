module tb_uart_top;
    reg clk;
    reg rst_n;
    reg [7:0] tx_data_in;
    reg tx_wr_en;
    wire tx_full;
    wire tx;
    wire rx_data_valid;
    wire [7:0] rx_data_out;
    wire rx_empty;
    reg rx_rd_en;  // Control signal for RX FIFO read

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Loopback connection for testing
    // Connect TX directly to RX
    uart_top uart_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data_in(tx_data_in),
        .tx_wr_en(tx_wr_en),
        .tx_full(tx_full),
        .tx(tx),
        .rx(tx),  // This is the key loopback connection - rx is connected to tx
        .rx_data_valid(rx_data_valid),
        .rx_data_out(rx_data_out),
        .rx_empty(rx_empty),
        .rx_rd_en(rx_rd_en)
    );

    // Dump waveforms for debugging
    initial begin
        $dumpfile("uart_wave.vcd");
        $dumpvars(0, tb_uart_top);
        
        // Initialize signals
        rst_n = 0;
        tx_data_in = 0;
        tx_wr_en = 0;
        rx_rd_en = 0;
        
        // Reset sequence
        #100; 
        rst_n = 1;
        #100;
        
        // Send a test byte (0x55)
        tx_data_in = 8'h55;
        tx_wr_en = 1;
        #10 tx_wr_en = 0;
        
        // Wait for transmission and reception to complete (calculate based on baud rate)
        // At 9600 baud, one bit takes ~104us, so 10 bits (start + 8 data + stop) = ~1.04ms
        // Add some margin
        #2000000;
        
        // Read from RX FIFO
        if (!rx_empty) begin
            rx_rd_en = 1;
            #10 rx_rd_en = 0;
            #10;
            $display("Received data: 0x%h", rx_data_out);
        end else begin
            $display("ERROR: RX FIFO is empty!");
        end
        
        // Run for a bit longer and finish        
        #1000000;
    end

endmodule
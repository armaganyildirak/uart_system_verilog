module fifo #(parameter WIDTH = 8, DEPTH = 16) (
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out,
    output wire empty,
    output wire full,
    output reg [$clog2(DEPTH):0] count
);

    reg [WIDTH-1:0] mem[0:DEPTH-1];
    reg [$clog2(DEPTH)-1:0] rd_ptr;
    reg [$clog2(DEPTH)-1:0] wr_ptr;

    assign empty = (count == 0);
    assign full = (count == DEPTH);

    // Initialize data_out to avoid X propagation
    initial begin
        data_out = 0;
        rd_ptr = 0;
        wr_ptr = 0;
        count = 0;
    end

    // Update data_out value
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 0;
        end else if (!empty) begin
            data_out <= mem[rd_ptr];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
            count <= 0;
        end else begin
            // Handle write
            if (wr_en && (!full || rd_en)) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= (wr_ptr == DEPTH-1) ? 0 : wr_ptr + 1;
                
                if (!rd_en || empty)
                    count <= count + 1;
            end
            
            // Handle read
            if (rd_en && !empty) begin
                rd_ptr <= (rd_ptr == DEPTH-1) ? 0 : rd_ptr + 1;
                
                if (!wr_en)
                    count <= count - 1;
            end
        end
    end
endmodule
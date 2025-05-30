module top (
    input wire i_clk,
    output logic o_tx
);

    logic rst;

    logic fifo_ren;
    logic fifo_wen;
    logic [7:0] fifo_wdata;
    logic [7:0] fifo_rdata;
    logic fifo_full;
    logic fifo_empty;

    core #(
        .MEM_DEPTH(8*1024)
    ) core_inst (
        .i_clk(i_clk),
        .i_rst(rst),
        .o_ebreak(),

        .o_uart_en(fifo_wen),
        .o_uart_data(fifo_wdata)
    );

    fifo #(
        .DEPTH(64)
    ) fifo_inst (
        .i_clk(i_clk),
        .i_rst(rst),
        .i_ren(fifo_ren),
        .i_wen(fifo_wen),
        .i_wdata(fifo_wdata),
        .o_rdata(fifo_rdata),
        .o_full(fifo_full),
        .o_empty(fifo_empty)
    );

    uart_tx #(
        .CLK_FREQ(100000000),
        .UART_FREQ(115200)
    ) uart_inst (
        .i_clk(i_clk),
        .i_rst(rst),
        .i_data(fifo_rdata),
        .i_data_valid(!fifo_empty),
        .o_done(fifo_ren),
        .o_tx(o_tx)
    );

    logic [1:0] x;
    always_ff @(posedge i_clk) begin
        if (x != 2'b11) x <= x + 1;
    end
    assign rst = x != 2'b11;

endmodule

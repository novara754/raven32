module top_tb;

    vlog_tb_utils vtu ();

    logic clk;
    logic tx;

    top dut (
        .i_clk(clk),
        .o_uart_tx(tx)
    );

    always #41.66666666666 clk = !clk;

    initial #10000000 $finish;

endmodule

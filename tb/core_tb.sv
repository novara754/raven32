module core_tb;
    vlog_tb_utils vtu ();

    logic clk;
    logic rst;

    core dut (
        .i_clk(clk),
        .i_rst(rst)
    );

    logic [1024:0] firmware;
    initial begin
        if($value$plusargs("firmware=%s", firmware)) begin
            $readmemh(firmware, dut.inst_mem.mem);
        end

        rst = 1;
        #50;
        rst = 0;
        #5000
        $finish;
    end

    always begin
        #10 clk = !clk;
    end

endmodule

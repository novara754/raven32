module core_tb;
    vlog_tb_utils vtu ();

    logic clk;
    logic rst;
    logic ebreak;

    core #(
        .MEM_DEPTH(1024 * 1024)
    ) dut (
        .i_clk(clk),
        .i_rst(rst),
        .o_ebreak(ebreak)
    );

    logic [1024:0] firmware;
    initial begin
        if($value$plusargs("firmware=%s", firmware)) begin
            $readmemh(firmware, dut.inst_mem.mem);
            $readmemh(firmware, dut.data_mem.mem);
        end

        rst = 1;
        #50;
        rst = 0;

        // timeout
        #1000000;
        $display("Timeout...");
        $finish;
    end

    always begin
        #10 clk = !clk;
    end

    always_ff @(posedge clk) begin
        if (dut.m_mem_wen && dut.m_alu_res == 32'h10000000)
            $write("%c", dut.m_mem_wdata[7:0]);

        if (ebreak) begin
            $display("EBREAK");
            $finish;
        end
    end
endmodule

`default_nettype none

module register_file (
    input i_clk,
    input i_rst,

    input i_wen,
    input [4:0] i_waddr,
    input [31:0] i_wdata,

    input [4:0] i_raddr1,
    input [4:0] i_raddr2,

    output logic [31:0] o_rdata1,
    output logic [31:0] o_rdata2
);

    logic [31:0] mem [0:31];

    always_ff @(negedge i_clk) begin
        if (i_rst)
            for (int i = 0; i < 32; i++)
                mem[i] <= 0;
        else if (i_wen)
            mem[i_waddr] <= i_wdata;
    end

    assign o_rdata1 = (i_raddr1 == 0) ? 0 : mem[i_raddr1];
    assign o_rdata2 = (i_raddr2 == 0) ? 0 : mem[i_raddr2];

endmodule

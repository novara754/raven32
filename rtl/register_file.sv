`default_nettype none

module register_file (
    input wire i_clk,

    input wire i_wen,
    input wire [4:0] i_waddr,
    input wire [31:0] i_wdata,

    input wire [4:0] i_raddr1,
    input wire [4:0] i_raddr2,

    output logic [31:0] o_rdata1,
    output logic [31:0] o_rdata2
);

    logic [31:0] mem [0:31];

    always_ff @(negedge i_clk) begin
        if (i_wen)
            mem[i_waddr] <= i_wdata;
    end

    assign o_rdata1 = (i_raddr1 == 0) ? 0 : mem[i_raddr1];
    assign o_rdata2 = (i_raddr2 == 0) ? 0 : mem[i_raddr2];

endmodule

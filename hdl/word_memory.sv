`default_nettype none

module word_memory #(
    parameter DEPTH = 10*1024
) (
    input i_clk,
    input i_rst,

    input i_wen,
    input [31:0] i_waddr,
    input [31:0] i_wdata,

    input [31:0] i_raddr,

    output logic [31:0] o_rdata
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    logic [31:0] mem [0:DEPTH-1];

    always_ff @(posedge i_clk) begin
        if (i_rst)
            for (int i = 0; i < DEPTH; i++)
                mem[i] <= 0;
        else if (i_wen)
            mem[i_waddr[2 +: ADDR_WIDTH]] <= i_wdata;
    end

    assign o_rdata = mem[i_raddr[2 +: ADDR_WIDTH]];

endmodule

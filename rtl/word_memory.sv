`default_nettype none

module word_memory #(
    parameter DEPTH = 10*1024
) (
    input wire i_clk,

    input wire i_wen,
    // warns about not all bits being used
    /* verilator lint_off UNUSEDSIGNAL */
    input wire [31:0] i_waddr,
    input wire [31:0] i_wdata,

    input wire [31:0] i_raddr,
    /* verilator lint_on UNUSEDSIGNAL */

    output logic [31:0] o_rdata
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    logic [31:0] mem [0:DEPTH-1];
    initial $readmemh("firmware.hex", mem);

    always_ff @(posedge i_clk) begin
        if (i_wen)
            mem[i_waddr[2 +: ADDR_WIDTH]] <= i_wdata;
    end

    assign o_rdata = mem[i_raddr[2 +: ADDR_WIDTH]];

endmodule

`default_nettype none

module ram #(
    parameter DEPTH = 10*1024
) (
    input i_clk,
    input i_rst,

    input i_wen,
    input [31:0] i_waddr,
    input [31:0] i_wdata,

    input [31:0] i_raddr,
    // 0 = byte
    // 1 = word
    input i_rwidth,

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

    logic [31:0] rdata;
    assign rdata = mem[i_raddr[2 +: ADDR_WIDTH]];

    always_comb begin
        case (i_rwidth)
            1'b0: case (i_raddr[1:0])
                2'b00: o_rdata = {{24{rdata[7]}}, rdata[7:0]};
                2'b01: o_rdata = {{24{rdata[15]}}, rdata[15:8]};
                2'b10: o_rdata = {{24{rdata[23]}}, rdata[23:16]};
                2'b11: o_rdata = {{24{rdata[31]}}, rdata[31:24]};
            endcase
            1'b1: o_rdata = rdata;
        endcase
    end

endmodule

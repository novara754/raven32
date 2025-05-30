module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 32
) (
    input wire i_clk,
    input wire i_rst,

    input wire i_ren,
    input wire i_wen,
    input wire [WIDTH-1:0] i_wdata,

    output logic [WIDTH-1:0] o_rdata,
    output logic o_full,
    output logic o_empty
);

    localparam PTR_WIDTH = $clog2(DEPTH);

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    logic [PTR_WIDTH:0] waddr_q, waddr_d;
    logic [PTR_WIDTH:0] raddr_q, raddr_d;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            for (int i = 0; i < DEPTH; ++i)
                mem[i] <= 0;

            waddr_q <= 0;
            raddr_q <= 0;
        end
        else begin
            if (i_wen && !o_full)
                mem[waddr_q[PTR_WIDTH-1:0]] <= i_wdata;

            waddr_q <= waddr_d;
            raddr_q <= raddr_d;
        end
    end

    always_comb begin
        waddr_d = waddr_q;
        raddr_d = raddr_q;

        if (i_wen && !o_full) begin
            // if (waddr_q < DEPTH-1)
                waddr_d = waddr_q + 1;
            // else
                // waddr_d = 0;
        end

        if (i_ren && !o_empty) begin
            // if (raddr_q < DEPTH-1)
                raddr_d = raddr_q + 1;
            // else
                // raddr_d = 0;
        end
    end

    assign o_empty = waddr_q == raddr_q;
    assign o_full = (waddr_q[PTR_WIDTH] != raddr_q[PTR_WIDTH]) && (waddr_q[PTR_WIDTH-1:0] == raddr_q[PTR_WIDTH-1:0]);

    assign o_rdata = mem[raddr_q[PTR_WIDTH-1:0]];

endmodule

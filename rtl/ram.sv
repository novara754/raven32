`default_nettype none

module ram #(
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
    // 00 = byte
    // 01 = half-word
    // 10 = word
    input wire [1:0] i_rwidth,
    // 0 = unsigned
    // 1 = signed
    input wire i_rsigned,

    output logic [31:0] o_rdata
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    logic [31:0] mem [0:DEPTH-1];
    initial $readmemh("firmware.hex", mem);

    always_ff @(posedge i_clk) begin
        if (i_wen)
            mem[i_waddr[2 +: ADDR_WIDTH]] <= i_wdata;
    end

    logic [31:0] rdata;
    assign rdata = mem[i_raddr[2 +: ADDR_WIDTH]];

    always_comb begin
        case (i_rwidth)
            2'b00: if (i_rsigned) begin
                case (i_raddr[1:0])
                    2'b00: o_rdata = {{24{rdata[7]}}, rdata[7:0]};
                    2'b01: o_rdata = {{24{rdata[15]}}, rdata[15:8]};
                    2'b10: o_rdata = {{24{rdata[23]}}, rdata[23:16]};
                    2'b11: o_rdata = {{24{rdata[31]}}, rdata[31:24]};
                endcase
            end
            else begin
                case (i_raddr[1:0])
                    2'b00: o_rdata = {24'b0, rdata[7:0]};
                    2'b01: o_rdata = {24'b0, rdata[15:8]};
                    2'b10: o_rdata = {24'b0, rdata[23:16]};
                    2'b11: o_rdata = {24'b0, rdata[31:24]};
                endcase
            end

            2'b01: if (i_rsigned) begin
                if (!i_raddr[1]) o_rdata = {{16{rdata[15]}}, rdata[15:0]};
                else o_rdata = {{16{rdata[31]}}, rdata[31:16]};
            end
            else begin
                if (!i_raddr[1]) o_rdata = {16'b0, rdata[15:0]};
                else o_rdata = {16'b0, rdata[31:16]};
            end

            default: o_rdata = rdata;
        endcase
    end

endmodule

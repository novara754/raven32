`default_nettype none

module program_counter (
    input i_clk,
    input i_rst,

    output logic [31:0] o_pc
);

    logic [31:0] addr;

    always_ff @(posedge i_clk) begin
        if (i_rst)
            addr <= 0;
        else
            addr <= addr + 4;
    end

    assign o_pc = addr;

endmodule

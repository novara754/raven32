`default_nettype none

module program_counter (
    input i_clk,
    input i_rst,
    input i_en,
    input i_jmp_en,
    input [31:0] i_jmp_addr,
    output logic [31:0] o_pc,
    output logic [31:0] o_pc_plus_4
);

    logic [31:0] addr;

    always_ff @(posedge i_clk) begin
        if (i_rst)
            addr <= 0;
        else if (i_jmp_en)
            addr <= i_jmp_addr;
        else if (i_en)
            addr <= o_pc_plus_4;
        else
            addr <= addr;
    end

    assign o_pc = addr;
    assign o_pc_plus_4 = addr + 4;

endmodule

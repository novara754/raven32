`default_nettype none

module hazard_unit (
    /* -- W/M -> E FORWARDING -- */
    input wire [4:0] i_e_rs1,
    input wire [4:0] i_e_rs2,
    input wire [4:0] i_m_rd,
    input wire i_m_reg_wen,
    input wire [4:0] i_w_rd,
    input wire i_w_reg_wen,
    // 00 = no forwarding
    // 01 = forward from MEMORY
    // 10 = forward from WRITEBACK
    output logic [1:0] o_rs1_fwd,
    // 00 = no forwarding
    // 01 = forward from MEMORY
    // 10 = forward from WRITEBACK
    output logic [1:0] o_rs2_fwd,

    // -- LOAD STALL --
    input wire i_e_jmp_en,
    input wire i_e_has_load,
    input wire [4:0] i_e_rd,
    input wire [4:0] i_d_rs1,
    input wire [4:0] i_d_rs2,

    output logic o_stall_f,
    output logic o_stall_d,
    output logic o_flush_d,
    output logic o_flush_e
);

    always_comb begin
        if (i_m_reg_wen && i_e_rs1 == i_m_rd && i_e_rs1 != 0)
            o_rs1_fwd = 2'b01;
        else if (i_w_reg_wen && i_e_rs1 == i_w_rd && i_e_rs1 != 0)
            o_rs1_fwd = 2'b10;
        else
            o_rs1_fwd = 2'b00;

        if (i_m_reg_wen && i_e_rs2 == i_m_rd && i_e_rs2 != 0)
            o_rs2_fwd = 2'b01;
        else if (i_w_reg_wen && i_e_rs2 == i_w_rd && i_e_rs2 != 0)
            o_rs2_fwd = 2'b10;
        else
            o_rs2_fwd = 2'b00;
    end

    logic load_stall;
    assign load_stall = i_e_has_load && ((i_d_rs1 == i_e_rd) | (i_d_rs2 == i_e_rd));

    assign o_stall_f = load_stall;
    assign o_stall_d = load_stall;
    assign o_flush_d = i_e_jmp_en;
    assign o_flush_e = load_stall || i_e_jmp_en;

endmodule

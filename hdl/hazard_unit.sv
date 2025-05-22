`default_nettype none

module hazard_unit (
    input [4:0] i_e_rs1,
    input [4:0] i_e_rs2,
    input [4:0] i_m_rd,
    input i_m_reg_wen,
    input [4:0] i_w_rd,
    input i_w_reg_wen,

    // 00 = no forwarding
    // 01 = forward from MEMORY
    // 10 = forward from WRITEBACK
    output logic [1:0] o_rs1_fwd,
    // 00 = no forwarding
    // 01 = forward from MEMORY
    // 10 = forward from WRITEBACK
    output logic [1:0] o_rs2_fwd
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

endmodule

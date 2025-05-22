`default_nettype none

module core (
    input i_clk,
    input i_rst
);
    hazard_unit hazard_unit_inst (
        .i_e_rs1(e_rs1),
        .i_e_rs2(e_rs2),
        .i_m_rd(m_rd),
        .i_m_reg_wen(m_reg_wen),
        .i_w_rd(w_rd),
        .i_w_reg_wen(w_reg_wen),
        .o_rs1_fwd(e_rs1_fwd),
        .o_rs2_fwd(e_rs2_fwd)
    );

    /* -- FETCH -- */

    logic [31:0] f_pc;
    logic [31:0] f_inst;

    program_counter pc (
        .i_clk,
        .i_rst,
        .o_pc(f_pc)
    );

    word_memory inst_mem (
        .i_clk,
        .i_rst(1'b0),
        .i_wen(1'b0),
        .i_waddr(32'b0),
        .i_wdata(32'b0),
        .i_raddr(f_pc),
        .o_rdata(f_inst)
    );

    always_ff @(posedge i_clk) begin
        d_inst <= f_inst;
    end

    /* -- DECODE -- */

    logic [31:0] d_inst;

    logic [6:0] d_opcode;
    logic [2:0] d_funct3;
    logic [6:0] d_funct7;
    logic [31:0] d_imm;
    logic [4:0] d_rd;
    logic [4:0] d_rs1;
    logic [4:0] d_rs2;

    logic [3:0] d_alu_op;
    logic d_reg_wen;
    logic d_mem_wen;
    logic d_alu_src;
    logic [1:0] d_res_src;

    logic [31:0] d_rs1_data;
    logic [31:0] d_rs2_data;

    instruction_decoder inst_decoder (
        .i_inst(d_inst),
        .o_opcode(d_opcode),
        .o_funct3(d_funct3),
        .o_funct7(d_funct7),
        .o_imm(d_imm),
        .o_rd(d_rd),
        .o_rs1(d_rs1),
        .o_rs2(d_rs2)
    );

    control_unit ctrl_unit (
        .i_opcode(d_opcode),
        .i_funct3(d_funct3),
        .i_funct7(d_funct7),
        .o_alu_op(d_alu_op),
        .o_reg_wen(d_reg_wen),
        .o_mem_wen(d_mem_wen),
        .o_alu_src(d_alu_src),
        .o_res_src(d_res_src)
    );

    register_file regs (
        .i_clk,
        .i_rst,
        .i_wen(w_reg_wen),
        .i_waddr(w_rd),
        .i_wdata(w_result),
        .i_raddr1(d_rs1),
        .i_raddr2(d_rs2),
        .o_rdata1(d_rs1_data),
        .o_rdata2(d_rs2_data)
    );

    always_ff @(posedge i_clk) begin
        e_alu_op <= d_alu_op;
        e_reg_wen <= d_reg_wen;
        e_mem_wen <= d_mem_wen;
        e_alu_src <= d_alu_src;
        e_res_src <= d_res_src;
        e_rs1 <= d_rs1;
        e_rs2 <= d_rs2;
        e_rd <= d_rd;
        e_imm <= d_imm;
        e_rs1_data <= d_rs1_data;
        e_rs2_data <= d_rs2_data;
    end

    /* -- EXECUTE -- */

    logic [3:0] e_alu_op;
    logic e_reg_wen;
    logic e_mem_wen;
    logic e_alu_src;
    logic [1:0] e_res_src;
    logic [4:0] e_rd;
    logic [4:0] e_rs1;
    logic [4:0] e_rs2;
    logic [31:0] e_imm;
    logic [31:0] e_rs1_data;
    logic [31:0] e_rs2_data;

    logic [1:0] e_rs1_fwd;
    logic [1:0] e_rs2_fwd;
    logic [31:0] e_real_rs1_data;
    logic [31:0] e_real_rs2_data;

    logic [31:0] e_alu_b;
    logic [31:0] e_alu_res;

    always_comb begin
        case (e_rs1_fwd)
            2'b01: e_real_rs1_data = m_alu_res;
            2'b10: e_real_rs1_data = w_result;
            default: e_real_rs1_data = e_rs1_data;
        endcase

        case (e_rs2_fwd)
            2'b01: e_real_rs2_data = m_alu_res;
            2'b10: e_real_rs2_data = w_result;
            default: e_real_rs2_data = e_rs2_data;
        endcase
    end
    assign e_alu_b = e_alu_src ? e_imm : e_real_rs2_data;

    alu alu_inst (
        .i_op(e_alu_op),
        .i_a(e_real_rs1_data),
        .i_b(e_alu_b),
        .o_res(e_alu_res)
    );

    always_ff @(posedge i_clk) begin
        m_reg_wen <= e_reg_wen;
        m_mem_wen <= e_mem_wen;
        m_res_src <= e_res_src;
        m_rd <= e_rd;
        m_alu_res <= e_alu_res;
        m_mem_wdata <= e_real_rs2_data;
    end

    /* -- MEMORY -- */

    logic m_reg_wen;
    logic m_mem_wen;
    logic [1:0] m_res_src;
    logic [4:0] m_rd;
    logic [31:0] m_alu_res;
    logic [31:0] m_mem_wdata;

    logic [31:0] m_mem_rdata;

    word_memory data_mem (
        .i_clk,
        .i_rst,
        .i_wen(m_mem_wen),
        .i_waddr(m_alu_res),
        .i_wdata(m_mem_wdata),
        .i_raddr(m_alu_res),
        .o_rdata(m_mem_rdata)
    );

    always_ff @(posedge i_clk) begin
        w_reg_wen <= m_reg_wen;
        w_res_src <= m_res_src;
        w_rd <= m_rd;
        w_alu_res <= m_alu_res;
        w_mem_rdata <= m_mem_rdata;
    end

    /* -- WRITEBACK -- */

    logic w_reg_wen;
    logic [1:0] w_res_src;
    logic [4:0] w_rd;
    logic [31:0] w_alu_res;
    logic [31:0] w_mem_rdata;

    logic [31:0] w_result;

    always_comb begin
        case (w_res_src)
            2'b00: w_result = w_alu_res;
            2'b01: w_result = w_mem_rdata;
            2'b10: w_result = 0; // TODO: assign pc
            2'b11: w_result = 0;
        endcase
    end

endmodule

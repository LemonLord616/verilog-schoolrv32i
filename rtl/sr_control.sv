//
//  schoolRISCV - small RISC-V CPU
//
//  Originally based on Sarah L. Harris MIPS CPU
//  & schoolMIPS project.
//
//  Copyright (c) 2017-2020 Stanislav Zhelnio & Aleksandr Romanov.
//
//  Modified in 2024-2025 by Yuri Panchul & Mike Kuskov.
//
//  Modified in 2026 by Marat Mestnikov
//

`include "sr_cpu.svh"

module sr_control
(
    input        [ 6:0] op,
    input        [ 2:0] funct3,
    input        [ 6:0] funct7,
    input               alu_zero,

    output logic [ 1:0] pc_src,
    output logic        reg_write,
    output logic [ 1:0] write_byte_en,
    output logic        alu_src_a,
    output logic        alu_src_b,
    output logic [ 1:0] wd_src,
    output logic [ 3:0] alu_control,
    output logic [ 2:0] load_type,
    output logic        invalid_instr
);
    logic branch;
    logic cond_zero;
    logic jump;
    logic jump_reg;

    always_comb
    begin
        if (jump)
            pc_src = `PC_JAL;
        else if (jump_reg)
            pc_src = `PC_JALR;
        else if (branch & (alu_zero == cond_zero))
            pc_src = `PC_BRANCH;
        else
            pc_src = `PC_PLUS4;
    end

    always_comb
    begin
        branch        = 1'b0;
        cond_zero     = 1'b0;
        reg_write     = 1'b0;
        jump          = 1'b0;
        jump_reg      = 1'b0;
        alu_src_a     = `ALUA_RD1;
        alu_src_b     = `ALUB_RD2;
        wd_src        = `WD_ALU;
        alu_control   = `ALU_ADD;
        load_type     = `LOAD_W;
        write_byte_en = `WBE_NO;
        invalid_instr = 1'b0;

        casez ({ funct7, funct3, op })
            // R-type
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD   } : begin reg_write = 1'b1; alu_control = `ALU_ADD;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR    } : begin reg_write = 1'b1; alu_control = `ALU_OR;   end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL   } : begin reg_write = 1'b1; alu_control = `ALU_SRL;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU  } : begin reg_write = 1'b1; alu_control = `ALU_SLTU; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB   } : begin reg_write = 1'b1; alu_control = `ALU_SUB;  end
            { `RVF7_SLL,  `RVF3_SLL,  `RVOP_SLL   } : begin reg_write = 1'b1; alu_control = `ALU_SLL;  end
            { `RVF7_SLT,  `RVF3_SLT,  `RVOP_SLT   } : begin reg_write = 1'b1; alu_control = `ALU_SLT;  end
            { `RVF7_XOR,  `RVF3_XOR,  `RVOP_XOR   } : begin reg_write = 1'b1; alu_control = `ALU_XOR;  end
            { `RVF7_SRA,  `RVF3_SRA,  `RVOP_SRA   } : begin reg_write = 1'b1; alu_control = `ALU_SRA;  end
            { `RVF7_AND,  `RVF3_AND,  `RVOP_AND   } : begin reg_write = 1'b1; alu_control = `ALU_AND;  end

            // I-type
            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_ADD; end
            { `RVF7_SLLI, `RVF3_SLLI, `RVOP_SLLI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SLL;  end
            { `RVF7_ANY,  `RVF3_SLTI, `RVOP_SLTI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SLT;  end
            { `RVF7_ANY,  `RVF3_SLTIU,`RVOP_SLTIU } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SLTU; end
            { `RVF7_ANY,  `RVF3_XORI, `RVOP_XORI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_XOR;  end
            { `RVF7_SRLI, `RVF3_SRLI, `RVOP_SRLI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SRL;  end
            { `RVF7_SRAI, `RVF3_SRAI, `RVOP_SRAI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SRA;  end
            { `RVF7_ANY,  `RVF3_ORI,  `RVOP_ORI   } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_OR;   end
            { `RVF7_ANY,  `RVF3_ANDI, `RVOP_ANDI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_AND;  end

            // U-type
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI   } : begin reg_write = 1'b1; wd_src = `WD_IMM; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_AUIPC } : begin reg_write = 1'b1; wd_src = `WD_IMM; alu_src_a = `ALUA_PC; alu_src_b = `ALUB_IMM; end

            // B-type (cond_zero = 0 by default)
            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ   } : begin branch = 1'b1; alu_control = `ALU_SUB;  cond_zero = 1'b1; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE   } : begin branch = 1'b1; alu_control = `ALU_SUB;  end
            { `RVF7_ANY,  `RVF3_BLT,  `RVOP_BLT   } : begin branch = 1'b1; alu_control = `ALU_SLT;  end
            { `RVF7_ANY,  `RVF3_BGE,  `RVOP_BGE   } : begin branch = 1'b1; alu_control = `ALU_SLT;  cond_zero = 1'b1; end
            { `RVF7_ANY,  `RVF3_BLTU, `RVOP_BLTU  } : begin branch = 1'b1; alu_control = `ALU_SLTU; end
            { `RVF7_ANY,  `RVF3_BGEU, `RVOP_BGEU  } : begin branch = 1'b1; alu_control = `ALU_SLTU; cond_zero = 1'b1; end

            // J-type
            { `RVF7_ANY,  `RVF3_JALR, `RVOP_JALR  } : begin reg_write = 1'b1; jump_reg = 1'b1; wd_src = `WD_PCPLUS4; end // I-type actually
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_JAL   } : begin reg_write = 1'b1; jump = 1'b1;     wd_src = `WD_PCPLUS4; end
            
            // Load/Store
            { `RVF7_ANY,  `RVF3_LB,   `RVOP_LB    } : begin reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; load_type = `LOAD_B;  end
            { `RVF7_ANY,  `RVF3_LH,   `RVOP_LH    } : begin reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; load_type = `LOAD_H;  end
            { `RVF7_ANY,  `RVF3_LW,   `RVOP_LW    } : begin reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; load_type = `LOAD_W;  end
            { `RVF7_ANY,  `RVF3_LBU,  `RVOP_LBU   } : begin reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; load_type = `LOAD_BU; end
            { `RVF7_ANY,  `RVF3_LHU,  `RVOP_LHU   } : begin reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; load_type = `LOAD_HU; end
            { `RVF7_ANY,  `RVF3_SW,   `RVOP_SW    } : begin write_byte_en = `WBE_W; alu_src_b = `ALUB_IMM; end

            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_ANY   } : begin invalid_instr = 1'b1; end
        endcase
    end

endmodule

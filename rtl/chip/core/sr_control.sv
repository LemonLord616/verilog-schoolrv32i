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
`include "memory.svh"

module sr_control
(
    input  [ 6:0] op,
    input  [ 2:0] funct3,
    input  [ 6:0] funct7,
    input         alu_zero,

    output     [ 1:0] pc_src,
    output reg        reg_write,
    output reg        mem_op,
    output reg [ 1:0] mem_size,
    output reg        mem_enable,
    output reg        mem_signed,
    output reg        alu_src_a,
    output reg        alu_src_b,
    output reg [ 1:0] wd_src,
    output reg [ 3:0] alu_control,
    output reg        invalid_instr
);
    reg branch;
    reg cond_zero;
    reg jump;
    reg jump_reg;

    assign pc_src =
        (jump    ) ? `PC_JAL  :
        (jump_reg) ? `PC_JALR :
        (branch & (alu_zero == cond_zero)) ? `PC_BRANCH :
        `PC_PLUS4;

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
        mem_op        = `MEM_OP_LOAD;
        mem_size      = `MEM_SIZE_W;
        mem_enable    = 1'b0;
        mem_signed    = 1'b1;
        invalid_instr = 1'b0;

        casez ({ funct7, funct3, op })
            { `RVF7_ANY,  `RVF3_LB,   `RVOP_LB    } : begin 
                reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; mem_enable = 1'b1; mem_op = `MEM_OP_LOAD; mem_size = `MEM_SIZE_B; end
            { `RVF7_ANY,  `RVF3_LH,   `RVOP_LH    } : begin
                reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; mem_enable = 1'b1; mem_op = `MEM_OP_LOAD; mem_size = `MEM_SIZE_H; end
            { `RVF7_ANY,  `RVF3_LW,   `RVOP_LW    } : begin
                reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; mem_enable = 1'b1; mem_op = `MEM_OP_LOAD; mem_size = `MEM_SIZE_W; end
            { `RVF7_ANY,  `RVF3_LBU,  `RVOP_LBU   } : begin
                reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; mem_enable = 1'b1; mem_op = `MEM_OP_LOAD; mem_size = `MEM_SIZE_B; mem_signed = 1'b0; end
            { `RVF7_ANY,  `RVF3_LHU,  `RVOP_LHU   } : begin
                reg_write = 1'b1; wd_src = `WD_MEM; alu_src_b = `ALUB_IMM; mem_enable = 1'b1; mem_op = `MEM_OP_LOAD; mem_size = `MEM_SIZE_W; mem_signed = 1'b0; end

            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_ADD; end
            { `RVF7_SLLI, `RVF3_SLLI, `RVOP_SLLI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SLL;  end
            { `RVF7_ANY,  `RVF3_SLTI, `RVOP_SLTI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SLT;  end
            { `RVF7_ANY,  `RVF3_SLTIU,`RVOP_SLTIU } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SLTU; end
            { `RVF7_ANY,  `RVF3_XORI, `RVOP_XORI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_XOR;  end
            { `RVF7_SRLI, `RVF3_SRLI, `RVOP_SRLI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SRL;  end
            { `RVF7_SRAI, `RVF3_SRAI, `RVOP_SRAI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_SRA;  end
            { `RVF7_ANY,  `RVF3_ORI,  `RVOP_ORI   } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_OR;   end
            { `RVF7_ANY,  `RVF3_ANDI, `RVOP_ANDI  } : begin reg_write = 1'b1; alu_src_b = `ALUB_IMM; alu_control = `ALU_AND;  end

            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_AUIPC } : begin reg_write = 1'b1; wd_src = `WD_ALU; alu_src_a = `ALUA_PC; alu_src_b = `ALUB_IMM; end

            { `RVF7_ANY,  `RVF3_SB,   `RVOP_SB    } : begin alu_src_b = `ALUB_IMM; mem_enable = 1'b1; mem_op = `MEM_OP_STORE; mem_size = `MEM_SIZE_B; end
            { `RVF7_ANY,  `RVF3_SH,   `RVOP_SH    } : begin alu_src_b = `ALUB_IMM; mem_enable = 1'b1; mem_op = `MEM_OP_STORE; mem_size = `MEM_SIZE_H; end
            { `RVF7_ANY,  `RVF3_SW,   `RVOP_SW    } : begin alu_src_b = `ALUB_IMM; mem_enable = 1'b1; mem_op = `MEM_OP_STORE; mem_size = `MEM_SIZE_W; end

            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD   } : begin reg_write = 1'b1; alu_control = `ALU_ADD;  end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB   } : begin reg_write = 1'b1; alu_control = `ALU_SUB;  end
            { `RVF7_SLL,  `RVF3_SLL,  `RVOP_SLL   } : begin reg_write = 1'b1; alu_control = `ALU_SLL;  end
            { `RVF7_SLT,  `RVF3_SLT,  `RVOP_SLT   } : begin reg_write = 1'b1; alu_control = `ALU_SLT;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU  } : begin reg_write = 1'b1; alu_control = `ALU_SLTU; end
            { `RVF7_XOR,  `RVF3_XOR,  `RVOP_XOR   } : begin reg_write = 1'b1; alu_control = `ALU_XOR;  end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL   } : begin reg_write = 1'b1; alu_control = `ALU_SRL;  end
            { `RVF7_SRA,  `RVF3_SRA,  `RVOP_SRA   } : begin reg_write = 1'b1; alu_control = `ALU_SRA;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR    } : begin reg_write = 1'b1; alu_control = `ALU_OR;   end
            { `RVF7_AND,  `RVF3_AND,  `RVOP_AND   } : begin reg_write = 1'b1; alu_control = `ALU_AND;  end

            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI   } : begin reg_write = 1'b1; wd_src = `WD_IMM; end

            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ   } : begin branch = 1'b1; alu_control = `ALU_SUB;  cond_zero = 1'b1; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE   } : begin branch = 1'b1; alu_control = `ALU_SUB;  cond_zero = 1'b0; end
            { `RVF7_ANY,  `RVF3_BLT,  `RVOP_BLT   } : begin branch = 1'b1; alu_control = `ALU_SLT;  cond_zero = 1'b0; end
            { `RVF7_ANY,  `RVF3_BGE,  `RVOP_BGE   } : begin branch = 1'b1; alu_control = `ALU_SLT;  cond_zero = 1'b1; end
            { `RVF7_ANY,  `RVF3_BLTU, `RVOP_BLTU  } : begin branch = 1'b1; alu_control = `ALU_SLTU; cond_zero = 1'b0; end
            { `RVF7_ANY,  `RVF3_BGEU, `RVOP_BGEU  } : begin branch = 1'b1; alu_control = `ALU_SLTU; cond_zero = 1'b1; end

            { `RVF7_ANY,  `RVF3_JALR, `RVOP_JALR  } : begin reg_write = 1'b1; jump_reg = 1'b1; wd_src = `WD_PCPLUS4; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_JAL   } : begin reg_write = 1'b1; jump = 1'b1;     wd_src = `WD_PCPLUS4; end
            
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_ANY   } : begin invalid_instr = 1'b1; end
        endcase
    end

endmodule

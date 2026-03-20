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

module sr_decode
(
    input  [31:0] instr,
    output [ 6:0] op,
    output [ 4:0] rd,
    output [ 2:0] funct3,
    output [ 4:0] rs1,
    output [ 4:0] rs2,
    output [ 6:0] funct7,
    output [31:0] imm
);
    assign op     = instr [ 6: 0];
    assign rd     = instr [11: 7];
    assign funct3 = instr [14:12];
    assign rs1    = instr [19:15];
    assign rs2    = instr [24:20];
    assign funct7 = instr [31:25];
    
    assign imm =
        (op == `OP_LOAD   ||
         op == `OP_IMM    ||
         op == `OP_JALR  ) ? { {20{instr[31]}}, instr[31:20] } :
        (op == `OP_AUIPC  ||
         op == `OP_LUI   ) ? { instr[31:12], 12'b0 } :
        (op == `OP_STORE ) ? { {20{instr[31]}}, instr[31:25], instr[11:7] }:
        (op == `OP_BRANCH) ? { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0} :
        (op == `OP_JUMP  ) ? { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0} :
        {32{1'bx}};

    // always_comb
    // begin
    //     unique case (op)
    //         `OP_LOAD, `OP_IMM, `OP_JALR: 
    //             imm = { {20{instr[31]}}, instr[31:20] };
    //             // essentially the same as
    //             // imm = { {21{instr[31]}}, instr[30:20] };
    //         `OP_AUIPC, `OP_LUI:
    //             imm = { instr[31:12], 12'b0 };
    //         `OP_STORE:
    //             imm = { {20{instr[31]}}, instr[31:25], instr[11:7] };
    //         `OP_BRANCH:
    //             imm = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    //         `OP_JUMP:
    //             imm = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
    //         default: imm = 32'b0;
    //     endcase
    // end

endmodule

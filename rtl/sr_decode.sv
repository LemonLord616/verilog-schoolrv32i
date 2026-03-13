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
    input        [31:0] instr,
    output       [ 6:0] op,
    output       [ 4:0] rd,
    output       [ 2:0] funct3,
    output       [ 4:0] rs1,
    output       [ 4:0] rs2,
    output       [ 6:0] funct7,
    output logic [31:0] imm
    // output logic [31:0] immI,
    // output logic [31:0] immB,
    // output logic [31:0] immU,
    // output logic [31:0] immJ,
    // output logic [31:0] immS
);
    assign op     = instr [ 6: 0];
    assign rd     = instr [11: 7];
    assign funct3 = instr [14:12];
    assign rs1    = instr [19:15];
    assign rs2    = instr [24:20];
    assign funct7 = instr [31:25];
    
    always_comb
    begin
        unique case (op)
            `OP_LOAD, `OP_IMM, `OP_JALR: 
                imm = { {20{instr[31]}}, instr[31:20] };
            `OP_AUIPC, `OP_LUI:
                imm = { instr[31:12], 12'b0 };
            `OP_STORE:
                imm = { {20{instr[31]}}, instr[31:25], instr[11:7] };
            `OP_BRANCH:
                imm = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            `OP_JUMP:
                imm = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm = 32'b0;
        endcase
    end

    // I-type

    // always_comb
    // begin
    //     immI [10: 0] = instr [30:20];
    //     immI [31:11] = { 21 { instr [31] } };
    // end

    // B-type

    // always_comb
    // begin
    //     immB [    0] = 1'b0;
    //     immB [ 4: 1] = instr [11:8];
    //     immB [10: 5] = instr [30:25];
    //     immB [   11] = instr [7];
    //     immB [31:12] = { 20 { instr [31] } };
    // end

    // U-type

    // always_comb
    // begin
    //     immU [11: 0] = 12'b0;
    //     immU [31:12] = instr [31:12];
    // end

    // J-type

    // always_comb
    // begin
    //     immJ [    0] = 1'b0;
    //     immJ [10: 1] = instr [30:21];
    //     immJ [   11] = instr [20];
    //     immJ [19:12] = instr [19:12];
    //     immJ [31:20] = { 12 { instr [31] } };
    // end

    // S-type

    // always_comb
    // begin
    //     immS [ 4: 0] = instr [11: 7];
    //     immS [11: 5] = instr [31:25];
    //     immS [31:12] = { 20 { instr [31] } };
    // end

endmodule

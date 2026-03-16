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

`ifndef SR_CPU_SVH
`define SR_CPU_SVH

// Multiplexers (Enums)
// Opcode (used in instruction decoder)
`define OP_LOAD   7'd3
`define OP_IMM    7'd19
`define OP_AUIPC  7'd23
`define OP_STORE  7'd35
`define OP_REG    7'd51
`define OP_LUI    7'd55
`define OP_BRANCH 7'd99
`define OP_JALR   7'd103
`define OP_JUMP   7'd111 // jal

// pcSrc
`define PC_PLUS4    2'd0
`define PC_BRANCH   2'd1
`define PC_JAL      2'd2
`define PC_JALR     2'd3
// ALU's srcB
// `define ALUB_RD2    3'b000
// `define ALUB_IMM_I  3'b001
// `define ALUB_IMM_J  3'b010
// `define ALUB_IMM_U  3'b011
// `define ALUB_IMM_S  3'b100
`define ALUB_RD2    1'd0
`define ALUB_IMM    1'd1
// ALU's srcA
`define ALUA_RD1    1'd0
`define ALUA_PC     1'd1
// wdSrc
`define WD_ALU      2'd0
`define WD_PCPLUS4  2'd1 // jal/jar
// `define WD_IMM_U    2'b10 // lui immediate
`define WD_IMM      2'd2
`define WD_MEM      2'd3 // load instr
// mem_write
`define MW_NO       2'd0 // no write
`define MW_W        2'd1 // word
`define MW_H        2'd2 // half word
`define MW_B        2'd3 // byte
// loadType (for sign/zero extend)
`define LOAD_W      3'b000
`define LOAD_H      3'b001
`define LOAD_B      3'b010
`define LOAD_HU     3'b011
`define LOAD_BU     3'b100

// ALU commands

`define ALU_ADD     4'd0
`define ALU_OR      4'd1
`define ALU_SRL     4'd2
`define ALU_SLTU    4'd3
`define ALU_SUB     4'd4
`define ALU_SLL     4'd5
`define ALU_SLT     4'd6
`define ALU_XOR     4'd7
`define ALU_SRA     4'd8
`define ALU_AND     4'd9

// Instruction opcode

`define RVOP_LB     7'd3
`define RVOP_LH     7'd3
`define RVOP_LW     7'd3
`define RVOP_LBU    7'd3
`define RVOP_LHU    7'd3

`define RVOP_ADDI   7'd19
`define RVOP_SLLI   7'd19
`define RVOP_SLTI   7'd19
`define RVOP_SLTIU  7'd19
`define RVOP_XORI   7'd19
`define RVOP_SRLI   7'd19
`define RVOP_SRAI   7'd19
`define RVOP_ORI    7'd19
`define RVOP_ANDI   7'd19

`define RVOP_AUIPC  7'd23

`define RVOP_SB     7'd35
`define RVOP_SH     7'd35
`define RVOP_SW     7'd35

`define RVOP_ADD    7'd51
`define RVOP_SUB    7'd51
`define RVOP_SLL    7'd51
`define RVOP_SLT    7'd51
`define RVOP_SLTU   7'd51
`define RVOP_XOR    7'd51
`define RVOP_SRL    7'd51
`define RVOP_SRA    7'd51
`define RVOP_OR     7'd51
`define RVOP_AND    7'd51

`define RVOP_LUI    7'd55

`define RVOP_BEQ    7'd99
`define RVOP_BNE    7'd99
`define RVOP_BLT    7'd99
`define RVOP_BGE    7'd99
`define RVOP_BLTU   7'd99
`define RVOP_BGEU   7'd99

`define RVOP_JALR   7'd103
`define RVOP_JAL    7'd111

`define RVOP_ANY    7'b???????

// Instruction funct3

`define RVF3_LB     3'b000
`define RVF3_LH     3'b001
`define RVF3_LW     3'b010
`define RVF3_LBU    3'b100
`define RVF3_LHU    3'b101

`define RVF3_ADDI   3'b000
`define RVF3_SLLI   3'b001
`define RVF3_SLTI   3'b010
`define RVF3_SLTIU  3'b011
`define RVF3_XORI   3'b100
`define RVF3_SRLI   3'b101
`define RVF3_SRAI   3'b101
`define RVF3_ORI    3'b110
`define RVF3_ANDI   3'b111

`define RVF3_SB     3'b000
`define RVF3_SH     3'b010
`define RVF3_SW     3'b011

`define RVF3_ADD    3'b000
`define RVF3_SUB    3'b000
`define RVF3_SLL    3'b001
`define RVF3_SLT    3'b010
`define RVF3_SLTU   3'b011
`define RVF3_XOR    3'b100
`define RVF3_SRL    3'b101
`define RVF3_SRA    3'b101
`define RVF3_OR     3'b110
`define RVF3_AND    3'b111

`define RVF3_BEQ    3'b000
`define RVF3_BNE    3'b001
`define RVF3_BLT    3'b100
`define RVF3_BGE    3'b101
`define RVF3_BLTU   3'b110
`define RVF3_BGEU   3'b111

`define RVF3_JALR   3'b000

`define RVF3_ANY    3'b???

// Instruction funct7

`define RVF7_SLLI   7'b0000000
`define RVF7_SRLI   7'b0000000
`define RVF7_SRAI   7'b0100000

`define RVF7_ADD    7'b0000000
`define RVF7_SUB    7'b0100000
`define RVF7_SLL    7'b0000000
`define RVF7_SLT    7'b0000000
`define RVF7_SLTU   7'b0000000
`define RVF7_XOR    7'b0000000
`define RVF7_SRL    7'b0000000
`define RVF7_SRA    7'b0100000
`define RVF7_OR     7'b0000000
`define RVF7_AND    7'b0000000

`define RVF7_ANY    7'b???????

`endif  // `ifndef SR_CPU_SVH

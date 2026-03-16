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

module sr_cpu
(
    input           clk,               // clock
    input           rst,               // reset

    output  [31:0]  instr_addr,        // instruction memory address
    input   [31:0]  instr_data,        // instruction memory data

    output  [ 1:0]  mem_write,         // data write on mem_write (see sr_cpu.svh MW_... constants)
    output  [31:0]  addr,              // r/w ram address
    input   [31:0]  rdata,             // read ram data
    output  [31:0]  wdata,             // write ram data

    output          invalid_instr,

    input   [ 4:0]  debug_reg_addr, // debug access reg address
    output  [31:0]  debug_reg_data  // debug access reg data
);

    // instruction decode wires

    wire [ 6:0] op;
    wire [ 4:0] rd;
    wire [ 2:0] funct3;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    wire [ 6:0] funct7;
    wire [31:0] imm;

    // instruction decode

    sr_decode id
    (
        .instr   ( instr  ),
        .op      ( op     ),
        .rd      ( rd     ),
        .funct3  ( funct3 ),
        .rs1     ( rs1    ),
        .rs2     ( rs2    ),
        .funct7  ( funct7 ),
        .imm     ( imm    )
    );

    // control wires

    wire       alu_zero;
    wire [1:0] pc_src;
    wire       reg_write;
    wire       alu_src_a;
    wire       alu_src_b;
    wire [1:0] wd_src;
    wire [3:0] alu_control;
    wire [2:0] load_type;

    // control

    sr_control control
    (
        .op             ( op            ),
        .funct3         ( funct3        ),
        .funct7         ( funct7        ),
        .alu_zero       ( alu_zero      ),
        .pc_src         ( pc_src        ),
        .reg_write      ( reg_write     ),
        .mem_write      ( mem_write ),
        .alu_src_a      ( alu_src_a     ),
        .alu_src_b      ( alu_src_b     ),
        .wd_src         ( wd_src        ),
        .alu_control    ( alu_control   ),
        .load_type      ( load_type     ),
        .invalid_instr  ( invalid_instr )
    );

    // alu

    wire [31:0] alu_result;
    wire [31:0] src_a = alu_src_a == `ALUA_RD1 ? rd1 : pc;
    wire [31:0] src_b = alu_src_b == `ALUB_RD2 ? rd2 : imm;

    sr_alu alu
    (
        .src_a      ( src_a        ),
        .src_b      ( src_b        ),
        .oper       ( alu_control  ),
        .zero       ( alu_zero     ),
        .result     ( alu_result   )
    );

    // ram

    assign addr = alu_result;
    assign wdata = rd2;
    wire [31:0] load_data;

    assign load_data =
        (load_type == `LOAD_W) ? rdata :
        (load_type == `LOAD_H) ? { {16{rdata[31]}}, rdata[15: 0] } :
        (load_type == `LOAD_B) ? { {24{rdata[31]}}, rdata[ 7: 0] } :
        (load_type == `LOAD_HU) ? { 16'b0, rdata[15: 0] } :
        (load_type == `LOAD_BU) ? { 24'b0, rdata[ 7: 0] } :
        {32{1'bx}};
        
    // program counter

    wire [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4  = pc + 32'd4;
    wire [31:0] pc_cond    = pc + imm; // least significant bit is decoded as zero in decoder
    // TODO: recheck logic
    wire [31:0] pc_jump_reg = (rd1 + imm) & ~32'b1; // least significant bit is zero

    assign pc_next =
        (pc_src == `PC_PLUS4 ) ? pc_plus_4   :
        (pc_src == `PC_BRANCH) ? pc_cond     :
        (pc_src == `PC_JAL   ) ? pc_cond     :
        (pc_src == `PC_JALR  ) ? pc_jump_reg :
        {32{1'bx}};

    register_with_rst pc_r (clk, rst, pc_next, pc);

    // program memory access

    assign instr_addr = pc >> 2;
    wire [31:0] instr = instr_data;

    // register file

    wire [31:0] debug_rd;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wd3;

    assign wd3 =
        (wd_src == `WD_ALU    ) ? alu_result :
        (wd_src == `WD_IMM    ) ? imm        :
        (wd_src == `WD_PCPLUS4) ? pc_plus_4  :
        (wd_src == `WD_MEM    ) ? load_data  :
        {32{1'bx}};

    sr_register_file rf
    (
        .clk        ( clk            ),
        .a1         ( rs1            ),
        .a2         ( rs2            ),
        .a3         ( rd             ),
        .rd1        ( rd1            ),
        .rd2        ( rd2            ),
        .wd3        ( wd3            ),
        .we3        ( reg_write      ),

        .dbg_addr   ( debug_reg_addr ),
        .dbg_data   ( debug_rd       )
    );

    // debug register access

    assign debug_reg_data = (debug_reg_addr != '0) ? debug_rd : pc;

endmodule

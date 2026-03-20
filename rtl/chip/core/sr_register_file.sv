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

`include "sr_cpu.svh"

module sr_register_file
(
    input         clk,
    input  [ 4:0] a1,
    input  [ 4:0] a2,
    input  [ 4:0] a3,
    output [31:0] rd1,
    output [31:0] rd2,
    input  [31:0] wd3,
    input         we3,

    input  [ 4:0] dbg_addr,
    output [31:0] dbg_data
);
    logic [31:0] rf [0:31];

    assign rd1 = (a1 != 0) ? rf [a1] : 32'b0;
    assign rd2 = (a2 != 0) ? rf [a2] : 32'b0;
    assign dbg_data = (dbg_addr != 0) ? rf [dbg_addr] : 32'b0;

    always_ff @ (posedge clk)
        if(we3) rf [a3] <= wd3;

endmodule

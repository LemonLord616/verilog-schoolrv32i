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

module sr_mdu
(
    input        [31:0] srcA,
    input        [31:0] srcB,
    input        [ 2:0] oper,
    output logic [31:0] result
);

    always_comb
        case (oper)
            default   : result =  srcA * srcB;
        endcase

endmodule

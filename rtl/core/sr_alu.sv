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

module sr_alu
(
    input  [31:0] src_a,
    input  [31:0] src_b,
    input  [ 3:0] oper,
    output        zero,
    output [31:0] result
);

    assign result =
        (oper == `ALU_ADD ) ?  src_a +   src_b :
        (oper == `ALU_OR  ) ?  src_a |   src_b :
        (oper == `ALU_SRL ) ?  src_a >>  src_b [4:0] :
        (oper == `ALU_SLTU) ? (src_a <   src_b ? 32'd1 : 32'd0) :
        (oper == `ALU_SUB ) ?  src_a -   src_b :
        (oper == `ALU_SLL ) ?  src_a <<  src_b [4:0] :
        (oper == `ALU_SLT ) ? ($signed(src_a) < $signed(src_b) ? 32'd1 : 32'd0) :
        (oper == `ALU_XOR ) ?  src_a ^   src_b :
        (oper == `ALU_SRA ) ?  src_a >>> src_b :
        (oper == `ALU_AND ) ?  src_a &   src_b :
        {32{1'bx}};
    // always_comb
    //     case (oper)
    //         default   : result =  src_a +   src_b;
    //         `ALU_ADD  : result =  src_a +   src_b;
    //         `ALU_OR   : result =  src_a |   src_b;
    //         `ALU_SRL  : result =  src_a >>  src_b [4:0];
    //         `ALU_SLTU : result = (src_a <   src_b) ? 32'd1 : 32'd0;
    //         `ALU_SUB  : result =  src_a -   src_b;
    //         `ALU_SLL  : result =  src_a <<  src_b [4:0];
    //         `ALU_SLT  : result = ($signed(src_a) <  $signed(src_b)) ? 32'd1 : 32'd0;
    //         `ALU_XOR  : result =  src_a ^   src_b;
    //         `ALU_SRA  : result =  src_a >>> src_b;
    //         `ALU_AND  : result =  src_a &   src_b;
    //     endcase

    assign zero = (result == '0);

endmodule

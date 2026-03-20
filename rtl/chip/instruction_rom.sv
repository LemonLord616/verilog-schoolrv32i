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

module instruction_rom
#(
    parameter SIZE = 64
)
(
    input  [31:0] addr,
    output [31:0] rdata
);
    logic [31:0] rom [0:SIZE - 1];
    
    assign rdata = rom [addr];

    initial $readmemh ("./rtl/program.hex", rom);

endmodule

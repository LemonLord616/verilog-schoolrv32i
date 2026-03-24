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
//  Modified in 2025 by Marat Mestnikov
//

`include "sr_cpu.svh"
`include "memory.svh"

//
// Keep in mind that testbench will not allocate much memory
// Address overflow is not handled at this moment
//
module data_ram
#(
    parameter SIZE = 1024
)
(
    input          clk,

    input          write_mem,
    input  [ 1: 0] mem_size,
    input  [31: 0] addr,
    input  [31: 0] wdata,

    output [31: 0] rdata
);
    logic [7:0] ram [0:SIZE - 1]; // single byte-addressable address space
    
    logic [31: 0] dump_debug;
    // initial $readmemh ("./rtl/data.hex", ram);

    always_ff @( posedge clk ) begin
        if (write_mem) begin
            case (mem_size)
                `MEM_SIZE_W: begin       // word
                    dump_debug     <= wdata;
                    ram[addr + 3] <= wdata[31:24];        
                    ram[addr + 2] <= wdata[23:16];        
                    ram[addr + 1] <= wdata[15: 8];        
                    ram[addr]     <= wdata[ 7: 0];        
                end
                `MEM_SIZE_H: begin       // half word
                    ram[addr + 1] <= wdata[15: 8];
                    ram[addr]     <= wdata[ 7: 0];
                end
                `MEM_SIZE_B: ram[addr] <= wdata[ 7: 0]; // byte
                default: ram[addr] <= wdata[ 7: 0];
            endcase
        end
    end

    assign rdata = { ram [addr + 3], ram [addr + 2], ram [addr + 1], ram [addr] };


endmodule


`include "chip_top.svh"
`include "sr_cpu.svh"
`include "memory.svh"

module address_decoder
(
    input         mem_op,
    input         mem_enable,
    input  [31:0] addr,

    output [11:0] dev_id,
    output [`SEL_WIDTH-1:0] sel,

    output write_mem,
    output write_1,
    output write_2,
    output write_3,
    
    output read_mem,
    output read_1,
    output read_2,
    output read_3
);
    
    assign sel = 
        (addr[31-:4]  ==  4'h0)     ? `SEL_MEM  : // range [32'h0000_0000, 32'h0fff_ffff]
        (addr[31-:20] == 20'h10000) ? `SEL_DEV1 : // range [32'h1000_0000, 32'h1000_0fff]
        (addr[31-:20] == 20'h20000) ? `SEL_DEV2 : // range [32'h2000_0000, 32'h2000_0fff]
        (addr[31-:20] == 20'h30000) ? `SEL_DEV3 : // range [32'h3000_0000, 32'h3000_0fff]
        `SEL_INVALID_ADDR;
    
    wire store = mem_enable && mem_op == `MEM_OP_STORE;
    wire load  = mem_enable && mem_op == `MEM_OP_LOAD;

    assign write_mem = (sel == `SEL_MEM  && store);
    assign write_1   = (sel == `SEL_DEV1 && store);
    assign write_2   = (sel == `SEL_DEV2 && store);
    assign write_3   = (sel == `SEL_DEV3 && store);
    
    assign read_mem = (sel == `SEL_MEM  && load);
    assign read_1   = (sel == `SEL_DEV1 && load);
    assign read_2   = (sel == `SEL_DEV2 && load);
    assign read_3   = (sel == `SEL_DEV3 && load);

    assign dev_id = addr[0+:12];
    

endmodule

`include "lab_top.svh"
`include "sr_cpu.svh"

module address_decoder
(
    input  [ 1:0] mem_write,
    input  [31:0] addr,
    output [ 1:0] sel,
    output [ 1:0] we_mem,
    output [ 1:0] we_1,
    output [ 1:0] we_2
);
    
    assign sel = 
        (addr[31:28] ==  4'h0)     ? `SEL_MEM  : // range [32'h0000_0000, 32'h0fff_ffff]
        (addr[31:12] == 20'h10000) ? `SEL_DEV1 : // range [32'h1000_0000, 32'h1000_0fff]
        (addr[31:12] == 20'h20000) ? `SEL_DEV2 : // range [32'h2000_0000, 32'h2000_0fff]
        `SEL_INVALID_ADDR;

    assign we_mem = (sel == `SEL_MEM ) ? mem_write : `MW_NO;
    assign we_1   = (sel == `SEL_DEV1) ? mem_write : `MW_NO;
    assign we_2   = (sel == `SEL_DEV2) ? mem_write : `MW_NO;

endmodule
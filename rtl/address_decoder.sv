
`include "lab_top.svh"


module address_decoder
(
    input  [ 1:0] mem_write,
    input  [31:0] addr,
    output [ 1:0] rd_sel,
    output        we_mem,
    output        we_1,
    output        we_2,
    output        we_3,
);
    


module switches
# ( parameter w_sw = 8 ) // supports up to 4095 switches (I guess?)
(
    input          clk,
    input  [11: 0] dev_id,
    output [31: 0] rdata,
    
    input [w_sw - 1: 0] sw
);
    // 32'x2000_0fff
    // 32'b0010_0000_0000_0000_0000_1111_1111_1111
    
    assign rdata = { {31{1'b0}}, sw[dev_id] };
    
endmodule
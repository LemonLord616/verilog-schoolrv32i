
module switches
# ( parameter w_sw = 8 ) // supports up to 4095 switches (I guess?)
(
    input          clk,
    input  [31: 0] addr,
    output [31: 0] rdata,
    
    input [w_sw - 1: 0] sw,
    
    output invalid_addr
);
    // 32'x2000_0fff
    // 32'b0002_0000_0000_0000_0000_1111_1111_1111
    
    assign invalid_addr = !(addr[11: 0] < w_sw);
    
    // returns -1 on invalid access
    assign rdata = (!invalid_addr) ? { {31{1'b0}}, sw[addr[11: 0]] } : { 32{1'b1} };
    
endmodule
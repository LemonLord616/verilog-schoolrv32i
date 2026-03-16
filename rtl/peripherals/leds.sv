
`include "sr_cpu.svh"

module leds
# ( parameter w_led = 8 ) // supports up to 4095 leds (I guess?)
(
    input          clk,
    input  [31: 0] addr,
    input  [ 1: 0] write_enable,
    input  [31: 0] wdata,
    // output [31: 0] rdata,
    
    output [w_led - 1: 0] led,
    
    output invalid_addr
);
    logic [w_led - 1: 0] led_reg;

    assign invalid_addr = (write_enable != `MW_NO) && !(addr[11: 0] < w_led);
    
    // 32'x1000_0fff
    // 32'b0001_0000_0000_0000_0000_1111_1111_1111
    always_ff @( posedge clk ) begin
        if (!invalid_addr) begin // write if addr is valid
            led_reg[addr[11: 0]] <= wdata != 32'b0;
        end
    end
    
    assign led = led_reg;

endmodule
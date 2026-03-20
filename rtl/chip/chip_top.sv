`include "chip_top.svh"
`include "sr_cpu.svh"


module chip_top
#(
    parameter clk_mhz = 50,
    parameter ROM_SIZE = 64,
    parameter RAM_SIZE = 64,
    parameter w_led = 8,
    parameter w_sw  = 8
)
(
    input clk,
    input rst,
    output [w_led-1 : 0] led,
    input  [w_sw -1 : 0] sw,
    
    input  i_uart_rx,
    output o_uart_tx,

    input   [4:0] debug_reg_addr,
    output [31:0] debug_reg_data,
    output [31:0] debug_im_addr,
    output [31:0] debug_im_data
);

    // rom
    wire [ 4:0] reg_addr;  // debug access reg address
    wire [31:0] reg_data;  // debug access reg data
    wire [31:0] im_addr;   // instruction memory address
    wire [31:0] im_data;   // instruction memory data
    
    assign reg_addr = debug_reg_addr;
    assign debug_reg_data = reg_data;
    assign debug_im_addr  = im_addr;
    assign debug_im_data  = im_data;

    // ram
    wire [ 1:0] mem_write; // data write on mem_write (see sr_cpu.svh MW_... constants)
    wire [31:0] addr;      // r/w data address
    wire [31:0] rdata;     // read data 
    wire [31:0] wdata;     // write data

    sr_cpu i_cpu
    (
        .clk            ( clk ),
        .rst            ( rst ),

        .instr_addr     ( im_addr ),
        .instr_data     ( im_data ),

        .addr           ( addr   ),
        .rdata          ( rdata  ),
        .wdata          ( wdata  ),
        .mem_write      ( mem_write ),
        
        .invalid_instr  (  ),

        .debug_reg_addr ( reg_addr ),
        .debug_reg_data ( reg_data )
    );
    
    wire [`SEL_WIDTH: 0] sel;
    wire [1:0] we_mem; // ram
    wire we_1, we_2, we_3; // devices

    wire [31:0] rdata_mem; // ram
    wire [31:0] rdata_1, rdata_2, rdata_3; // devices
    
    wire [11:0] dev_id;

    assign rdata_1 = {32{1'b0}}; // leds do not return anything
    
    assign rdata =
        (sel == `SEL_MEM ) ? rdata_mem :
        (sel == `SEL_DEV1) ? rdata_1 :
        (sel == `SEL_DEV2) ? rdata_2 :
        (sel == `SEL_DEV3) ? rdata_3 :
        {32{`ERROR}};
    
    address_decoder i_address_decoder
    (
        .mem_write ( mem_write ),
        .addr      ( addr      ),
        .dev_id    ( dev_id    ),
        .sel       ( sel       ),
        .we_mem    ( we_mem    ),
        .we_1      ( we_1      ),
        .we_2      ( we_2      )
    );

    instruction_rom # (.SIZE (ROM_SIZE)) i_rom
    (
        .addr    ( im_addr ),
        .rdata   ( im_data )
    );

    data_ram # (.SIZE (RAM_SIZE)) i_ram
    (
        .clk           ( clk       ),
        .mem_write     ( we_mem    ),
        .addr          ( addr      ),
        .rdata         ( rdata_mem ),
        .wdata         ( wdata     )
    );
    
    leds # (.w_led (w_led)) i_leds
    (
        .clk          ( clk   ),
        .dev_id       ( dev_id ),
        .write_enable ( we_1   ),
        .wdata        ( wdata  ) ,
    
        .led          ( led    )
    );
    
    switches # (.w_sw (w_sw)) i_switches
    (
        .clk    ( clk     ),
        .dev_id ( dev_id  ),
        .rdata  ( rdata_2 ),

        .sw     ( sw      )
    );
    
    uart # ( .clk_mhz(50) ) i_uart
    (
        .clk          ( clk    ),
        .rst          ( rst    ),
        .write_enable ( we_3   ),
        .dev_id       ( dev_id ),
        .rdata        ( rdata  ),
        .wdata        ( wdata  ),

        .i_uart_rx ( i_uart_rx ),
        .o_uart_tx ( o_uart_tx )
    );

endmodule

`include "lab_top.svh"

module lab_top
# (
    parameter  clk_mhz       = 50,
               w_key         = 4,
               w_sw          = 8,
               w_led         = 8,
               w_digit       = 8,
               w_gpio        = 100,

               screen_width  = 640,
               screen_height = 480,

               w_red         = 4,
               w_green       = 4,
               w_blue        = 4,

               w_x           = $clog2 ( screen_width  ),
               w_y           = $clog2 ( screen_height )
)
(
    input                        clk,
    input                        slow_clk,
    input                        rst,

    // Keys, switches, LEDs

    input        [w_key   - 1:0] key,
    input        [w_sw    - 1:0] sw,
    output logic [w_led   - 1:0] led,

    // A dynamic seven-segment display

    output logic [          7:0] abcdefgh,
    output logic [w_digit - 1:0] digit,

    // Graphics

    input        [w_x     - 1:0] x,
    input        [w_y     - 1:0] y,

    output logic [w_red   - 1:0] red,
    output logic [w_green - 1:0] green,
    output logic [w_blue  - 1:0] blue,

    // Microphone, sound output and UART

    input        [         23:0] mic,
    output       [         15:0] sound,

    input                        uart_rx,
    output                       uart_tx,

    // General-purpose Input/Output

    inout        [w_gpio  - 1:0] gpio
);

    //------------------------------------------------------------------------

       assign led        = '0;
    // assign abcdefgh   = '0;
    // assign digit      = '0;
       assign red        = '0;
       assign green      = '0;
       assign blue       = '0;
       assign sound      = '0;
       assign uart_tx    = '1;

    //------------------------------------------------------------------------

    // rom
    wire [ 4:0] regAddr;  // debug access reg address
    wire [31:0] regData;  // debug access reg data
    wire [31:0] imAddr;   // instruction memory address
    wire [31:0] imData;   // instruction memory data

    // ram
    wire [ 1:0] mem_write; // data write on mem_write (see sr_cpu.svh MW_... constants)
    wire [31:0] addr;      // r/w data address
    wire [31:0] rdata;     // read data 
    wire [31:0] wdata;     // write data

    sr_cpu cpu
    (
        .clk            ( slow_clk ),
        .rst            ( rst      ),

        .instr_addr     ( imAddr ),
        .instr_data     ( imData ),

        .addr           ( addr   ),
        .rdata          ( rdata  ),
        .wdata          ( wdata  ),
        .mem_write      ( mem_write ),
        
        .invalid_instr  (  ),

        .debug_reg_addr ( regAddr ),
        .debug_reg_data ( regData )
    );
    
    wire [ 1:0] rd_sel;
    wire we_mem; // ram
    wire we_1, we_2, we_3; // devices
    wire [31:0] rdata_mem; // ram
    wire [31:0] rdata_1, rdata_2, rdata_3; // devices
    
    // placeholder TODO: remove
    assign rdata_1 = rdata;
    assign rdata_2 = rdata;
    assign rdata_3 = rdata;
    
    always_comb begin
        case (rd_sel)
            `RD_MEM: rdata = rdata_mem;
            `RD_1: rdata = rdata_1;
            `RD_2: rdata = rdata_2;
            `RD_3: rdata = rdata_3;
        endcase
    end
    
    address_decoder addr_decoder
    (
        .mem_write(mem_write),
        .addr(addr),
        .rd_sel(rd_sel),
        .we_mem(we_mem),
        .we_1(we_1),
        .we_2(we_2),
        .we_3(we_3)
    );

    instruction_rom # (.SIZE (64)) rom
    (
        .addr    ( imAddr   ),
        .rdata   ( imData   )
    );

    data_ram # (.SIZE (64)) ram
    (
        .clk           ( clk       ),
        .mem_write     ( we_mem    ),
        .addr          ( addr      ),
        .rdata         ( rdata_mem ),
        .wdata         ( wdata     )
    );

    //------------------------------------------------------------------------

    assign regAddr = 5'd10;  // a0

    localparam w_number = w_digit * 4;

    wire [w_number - 1:0] number
        = w_number' ( key [0] ? regData : imAddr );

    seven_segment_display
    # (
        .w_digit  ( w_digit  ),
        .clk_mhz  ( clk_mhz  )
    )
    display
    (
        .clk      ( clk      ),
        .rst      ( rst      ),

        .number   ( number   ),
        .dots     ( '0       ),

        .abcdefgh ( abcdefgh ),
        .digit    ( digit    )
    );

endmodule

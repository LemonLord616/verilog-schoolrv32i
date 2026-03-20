
module uart
# (
    parameter clk_mhz = 50
)
(
    input          clk,
    input          rst,
    input          write_enable,
    input  [11: 0] dev_id,
    output [31: 0] rdata,
    input  [31: 0] wdata,
    
    input  i_uart_rx,
    output o_uart_tx
);
    // 32'x3000_0fff
    // 32'b0011_0000_0000_0000_0000_1111_1111_1111
    
    // i_ - input - receive from UART
    // o_ - output - send to UART
    wire       o_tready;
    reg        i_tvalid;
    reg [7:0]  i_tdata;
    reg        i_overflow;
    
    localparam byte_width = 1;

    wire [8*byte_width-1:0] o_tdata;
    wire [  byte_width-1:0] o_tkeep;

    wire i_tready;
    wire o_tvalid;
    wire o_tlast;

    uart_rx
    # (
        .CLK_FREQ  ( clk_mhz * 1_000_000 )
    ) inst_uart_rx (
        .clk  ( clk ),
        .rstn ( rst ),
        .i_uart_rx   ( i_uart_rx ),
        .o_tready    ( o_tready ),
        .o_tvalid    ( i_tvalid ),
        .o_tdata     ( i_tdata ),
        .o_overflow  ( i_overflow )
    );
    
    uart_tx
    # (
        .CLK_FREQ   ( clk_mhz * 1_000_000 ),
        .BYTE_WIDTH ( byte_width )
    ) inst_uart_tx (
        .clk  ( clk ),
        .rstn ( rst ),
        .i_tready  ( i_tready ),
        .i_tvalid  ( o_tvalid ),
        .i_tdata   ( o_tdata ),
        .i_tkeep   ( o_tkeep ),
        .i_tlast   ( o_tlast ),
        .o_uart_tx ( o_uart_tx )
    );
    
endmodule
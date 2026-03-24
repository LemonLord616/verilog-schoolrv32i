`include "memory.svh"

module uart
# (
    parameter clk_mhz = 50
)
(
    input          clk,
    input          rst,
    input          write_enable,
    input          read_enable,
    input  [ 1: 0] mem_size,
    input  [11: 0] dev_id,
    output reg [31: 0] rdata,
    input  reg [31: 0] wdata,
    
    input  i_uart_rx,
    output o_uart_tx
);
    // 32'x3000_0fff
    // 32'b0011_0000_0000_0000_0000_1111_1111_1111

    // dev_id map:
    // 0: transmitter/reciever
    // 1: bytes_in_rbuffer
    // 2: bytes_in_wbuffer
    
    // i_ - input - receive from UART
    // o_ - output - send to UART
    reg        o_tready;
    wire       i_tvalid;
    wire [7:0] i_tdata;
    wire       i_overflow;
    
    localparam byte_width = 1;

    reg [8*byte_width-1:0] o_tdata;
    reg [  byte_width-1:0] o_tkeep;

    wire i_tready;
    reg o_tvalid;
    reg o_tlast;

    uart_rx
    # (
        .CLK_FREQ  ( clk_mhz * 1_000_000 )
    ) inst_uart_rx (
        .clk  (  clk ),
        .rstn ( ~rst ),
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
        .clk  (  clk ),
        .rstn ( ~rst ),
        .i_tready  ( i_tready ),
        .i_tvalid  ( o_tvalid ),
        .i_tdata   ( o_tdata ),
        .i_tkeep   ( o_tkeep ),
        .i_tlast   ( o_tlast ),
        .o_uart_tx ( o_uart_tx )
    );
    
    reg  [31: 0] rbuffer;
    reg  [ 2: 0] bytes_in_rbuffer;
    wire [ 2: 0] r_ptr = 3 - bytes_in_rbuffer;
    reg  [31: 0] wbuffer;
    reg  [ 2: 0] bytes_in_wbuffer;
    wire [ 2: 0] w_ptr = 3 - bytes_in_wbuffer;

    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            rdata <= 32'b0;
            rbuffer <= 32'b0;
            bytes_in_rbuffer <= 3'b0;
            o_tready <= 1'b0;
        end
        else begin 
            o_tready <= 1'b0;

            if (read_enable) begin
                case (dev_id)
                    0: begin
                        case (mem_size)
                            `MEM_SIZE_B: begin
                                rdata   <= {24'b0, rbuffer[31-:8]};
                                rbuffer <= {rbuffer[0+:24], 8'b0};
                                bytes_in_rbuffer <= (bytes_in_rbuffer > 0) ? bytes_in_rbuffer - 1 : 3'b0;
                            end
                            `MEM_SIZE_H: begin
                                rdata   <= {16'b0, rbuffer[31-:16]};
                                rbuffer <= {rbuffer[0+:16], 16'b0};
                                bytes_in_rbuffer <= (bytes_in_rbuffer > 1) ? bytes_in_rbuffer - 2 : 3'b0;
                            end
                            `MEM_SIZE_W: begin
                                rdata   <= rbuffer;
                                rbuffer <= 32'b0;
                                bytes_in_rbuffer <= (bytes_in_rbuffer > 3) ? bytes_in_rbuffer - 4 : 3'b0;
                            end
                            default: begin
                                rdata   <= {24'b0, rbuffer[31-:8]};
                                rbuffer <= {rbuffer[0+:24], 8'b0};
                                bytes_in_rbuffer <= (bytes_in_rbuffer > 0) ? bytes_in_rbuffer - 1 : 3'b0;
                            end
                        endcase
                    end
                    1: rdata <= {29'b0, bytes_in_rbuffer};
                    2: rdata <= {29'b0, bytes_in_wbuffer};
                    default: rdata <= 32'b1;
                endcase
            end
            
            if (i_tvalid && !i_overflow && bytes_in_rbuffer < 4) begin
                rbuffer[r_ptr*8+:8] <= i_tdata;
                bytes_in_rbuffer <= bytes_in_rbuffer + 1;
                o_tready <= 1'b1;
            end
        end
    end


    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            wbuffer <= 32'b0;
            bytes_in_wbuffer <= 3'b0;
            o_tdata  <= 0;
            o_tkeep  <= 0;
            o_tvalid <= 1'b0;
            o_tlast  <= 1'b0;
        end
        else begin
            o_tdata  <= 0;
            o_tkeep  <= 0;
            o_tvalid <= 1'b0;
            o_tlast  <= 1'b0;

            if (write_enable) begin
                case (dev_id)
                    0: begin
                        case (mem_size)
                            `MEM_SIZE_B: begin
                                wbuffer <= {wdata[0+:8], wbuffer[31-:24]};
                                bytes_in_wbuffer <= (bytes_in_wbuffer < 4) ? bytes_in_wbuffer + 1 : 3'd4;
                            end
                            `MEM_SIZE_H: begin
                                wbuffer <= {wdata[0+:16], wbuffer[31-:16]};
                                bytes_in_wbuffer <= (bytes_in_wbuffer < 3) ? bytes_in_wbuffer + 2 : 3'd4;
                            end
                            `MEM_SIZE_W: begin
                                wbuffer <= wdata;
                                bytes_in_wbuffer <= (bytes_in_wbuffer < 1) ? bytes_in_wbuffer + 4 : 3'd4;
                            end
                            default: begin
                                wbuffer <= {wdata[0+:8], wbuffer[31-:24]};
                                bytes_in_wbuffer <= (bytes_in_wbuffer < 4) ? bytes_in_wbuffer + 1 : 3'd4;
                            end
                        endcase
                    end
                endcase
            end

            if (i_tready && bytes_in_wbuffer > 0) begin
                o_tkeep[0] <= 1'b1;
                o_tlast <= 1'b0;
                o_tdata <= wbuffer[w_ptr*8+:8];
                o_tvalid <= 1'b1;
                wbuffer[w_ptr*8+:8] <= 8'b0;
                bytes_in_wbuffer <= bytes_in_wbuffer - 1;
            end
        end
    end

endmodule

//
//  schoolRISCV - small RISC-V CPU
//
//  Originally based on Sarah L. Harris MIPS CPU
//  & schoolMIPS project.
//
//  Copyright (c) 2017-2020 Stanislav Zhelnio & Aleksandr Romanov.
//
//  Modified in 2024-2025 by Yuri Panchul & Mike Kuskov.
//

module tb;

    logic        clk;
    logic        rst;

    wire  [31:0] imAddr;   // instruction memory address
    wire  [31:0] imData;   // instruction memory data

    logic [ 4:0] regAddr;  // debug access reg address
    wire  [31:0] regData;  // debug access reg data
    
    wire [7:0] led_placeholder;
    wire [7:0]  sw_placeholder;
    assign sw_placeholder = 8'b0;

    chip_top
    #(
        .ROM_SIZE ( 64 ),
        .RAM_SIZE ( 64 ),
        .w_led    ( 8  ),
        .w_sw     ( 8  )
    ) i_chip_top (
        .clk ( clk ),
        .rst ( rst ),
        .led ( led_placeholder ),
        .sw  (  sw_placeholder ),
        
        .debug_reg_addr ( regAddr ),
        .debug_reg_data ( regData ),
        .debug_im_addr  ( imAddr  ),
        .debug_im_data  ( imData  )
    );

    //------------------------------------------------------------------------

    initial
    begin
        clk = 1'b0;

        forever
            # 5 clk = ~ clk;
    end

    //------------------------------------------------------------------------

    initial
    begin
        rst <= 1'bx;
        repeat (2) @ (posedge clk);
        rst <= 1'b1;
        repeat (2) @ (posedge clk);
        rst <= 1'b0;
    end

    //------------------------------------------------------------------------

    initial
    begin
        `ifdef __ICARUS__
            // Uncomment the following `define
            // to generate a VCD file and analyze it using GTKwave

           $dumpfile ("./sim/icarus/output_files/dump.vcd");
           $dumpvars;
        `endif

        regAddr <= 5'd10;  // a0 register used for I/O

        @ (negedge rst);

        repeat (1000)
        begin
            @ (posedge clk);

            if (  regData == 32'h00213d05    // Fibonacci
                | regData == 32'h1c8cfc00 )  // Factorial
            begin
                $display ("%s PASS", `__FILE__);
                $finish;
            end
        end

        $display ("%s FAIL: none of expected register values occured",
            `__FILE__);

        $finish;
    end

    //------------------------------------------------------------------------

    final
    begin
        $display;
        $display ("Final registers state:");
        for(int i = 0; i < 32; i++)
        begin
            $display ("Reg x%02d, hex: %h, binary: %b", i, i_chip_top.i_cpu.i_rf.rf[i], i_chip_top.i_cpu.i_rf.rf[i]);
        end
    end

    //------------------------------------------------------------------------

    int unsigned cycle = 0;
    bit was_rst = 1'b0;

    logic [31:0] prev_imAddr;
    logic [31:0] prev_regData;

    always @ (posedge clk)
    begin
        $write ("cycle %5d", cycle ++);

        if (rst)
        begin
            $write (" rst");
            was_rst <= 1'b1;
        end
        else
        begin
            $write ("    ");
        end

        if (imAddr !== prev_imAddr)
            $write (" %h", imAddr);
        else
            $write ("         ");

        if (was_rst & ~ rst & $isunknown (imData))
        begin
            $display ("%s FAIL: fetched instruction at address %x contains Xs: %x",
                `__FILE__, imAddr, imData);

            $finish;
        end

        if (regData !== prev_regData)
            $write (" %h", regData);
        else
            $write ("         ");

        prev_imAddr  <= imAddr;
        prev_regData <= regData;

        $display;
    end

endmodule

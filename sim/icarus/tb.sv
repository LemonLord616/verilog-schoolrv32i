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

    logic [ 1:0] mem_write;
    logic [31:0] addr;
    logic [31:0] rdata;
    logic [31:0] wdata;

    sr_cpu cpu
    (
        .clk            ( clk     ),
        .rst            ( rst     ),

        .instr_addr     ( imAddr  ),
        .instr_data     ( imData  ),
        .invalid_instr  (         ),

        .mem_write      ( mem_write ),
        .addr           ( addr   ),
        .rdata          ( rdata   ),
        .wdata          ( wdata   ),

        .debug_reg_addr ( regAddr ),
        .debug_reg_data ( regData )
    );

    instruction_rom # (.SIZE (1024)) rom
    (
        .addr  ( imAddr ),
        .rdata ( imData )
    );

    data_ram # (.SIZE (1024)) i_ram
    (
        .clk          ( clk ),
        .mem_write    ( mem_write ),
        .addr         ( addr ),
        .rdata        ( rdata ),
        .wdata        ( wdata )
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
            $display ("Reg x%02d, hex: %h, binary: %b", i, cpu.rf.rf[i], cpu.rf.rf[i]);
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

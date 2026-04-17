`timescale 1ns/1ps

module RISC_V_CPU_tb();

    reg        clk;
    reg        rst;
    reg  [4:0] dbg_sel;
    wire [31:0] pc_out;
    wire [31:0] dbg_data;

    RISC_V_CPU dut (
        .clk      (clk),
        .rst      (rst),
        .pc_out   (pc_out),
        .dbg_sel  (dbg_sel),
        .dbg_data (dbg_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    //register aliases - matching instruction_mem.v
    localparam X0 = 5'd0;
    localparam R1 = 5'd1;   //current Fibonacci value
    localparam R2 = 5'd2;   //next Fibonacci value
    localparam R3 = 5'd3;   //loop counter
    localparam R4 = 5'd4;   //store address
    localparam R5 = 5'd5;   //temp

    //counters
    integer pass_count;
    integer fail_count;

    //task: read a register through the debug port and check its value
    task check_reg;
        input [255:0] msg;
        input [4:0]   reg_num;
        input [31:0]  expected;
        begin
            dbg_sel = reg_num;
            #2; //combinational - just settle
            if (dbg_data === expected) begin
                $display("PASSED:  %s | x%02d = 0x%08h", msg, reg_num, dbg_data);
                pass_count = pass_count + 1;
            end else begin
                $display("FAILED:  %s | x%02d = 0x%08h, expected = 0x%08h",msg, reg_num, dbg_data, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //task: check a word in data memory directly
    //using hierarchical reference into dmem
    //word_addr = byte_addr / 4
    task check_mem;
        input [255:0] msg;
        input [9:0]   word_addr;
        input [31:0]  expected;
        reg   [31:0]  got;
        begin
            got = dut.data_mem_inst.mem[word_addr];
            if (got === expected) begin
                $display("PASS  %s | mem[%0d] = %0d", msg, word_addr, got);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL  %s | mem[%0d] = %0d, expected = %0d",msg, word_addr, got, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //task: check PC is stuck at expected address
    //(verifies the halt instruction is reached)
    task check_halted;
        input [31:0] expected_pc;
        reg   [31:0] pc_before;
        begin
            pc_before = pc_out;
            @(posedge clk); #2;
            if (pc_out === pc_before && pc_out === expected_pc) begin
                $display("PASS  CPU halted at PC = 0x%08h", pc_out);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL  CPU not halted | PC = 0x%08h, expected = 0x%08h",pc_out, expected_pc);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //main test
    initial begin
        pass_count = 0;
        fail_count = 0;
        dbg_sel    = 0;

        //reset - hold for 3 cycles
        rst = 1;
        repeat(3) @(posedge clk);
        #2;
        rst = 0;
        $display("Reset released at t=%0t\n", $time);

        //run the Fibonacci program
        //instruction count:
        //4 init instructions
        //6 instructions per loop iteration x 10 iterations = 60
        //1 halt instruction
        //total = 65 instructions minimum

        //run 200 cycles to be safe

        $display("Running Fibonacci program...");
        repeat(200) @(posedge clk);
        #2;
        $display("Done at t=%0t\n", $time);

        //check PC is halted at JAL x0, 0
        //INSTR_11 is at word address 11
        //byte address = 11 * 4 = 44 = 0x0000002C

        $display("Halt check");
        check_halted(32'h0000002C);

        //check final register values
        //after 10 iterations of Fibonacci:
        //   R1 = F(9)  = 34    (last value stored)
        //   R2 = F(10) = 55    (next value, not stored)
        //   R3 = 0             (counter decremented to 0)
        //   R4 = 256 + 10*4    (base addr advanced 10 times)
        //      = 296 = 0x128
        //   X0 = 0             (always)
        // ─────────────────────────────────────────
        $display("\nRegister file");
        check_reg("x0 always zero  ", X0, 32'h00000000);
        check_reg("R1 last stored  ", R1, 32'h00000037);  //55 = 0x37
        check_reg("R2 next fib     ", R2, 32'h00000059);  //89 = 0x59
        check_reg("R3 counter      ", R3, 32'h00000000);  //exhausted
        check_reg("R4 store addr   ", R4, 32'h00000028);  //40 = 0x28

        //check data memory
        //results stored from byte address 256
        //byte addr 256 = word addr 64 (256/4 = 64)
        //Fibonacci sequence: 0,1,1,2,3,5,8,13,21,34

        $display("\nData memory (Fibonacci results)");
        check_mem("F(0)  = 0  ", 10'd0, 32'd0 );
        check_mem("F(1)  = 1  ", 10'd1, 32'd1 );
        check_mem("F(2)  = 1  ", 10'd2, 32'd1 );
        check_mem("F(3)  = 2  ", 10'd3, 32'd2 );
        check_mem("F(4)  = 3  ", 10'd4, 32'd3 );
        check_mem("F(5)  = 5  ", 10'd5, 32'd5 );
        check_mem("F(6)  = 8  ", 10'd6, 32'd8 );
        check_mem("F(7)  = 13 ", 10'd7, 32'd13);
        check_mem("F(8)  = 21 ", 10'd8, 32'd21);
        check_mem("F(9)  = 34 ", 10'd9, 32'd34);

        //check memory below and above result region
        //is untouched (should still be 0)

        $display("\nMemory boundary check");
        check_mem("below results   ", 10'd63, 32'd0);   //word just before base
        check_mem("above results   ", 10'd74, 32'd0);   //word just after last

        //reset test - reset mid-run and verify
        //PC goes back to 0 and results are rewritten

        $display("\nReset test");
        rst = 1;
        repeat(3) @(posedge clk);
        #2;
        rst = 0;

        //PC should be 0 immediately after reset
        if (pc_out === 32'h00000000) begin
            $display("PASS  PC = 0x00000000 after reset");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL  PC = 0x%08h after reset, expected 0x00000000", pc_out);
            fail_count = fail_count + 1;
        end

        //run again and check results are identical
        repeat(200) @(posedge clk);
        #2;
        check_mem("F(0) after reset", 10'd0, 32'd0 );
        check_mem("F(5) after reset", 10'd5, 32'd5 );
        check_mem("F(9) after reset", 10'd9, 32'd34);

        //summary
        $display("\nResults: %0d passed, %0d failed",
                 pass_count, fail_count);
        $finish;
    end

    // ─────────────────────────────────────────────
    // PC trace - print every cycle so you can watch
    // the program execute in the transcript
    // Comment this out if the output is too noisy
    // ─────────────────────────────────────────────
    always @(posedge clk) begin
        if (!rst)
            $display("t=%5.0f  PC=0x%08h  instr=0x%08h",
                     $time, pc_out, dut.imem_inst.instr);
    end

    // ─────────────────────────────────────────────
    // Waveform dump
    // ─────────────────────────────────────────────
    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, RISC_V_CPU_tb);
    end

endmodule
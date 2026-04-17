`timescale 1ns/1ps

module instruction_mem_tb();

    reg  [31:0] addr;
    wire [31:0] instr;

    instruction_mem dut(
        .addr(addr),
        .instr(instr)
    );
    
    task check;
        input [125:0] msg;
        input [31:0]  in;
        input [31:0]  expected;
        begin
            addr = in;
            #10;
            if(expected !== instr) begin
                $display("ERROR: %s | got = %h, expected = %h ",msg, instr, expected);
            end else begin
                $display("PASSED: %s | got = %h, expected = %h ",msg, instr, expected);
            end
        end
        
    endtask

    initial begin
        
        check("Instruction 0 ", 32'h00000000, dut.INSTR_0);
        check("Instruction 1 ", 32'h00000004, dut.INSTR_1);
        check("Instruction 2 ", 32'h00000008, dut.INSTR_2);
        check("Instruction 3 ", 32'h0000000C, dut.INSTR_3);
        check("Instruction 4 ", 32'h00000010, dut.INSTR_4);
        check("Instruction 5 ", 32'h00000014, dut.INSTR_5);
        check("Instruction 6 ", 32'h00000018, dut.INSTR_6);
        check("Instruction 7 ", 32'h0000001C, dut.INSTR_7);
        check("Instruction 8 ", 32'h00000020, dut.INSTR_8);
        check("Instruction 9 ", 32'h00000024, dut.INSTR_9);
        check("Instruction 10 ", 32'h00000028, dut.INSTR_10);
        check("Instruction 11 ", 32'h0000002C, dut.INSTR_11);
        check("Default ", 32'h00000100, 32'h00000013);
        
        $finish;
    end

endmodule
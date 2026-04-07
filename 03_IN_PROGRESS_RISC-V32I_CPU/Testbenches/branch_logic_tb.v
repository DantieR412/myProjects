`timescale 1ns / 1ps

module branch_logic_tb();

    reg [2:0] funct3;
    reg branch;
    reg zero;
    reg alu_result_0;
    wire branch_taken;

    branch_logic dut(
        .funct3(funct3),
        .branch(branch),
        .zero(zero),
        .alu_result_0(alu_result_0),
        .branch_taken(branch_taken)
    );

    task check;
        input expected;
        input [127:0] msg;
        begin
            #1;
            if (branch_taken !== expected) begin
                $display("FAILED: %s | got = %b, expected = %b",msg, branch_taken, expected);
            end else begin
                $display("PASSED: %s | got = %b, expected = %b",msg, branch_taken, expected);
            end
        end
    endtask

    initial begin
    
        //BEQ
        funct3 = 3'b000; branch = 1; zero = 1;
        check(1'b1, "BEQ taken (zero=1)");

        funct3 = 3'b000; branch = 1; zero = 0;
        check(1'b0, "BEQ not taken (zero=0)");
        
        //BNE
        funct3 = 3'b001; branch = 1; zero = 0;
        check(1'b1, "BNE taken (zero=0)");

        funct3 = 3'b001; branch = 1; zero = 1;
        check(1'b0, "BNE not taken (zero=1)");

        //BLT
        funct3 = 3'b100; branch = 1; alu_result_0 = 1;
        check(1'b1, "BLT taken");

        funct3 = 3'b100; branch = 1; alu_result_0 = 0;
        check(1'b0, "BLT not taken");

        //BGE
        funct3 = 3'b101; branch = 1; alu_result_0 = 0;
        check(1'b1, "BGE taken");

        funct3 = 3'b101; branch = 1; alu_result_0 = 1;
        check(1'b0, "BGE not taken");

        //BLTU
        funct3 = 3'b110; branch = 1; alu_result_0 = 1;
        check(1'b1, "BLTU taken");

        funct3 = 3'b110; branch = 1; alu_result_0 = 0;
        check(1'b0, "BLTU not taken");

        //BGEU
        funct3 = 3'b111; branch = 1; alu_result_0 = 0;
        check(1'b1, "BGEU taken");

        funct3 = 3'b111; branch = 1; alu_result_0 = 1;
        check(1'b0, "BGEU not taken");

        //branch = 0 (global disable)
        funct3 = 3'b000; branch = 0; zero = 1;
        check(1'b0, "Branch disabled (BEQ)");

        funct3 = 3'b100; branch = 0; alu_result_0 = 1;
        check(1'b0, "Branch disabled (BLT)");

        //default case
        funct3 = 3'b010; branch = 1; zero = 1; alu_result_0 = 1;
        check(1'b0, "Default case (invalid funct3)");

        $finish;
    end

endmodule
`timescale 1ns / 1ps

module writeback_mux_tb();

    reg [1:0] mem_to_reg;
    reg [31:0] alu_result;
    reg [31:0] pc_plus4;
    reg [31:0] mem_rdata;
    wire [31:0] wb_data;

    writeback_mux dut(
        .mem_to_reg(mem_to_reg),
        .alu_result(alu_result),
        .pc_plus4(pc_plus4),
        .mem_rdata(mem_rdata),
        .wb_data(wb_data)
    );

    task check;
        input [31:0] expected;
        input [127:0] msg;
        begin
            #1;
            if (wb_data !== expected) begin
                $display("FAILED: %s | got = %h, expected = %h",msg, wb_data, expected);
            end else begin
                $display("PASSED: %s | got = %h, expected = %h",msg, wb_data, expected);
            end
        end
    endtask

    initial begin

        //ALU result
        mem_to_reg = 2'b00;
        alu_result = 32'hAABBCCDD;
        pc_plus4   = 32'h11111111;
        mem_rdata  = 32'h22222222;
        check(32'hAABBCCDD, "ALU result selected");

        //Memory read
        mem_to_reg = 2'b01;
        alu_result = 32'hAAAAAAAA;
        pc_plus4   = 32'hBBBBBBBB;
        mem_rdata  = 32'h12345678;
        check(32'h12345678, "Memory data selected");

        //PC + 4
        mem_to_reg = 2'b10;
        alu_result = 32'hAAAAAAAA;
        pc_plus4   = 32'h00000004;
        mem_rdata  = 32'hBBBBBBBB;
        check(32'h00000004, "PC+4 selected");

        //Default case
        mem_to_reg = 2'b11;
        alu_result = 32'hDEADBEEF;
        pc_plus4   = 32'h11111111;
        mem_rdata  = 32'h22222222;
        check(32'hDEADBEEF, "Default -> ALU result");

        //Edge/robustness
        mem_to_reg = 2'bxx;
        alu_result = 32'hCAFEBABE;
        pc_plus4   = 32'h11111111;
        mem_rdata  = 32'h22222222;
        check(32'hCAFEBABE, "X input -> default behavior");

        $finish;
    end

endmodule
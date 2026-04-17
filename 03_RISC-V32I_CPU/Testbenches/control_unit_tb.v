`timescale 1ns/1ps

module control_unit_tb;

    reg  [6:0] opcode;
    wire reg_write;
    wire alu_src;
    wire alu_a_sel;
    wire mem_write;
    wire mem_read;
    wire [1:0] mem_to_reg;
    wire branch;
    wire jump;
    wire jump_reg;
    wire [1:0] alu_op;

    control_unit dut (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_a_sel(alu_a_sel),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .alu_op(alu_op)
    );

    task check;
        input [125:0] msg;
        input [6:0] op;   
        input exp_reg_write;
        input exp_alu_src;
        input exp_alu_a_sel;
        input exp_mem_write;
        input exp_mem_read;
        input [1:0] exp_mem_to_reg;
        input exp_branch;
        input exp_jump;
        input exp_jump_reg;
        input [1:0] exp_alu_op;  
        begin
            opcode = op;
            #10;
            if ({reg_write, alu_src, alu_a_sel, mem_write, mem_read,
                 mem_to_reg, branch, jump, jump_reg, alu_op} !==
                {exp_reg_write, exp_alu_src, exp_alu_a_sel, exp_mem_write, exp_mem_read,
                 exp_mem_to_reg, exp_branch, exp_jump, exp_jump_reg, exp_alu_op})
            begin
                $display("FAIL: %s | opcode=%b | got = rw=%b as=%b aa=%b mw=%b mr=%b mtr=%b br=%b j=%b jr=%b aluop=%b, expected = rw=%b as=%b aa=%b mw=%b mr=%b mtr=%b br=%b j=%b jr=%b aluop=%b",
                    msg,op,
                    reg_write, alu_src, alu_a_sel, mem_write, mem_read,
                    mem_to_reg, branch, jump, jump_reg, alu_op,
                    exp_reg_write, exp_alu_src, exp_alu_a_sel, exp_mem_write, exp_mem_read,
                    exp_mem_to_reg, exp_branch, exp_jump, exp_jump_reg, exp_alu_op);
            end else begin
                $display("PASSED: %s | opcode=%b | got = rw=%b as=%b aa=%b mw=%b mr=%b mtr=%b br=%b j=%b jr=%b aluop=%b, expected = rw=%b as=%b aa=%b mw=%b mr=%b mtr=%b br=%b j=%b jr=%b aluop=%b",
                    msg,op,
                    reg_write, alu_src, alu_a_sel, mem_write, mem_read,
                    mem_to_reg, branch, jump, jump_reg, alu_op,
                    exp_reg_write, exp_alu_src, exp_alu_a_sel, exp_mem_write, exp_mem_read,
                    exp_mem_to_reg, exp_branch, exp_jump, exp_jump_reg, exp_alu_op);
                end
            end
    endtask

    initial begin

        //R format - register operations
        check("R format", 7'b0110011, 1, 0, 0, 0, 0, 2'b00, 0, 0, 0, 2'b11);
        //I format - immediate operations
        check("I format", 7'b0010011, 1, 1, 0, 0, 0, 2'b00, 0, 0, 0, 2'b11);
        //L format - loads
        check("L format", 7'b0000011, 1, 1, 0, 0, 1, 2'b01, 0, 0, 0, 2'b00);
        //S format - stores
        check("S format", 7'b0100011, 0, 1, 0, 1, 0, 2'b00, 0, 0, 0, 2'b00);
        //B format - branches
        check("B format", 7'b1100011, 0, 0, 0, 0, 0, 2'b00, 1, 0, 0, 2'b01);
        //J format - JAL
        check("J format", 7'b1101111, 1, 0, 0, 0, 0, 2'b10, 0, 1, 0, 2'b00);
        //J - format - JALR
        check("J format register", 7'b1100111, 1, 1, 0, 0, 0, 2'b10, 0, 0, 1, 2'b00);
        //LUI
        check("LUI ", 7'b0110111, 1, 1, 0, 0, 0, 2'b00, 0, 0, 0, 2'b10);
        //AUIPC
        check("AUIPC", 7'b0010111, 1, 1, 1, 0, 0, 2'b00, 0, 0, 0, 2'b00);

        $finish;
    end
endmodule
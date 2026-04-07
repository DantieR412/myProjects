`timescale 1ns / 1ps

module branch_logic(
    input wire [2:0] funct3,
    input wire branch,
    input wire zero, //from ALU, used for BEQ/BNE
    input wire alu_result_0, //bit 0 of ALU result, used for BLT/BGE
    output reg branch_taken
    );
    //alu_op = 2'b01, so ALU already computed the result
    //branch is interpreted based on funct3
    //BEQ/BNE - ALU did SUB, so check zero flag
    //BLT/BGE (or BLTU/BGEU) - ALU did SLT (or SLTU), so check result[0] (or ~result[0])
    always@(*) begin
        case(funct3)
            3'b000: branch_taken = branch & zero; //BEQ
            3'b001: branch_taken = branch & ~zero;//BNE
            3'b100: branch_taken = branch & alu_result_0; //BLT
            3'b101: branch_taken = branch & ~alu_result_0; //BGE
            3'b110: branch_taken = branch & alu_result_0; //BLTU
            3'b111: branch_taken = branch & ~alu_result_0; //BGEU
            default: branch_taken = 1'b0;
        endcase
    end
endmodule
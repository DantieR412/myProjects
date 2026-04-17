`timescale 1ns / 1ps

module writeback_mux(
    input wire [1:0] mem_to_reg,
    input wire [31:0] alu_result,
    input wire [31:0] pc_plus4,
    input wire [31:0] mem_rdata,
    output reg [31:0] wb_data
    );
        always@(*) begin
        case(mem_to_reg)
            2'b00: wb_data = alu_result; //R format, I format, LUI, AUIPC
            2'b01: wb_data = mem_rdata; //L format(loads)
            2'b10: wb_data = pc_plus4; //JAL, JALR(save return address)
            default: wb_data = alu_result;
        endcase
    end
endmodule

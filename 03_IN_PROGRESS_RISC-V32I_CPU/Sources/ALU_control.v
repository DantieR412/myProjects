`timescale 1ns / 1ps

module ALU_control(
    
    input wire [1:0] alu_op,
    input wire [2:0] funct3,
    input wire       funct7_5, //funct7[5] - instr[30]
    input wire       opcode_5, //opcode[5] - instr[5]
    output reg [3:0] alu_ctrl
    );
    
    always@(*) begin
        case(alu_op)
            2'b00:  alu_ctrl = 4'b0000; //force ADD
            
            2'b01:  case(funct3) //Branches
                        3'b000,
                        3'b001: alu_ctrl = 4'b0001; //SUB - for BEQ/BNE (check zero flag)
                        
                        3'b100,
                        3'b101: alu_ctrl = 4'b1000; //SLT - for BLT/BGE
                        
                        3'b110,
                        3'b111: alu_ctrl = 4'b1001; //SLTU - for BLTU/BGEU
                        
                        default: alu_ctrl = 4'b0001;
                    endcase
                    
            2'b10:  alu_ctrl = 4'b1010; //LUI
            
            2'b11:  case(funct3) //R format or I format ALU
                        3'b000: alu_ctrl = (funct7_5 & opcode_5) ? 4'b0001 : 4'b0000; //SUB or ADD
                        3'b001: alu_ctrl = 4'b0101; //SLL/SLLI
                        3'b010: alu_ctrl = 4'b1000; //SLT/SLTI
                        3'b011: alu_ctrl = 4'b1001; //SLTU/SLTIU
                        3'b100: alu_ctrl = 4'b0100; //XOR/XORI
                        3'b101: alu_ctrl = funct7_5 ? 4'b0111 : 4'b0110; //SRA/SRAI or SRL/SRLI
                        3'b110: alu_ctrl = 4'b0011; //OR/ORI
                        3'b111: alu_ctrl = 4'b0010; //AND/ANDI
                        default: alu_ctrl = 4'b0000; //DEFAULT ADD
                    endcase
            
            default: alu_ctrl = 4'b0000; //DEFAULT ADD
      endcase
    end
        
endmodule

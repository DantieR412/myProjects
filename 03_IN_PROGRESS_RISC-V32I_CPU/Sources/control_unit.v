`timescale 1ns / 1ps

module control_unit(

    input wire [6:0]    opcode,   
    output reg          reg_write, //enable register file write
    output reg          alu_src,   //'0' = use RS2, '1' = use immediate as ALU B input
    output reg          alu_a_sel, //'0' = use RS1, '1' = use PC (for AUIPC)
    output reg          mem_write, //enable data memory write
    output reg          mem_read,  //enable data memory read
    output reg [1:0]    mem_to_reg,//writeback source: '00' = ALU, '01' = memory, '10' = PC + 4
    output reg          branch,    //used for branches
    output reg          jump,      //JAL
    output reg          jump_reg,  //JALR
    output reg [1:0]    alu_op     //guides alu_control
    );
    
    always@(*) begin
    
        //defaults - everything off
        reg_write   = 1'b0;
        alu_src     = 1'b0;
        alu_a_sel   = 1'b0;
        mem_write   = 1'b0;
        mem_read    = 1'b0;
        mem_to_reg  = 2'b00;
        branch      = 1'b0;
        jump        = 1'b0;
        jump_reg    = 1'b0;
        alu_op      = 2'b00;
    
        case(opcode)
            
            7'b0110011: begin //R format: ADD,SUB,AND,OR,XOR,SLL,SRL,SRA,SLT,SLTU
                reg_write = 1'b1;
                alu_op    = 2'b11;
            end
            
            7'b0010011: begin //I format: ADDI,ANDI,ORI,XORI,SLTI,SLTUI,SLLI,SRLI,SRAI
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b11;
            end
            
            7'b0000011: begin //L format: LW,LH,LB,LHU,LBU
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 2'b01; //writeback(WB) from memory
                alu_op     = 2'b00; //ADD for address calc
            end
            
            7'b0100011: begin //S format: SW,SH,SB
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = 2'b00; //ADD for address calc
            end
            
            7'b1100011: begin //B format: BEQ,BNE,BLT,BGE,BLTU,BGEU
                branch = 1'b1;
                alu_op = 2'b01; //branch comparison
            end
            
            7'b1101111: begin //J format: JAL
                reg_write  = 1'b1;
                jump       = 1'b1;
                mem_to_reg = 2'b10; //write back PC + 4 (return address)
                alu_op     = 2'b00;
            end
            
            7'b1100111: begin //J format: JALR
                reg_write  = 1'b1;
                jump_reg   = 1'b1;
                alu_src    = 1'b1; //immediate for RS1 + imm address
                mem_to_reg = 2'b10;//writeback PC + 4
                alu_op     = 2'b00;//ADD for address calc
            end
            
            7'b0110111: begin //LUI
                reg_write = 1'b1;
                alu_src   = 1'b1; //immediate goes into ALU B
                alu_op    = 2'b10;//LUI
            end
            
            7'b0010111: begin //AUIPC
                reg_write = 1'b1;
                alu_src   = 1'b1; // B = immediate
                alu_a_sel = 1'b1; // A = PC
                alu_op    = 2'b00;//ADD: PC + imm
            end
            
            default: begin end //NOP - all outputs stay 0
        endcase  
    end    
endmodule

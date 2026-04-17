 `timescale 1ns / 1ps

module ALU_control_tb();

    reg [1:0] alu_op;
    reg [2:0] funct3;
    reg       funct7_5;
    reg       opcode_5;
    wire [3:0] alu_ctrl;
    
    ALU_control dut(
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .opcode_5(opcode_5),
        .alu_ctrl(alu_ctrl)
    );

    task check;
        input [3:0] expected;
        input [127:0] msg;
        begin
            #1;
            if(alu_ctrl !== expected) begin
                $display("FAILED: %s | got = %h, expected = %h",msg,alu_ctrl,expected);
            end else begin
                $display("PASS: %s | got = %h, expected = %h",msg,alu_ctrl,expected);
            end
        end
    endtask
    
    initial begin
        
        //ADD
        alu_op = 2'b00;
        funct3 = 3'bxxx;
        funct7_5 = 0;
        opcode_5 = 0;
        check(4'b0000, "Forced ADD");
        
        //Branches
        alu_op = 2'b01;
        funct3 = 3'b000; check(4'b0001, "BEQ/BNE - SUB");
        funct3 = 3'b001; check(4'b0001, "BEQ/BNE - SUB");
        funct3 = 3'b100; check(4'b1000, "BLT/BGE - SLT");
        funct3 = 3'b101; check(4'b1000, "BLT/BGE - SLT");
        funct3 = 3'b110; check(4'b1001, "BLTU/BGEU - SLTU");   
        funct3 = 3'b111; check(4'b1001, "BLTU/BGEU - SLTU"); 
    
        //LUI
        alu_op = 2'b10;
        check(4'b1010, "LUI");
    
        //ALU operations
        //ADD/ADDI vs SUB
        alu_op = 2'b11;
        funct3 = 3'b000; 
        funct7_5 = 0; 
        opcode_5 = 0;
        check(4'b0000, "ADD I format");
        
        funct3 = 3'b000; 
        funct7_5 = 0; 
        opcode_5 = 1;
        check(4'b0000, "ADD R format");
        
        funct3 = 3'b000; 
        funct7_5 = 1; 
        opcode_5 = 1;
        check(4'b0001, "SUB R format");
        
        //SLL/SLLI
        funct3 = 3'b001;
        check(4'b0101, "SLL/SLLI");
        
        //SLT/SLTI
        funct3 = 3'b010;
        check(4'b1000, "SLT/SLTI");
        
        //SLTU/SLTUI
        funct3 = 3'b011;
        check(4'b1001, "SLTU/SLTUI");
        
        //XOR/XORI
        funct3 = 3'b100;
        check(4'b0100, "XOR/XORI");
        
        //SRA/SRAI vs SRL/SRLI
        funct3 = 3'b101;
        funct7_5 = 0; check(4'b0110, "SRL/SRLI");
        funct7_5 = 1; check(4'b0111, "SRA/SRAI");
        
        //OR/ORI
        funct3 = 3'b110;
        check(4'b0011, "OR/ORI");
        
        //AND/ANDI
        funct3 = 3'b111;
        check(4'b0010, "AND/ANDI");
        
        //default : ADD
        alu_op = 2'b01;
        funct3 = 3'b010;    //doesn't exist, so it should redirect to default value
        check(4'b0000, "default : ADD");
        
        //edge/robustness test
        alu_op = 2'b11;
        funct3 = 3'b000; funct7_5 = 1; opcode_5 = 0;
        check(4'b0000, "INVALID SUB (I format should still be ADD)");
        
        $finish;
    end
    
endmodule

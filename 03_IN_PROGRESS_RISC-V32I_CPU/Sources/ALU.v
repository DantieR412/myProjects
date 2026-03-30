`timescale 1ns / 1ps

module ALU(

    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0]  alu_sel,
    output reg [31:0] result,
    output wire       zero
    );
    
    assign zero = (result == 32'b0); //used for BEQ/BNE instructions
    
    always@(a,b,alu_sel) begin
        case(alu_sel)
            4'b0000: result = a + b;                                        //ADD
            4'b0001: result = a - b;                                        //SUB
            4'b0010: result = a & b;                                        //AND
            4'b0011: result = a | b;                                        //OR
            4'b0100: result = a ^ b;                                        //XOR
            4'b0101: result = a << b[4:0];                                  //SLL
            4'b0110: result = a >> b[4:0];                                  //SRL
            4'b0111: result = $signed(a) >>> b[4:0];                        //SRA
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;    //SLT
            4'b1001: result =       (a < b)             ? 32'b1 : 32'b0;    //SLTU
            4'b1010: result = b;                                            //LUI
            default: result = 32'b0;
        endcase
    end
    
endmodule

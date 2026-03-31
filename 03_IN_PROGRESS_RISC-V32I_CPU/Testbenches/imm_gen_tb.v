`timescale 1ns/1ps

module imm_gen_tb;

    reg  [31:0] instr;
    wire [31:0] imm;

    imm_gen dut(
        .instr(instr),
        .imm(imm)
    );
    
    task check;
        input [255:0] msg;
        input [31:0] instruction;
        input [31:0] expected;
        begin
            instr = instruction;
            #10;
            if(expected !== imm) begin
                $display("FAILED: %s | got = %h, expected = %h",msg,imm,expected);
            end else begin
                $display("PASS: %s | got = %h, expected = %h",msg,imm,expected);
            end
        end
    endtask
    
    initial begin
        //I format
        check("I +5", 32'h00500093, 32'h00000005);   //ADDI
        check("I -1", 32'hFFF00093, 32'hFFFFFFFF);   //ADDI   
        check("I LW+12", 32'h00c12083, 32'h0000000C);//LW
        
        //S format
        check("S +8", 32'h00112423, 32'h00000008);  //SW
        check("S -4", 32'hFE112E23, 32'hFFFFFFFC);  //SW
        
        //B format
        check("B +8", 32'h00000463, 32'h00000008);  //BEQ
        check("B -4", 32'hFE209EE3, 32'hFFFFFFFC);  //BNE
        
        //U format
        check("U LUI", 32'h123450B7, 32'h12345000);  //LUI
        check("U AUIPC", 32'h00001097, 32'h00001000);  //AUIPC
        
        //J format
        check("J +8", 32'h008000EF, 32'h00000008);  //JAL
        check("J -4", 32'hFFDFFF6F, 32'hFFFFFFFC);  //JAL
        
        //default
        check("default ", 32'h00000000, 32'h00000000);
        
        $finish;      
    end
endmodule

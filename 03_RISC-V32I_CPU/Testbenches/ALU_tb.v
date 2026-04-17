`timescale 1ns / 1ps

module ALU_tb();

    reg [31:0]   a;
    reg [31:0]   b;
    reg [3:0]    alu_sel;
    wire [31:0]  result;
    wire         zero;
    
    ALU dut(
        .a(a),
        .b(b),
        .alu_sel(alu_sel),
        .result(result),
        .zero(zero)
    );
    
    task self_check;
        input [31:0] expected;
        begin
            #1;
            if(result != expected) begin
                $display("ERROR: sel = %b, a = %h, b = %h -> result = %h. (expected %h)",alu_sel,a,b,result,expected);
            end else begin
                $display("PASSED: sel = %b, a = %h, b = %h -> result = %h. (expected %h)",alu_sel,a,b,result,expected);
            end
        end
    endtask

    initial begin
        $display("Starting ALU testbench...");
        
        //ADD
        a = 10; b = 5; alu_sel = 4'b0000; self_check(15); #10;
        //SUB 
        a = 15; b = 12; alu_sel = 4'b0001; self_check(3); #10;
        //AND
        a = 32'hF0FF; b = 32'h000F; alu_sel = 4'b0010; self_check(32'h000F); #10;
        //OR
        a = 32'hFFF0; b = 32'h0F0F; alu_sel = 4'b0011; self_check(32'hFFFF); #10;
        //XOR
        a = 32'hFF00; b = 32'h0F0F; alu_sel = 4'b0100; self_check(32'hF00F); #10;
        //SLL 
        a = 32'b00001111; b = 2; alu_sel = 4'b0101; self_check(8'b00111100); #10;
        //SRL
        a = 32'b00111100; b = 2; alu_sel = 4'b0110; self_check(8'b00001111); #10;
        //SRA 
        a = -16; b = 2; alu_sel = 4'b0111; self_check(-4); #10;
        //SLT
        a = -2; b = 5; alu_sel = 4'b1000; self_check(1); #10;
        //SLTU 
        a = 5; b = 2; alu_sel = 4'b1001; self_check(0); #10;
        //LUI
        a = 0; b = 32'hFFFF1234; alu_sel = 4'b1010; self_check(32'hFFFF1234); #10;
        //zero flag test
        a = 10; b = 10; alu_sel = 4'b0001;
        #10;
        if(zero !== 1)   $display("ERROR: zero flag test failed");
        else            $display("PASSED: zero flag test passed");
        
        $display("ALU testbench finished.");
        $stop;
    end

endmodule

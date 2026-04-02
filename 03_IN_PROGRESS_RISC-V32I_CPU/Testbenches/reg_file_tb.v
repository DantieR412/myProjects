`timescale 1ns/1ps

module reg_file_tb();

    reg clk;
    reg rst;
    reg we;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] wdata;
    wire [31:0] rdata1;
    wire [31:0] rdata2;
    reg [4:0] dbg_sel;
    wire [31:0] dbg_data;
    
    // DUT
    reg_file uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wdata(wdata),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .dbg_sel(dbg_sel),
        .dbg_data(dbg_data)
    );

    always #5 clk = ~clk;

    task check;
        input [31:0] got;
        input [31:0] expected;
        input [255:0] msg;
        begin
            if(got != expected) begin
                $display("[@%t ns] ERROR: %s; got = %h, expected = %h",$time,msg,got,expected);
            end else begin
                $display("[@%0t] PASSED: %s; got = %h, expected = %h",$time,msg,got,expected);
            end
        end
    endtask
    
    initial begin
        clk = 0;
        rst = 1;
        we = 0;
        rs1 = 0;        //initialize inputs with 0
        rs2 = 0;
        rd = 0;
        wdata = 0;
        dbg_sel = 0;
        
        //reset test
        #10;
        
        rst = 0; 
        rs1 = 5'd1;
        rs2 = 5'd2;
        #10;
        check(rdata1,32'd0, "Reset register 1");
        check(rdata2,32'd0, "Reset register 2");

        //write + read test
        we = 1;
        rd = 5'd5;
        wdata = 32'h12345678;
        #10;
        
        we = 0;
        rs1 = 5'd5;
        #10;

        check(rdata1,32'h12345678, "Write then read register 5");

        //reg0 true '0' test
        we = 1;
        rd = 5'd0;
        wdata = 32'hFFFFFFFF;
        #10;
        
        we = 0;
        rs1 = 5'd0;
        #10;
        
        check(rdata1, 32'd0, "Register 0 force feeding, should stay 0");
        
        //raw bypass test
        we = 1;
        rd = 5'd10;
        wdata = 32'h87654321;
        rs1 = 5'd10;
        #10;
        
        check(rdata1, 32'h87654321, "Raw bypass");
        #10;
        
        //dual read test
        we = 1;
        rd = 5'd3;
        wdata = 32'h11111111;
        #10;
        
        rd = 5'd4;
        wdata = 32'h22222222;
        #10;
        
        we = 0;
        rs1 = 5'd3;
        rs2 = 5'd4;
        #10;
        
        check(rdata1, 32'h11111111, "Port 1 read");
        check(rdata2, 32'h22222222, "Port 2 read");
        
        //same read on both ports test        
        we = 1;
        rd = 5'd7;
        wdata = 32'h77777777;
        #10;
        
        we = 0;
        rs1 = 5'd7;
        rs2 = 5'd7;
        #10;
        
        check(rdata1, 32'h77777777, "Port 1 same read");
        check(rdata2, 32'h77777777, "Port 2 same read");
        
        //debug port test
        we = 1;
        rd = 5'd8;
        wdata = 32'habcabcab;
        #10;
        
        we = 0;
        dbg_sel = 5'd8;
        #10;
        check(dbg_data, 32'habcabcab, "Debug port write and read test");
 
        //another reset test       
        rst = 1;
        #10;
        check(rdata1, 32'h0, "Port 1 reset");
        check(rdata2, 32'h0, "Port 2 reset");
        
    $finish;      
    end
endmodule

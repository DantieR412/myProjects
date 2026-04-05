`timescale 1ns / 1ps

module reg_file(
    input wire         clk,
    input wire         rst,
    input wire         we,          //write enable
    input wire  [4:0]  rs1,         //read address 1
    input wire  [4:0]  rs2,         //read address 2
    input wire  [4:0]  rd,          //write address
    input wire  [31:0] wdata,       //write data
    output wire [31:0] rdata1,      //read data 1
    output wire [31:0] rdata2,      //read data 2
    //debug: select registers via board switches SW[4:0], shown on LEDs
    input wire  [4:0]  dbg_sel,
    output wire [31:0] dbg_data
    );
    
    reg [31:0] regs [1:31]; //index 0 not written - always returns 0 when it is being read
    
    assign rdata1   = (rs1     == 5'd0) ? 32'd0 : regs[rs1];
    assign rdata2   = (rs2     == 5'd0) ? 32'd0 : regs[rs2];
    assign dbg_data = (dbg_sel == 5'd0) ? 32'd0 : regs[dbg_sel];
    
    
    integer i;
    always@(posedge clk) begin
        if(rst) begin //synchronous reset
            for(i = 1; i <= 31; i = i + 1) begin
                regs[i] <= 32'd0;
            end
        end else begin
            if(we && rd != 5'd0) begin
                regs[rd] <= wdata;              //synchrounous write
            end
        end
    end
   
endmodule

`timescale 1ns / 1ps

module data_mem_tb();

    reg clk;
    reg we;
    reg [31:0] addr;
    reg [31:0] wdata;
    reg [2:0] funct3;
    wire [31:0] rdata;

    data_mem dut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .funct3(funct3),
        .rdata(rdata)
    );

    always #5 clk = ~clk;

    task store;
        input [31:0] t_addr;
        input [31:0] t_wdata;
        input [2:0]  t_funct3;
        begin
            @(negedge clk); //to avoid delta-cycle ambiguity - race condition
            addr = t_addr;
            wdata = t_wdata;
            funct3 = t_funct3;
            we = 1;
            @(negedge clk);
            we = 0;
        end
    endtask

    task load;
        input [125:0] msg;
        input [31:0] t_addr;
        input [2:0]  t_funct3;
        input [31:0] expected;
        begin
            addr = t_addr;
            funct3 = t_funct3;
            we = 0;
            #1; //a little delay for combinational logic to settle and get a good read
            if(rdata !== expected) begin
                $display("FAILED: %s | addr = %h, funct3 = %b, got = %h, expected = %h",
                msg,t_addr,t_funct3,rdata,expected);
            end else begin
                $display("PASSED: %s | addr = %h, funct3 = %b, got = %h, expected = %h",
                msg,t_addr,t_funct3,rdata,expected);
            end
        end
    endtask

    initial begin
        clk = 0;
        we = 0;
        addr = 0;
        wdata = 0;
        funct3 = 0;
        
        //SB + LW
        store(32'h00000000, 32'hAABBCCDD, 3'b010); //SW
        load("SW/LW", 32'h00000000, 3'b010, 32'hAABBCCDD); //LW
        
        //SB + LB/LBU
        store(32'h00000001, 32'h000000AA, 3'b000); //SB
        
        load("SB/LB", 32'h00000001, 3'b000, 32'hFFFFFFAA); //LB
        load("SB/LBU", 32'h00000001, 3'b100, 32'h000000AA); //LBU
        
        //SH + LH/LHU (lower half)      
        store(32'h00000000, 32'h12345678, 3'b001); //SH (addr[1:0] = boff[1:0]), 0-lower half
        
        load("SH/LH lower", 32'h00000000, 3'b001, 32'h00005678); //LH
        load("SB/LBU lower", 32'h00000000, 3'b101, 32'h00005678); //LHU
        
        //SH + LH/LHU (upper half)    
        store(32'h00000002, 32'h12345678, 3'b001); //SH (addr[1:0] = boff[1:0]), 1-upper half
        
        load("SH/LH upper", 32'h00000002, 3'b001, 32'h00005678); //LH
        load("SB/LBU upper", 32'h00000002, 3'b101, 32'h00005678); //LHU
        
        //SB + LB       
        store(32'h00000000, 32'h11223344, 3'b010); //SW
        
        load("LB byte 0", 32'h00000000, 3'b100, 32'h00000044); //LB byte 0, addr[7:0]
        load("LB byte 1", 32'h00000001, 3'b100, 32'h00000033); //LB byte 0, addr[15:8]
        load("LB byte 2", 32'h00000002, 3'b100, 32'h00000022); //LB byte 0, addr[23:16]
        load("LB byte 3", 32'h00000003, 3'b100, 32'h00000011); //LB byte 0, addr[31:24]
        
        //SB + LB/LBU
        store(32'h00000000, 32'h00000080, 3'b000); //SB (0x80 = negative byte)
        
        load("LB byte 0", 32'h00000000, 3'b000, 32'hFFFFFF80); //LB byte 0, addr[7:0], filled with sign (0x80 is negative)
        load("LBU byte 0", 32'h00000000, 3'b100, 32'h00000080); //LBU byte 0, addr[7:0], filled with 0's
        
        $finish;
    end


endmodule
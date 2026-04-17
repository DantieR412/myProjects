`timescale 1ns / 1ps

module data_mem(

    input wire clk,
    input wire we,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    input wire [2:0] funct3,
    output reg [31:0] rdata
    );
    
    reg [31:0] mem [0:1023]; //4KB
    
    integer i;
    initial begin
        for(i = 0; i < 1024; i = i+1) begin
            mem[i] = 32'd0;    //initialize memory with 0
        end    
    end
    
    wire [9:0] waddr = addr[11:2]; //word address
    wire [1:0] boff = addr[1:0];   //byte offset in word
    
    //load logic (combinational)
    always@(*) begin
        case(funct3)
        
            3'b000: begin //LB sign extended byte
                case(boff)
                    2'b00: rdata = {{24{mem[waddr][7]}}, mem[waddr][7:0]};
                    2'b01: rdata = {{24{mem[waddr][15]}}, mem[waddr][15:8]};
                    2'b10: rdata = {{24{mem[waddr][23]}}, mem[waddr][23:16]};
                    2'b11: rdata = {{24{mem[waddr][31]}}, mem[waddr][31:24]};
                endcase
            end
            
            3'b001: begin //LH sign extended halfword
                case(boff[1]) //only 2 variants: upper half or lower half
                    1'b0: rdata = {{16{mem[waddr][15]}}, mem[waddr][15:0]};
                    1'b1: rdata = {{16{mem[waddr][31]}}, mem[waddr][31:16]};
                endcase
            end
            
            3'b010: begin //LW full word
                rdata = mem[waddr];
            end
            
            3'b100: begin //LBU zero extended byte
                case(boff)
                    2'b00: rdata = {24'd0, mem[waddr][7:0]};
                    2'b01: rdata ={24'd0, mem[waddr][15:8]};
                    2'b10: rdata ={24'd0, mem[waddr][23:16]};
                    2'b11: rdata ={24'd0, mem[waddr][31:24]};
                endcase                
            end
            
            3'b101: begin //LHU zero extended halfword
                case(boff[1]) //only 2 variants: upper half or lower half
                    1'b0: rdata ={16'd0, mem[waddr][15:0]};
                    1'b1: rdata ={16'd0, mem[waddr][31:16]};
                endcase                
            end
            
            default: rdata = mem[waddr];
        endcase
    end
    
    //store logic (asynchrounous secvential)
    
    always@(posedge clk) begin
        if(we) begin
            case(funct3)
                3'b000: begin //SB store 1 byte
                    case(boff)
                        2'b00: mem[waddr][7:0] <= wdata[7:0];
                        2'b01: mem[waddr][15:8] <= wdata[7:0];
                        2'b10: mem[waddr][23:16] <= wdata[7:0];
                        2'b11: mem[waddr][31:24] <= wdata[7:0];
                    endcase
                end
                
                3'b001: begin //SH store half word
                    case(boff[1])
                        1'b0: mem[waddr][15:0] <= wdata[15:0];
                        1'b1: mem[waddr][31:16] <= wdata[15:0];
                    endcase
                end
                
                3'b010: begin //SW store full word
                    mem[waddr] <= wdata;
                end
                
                default: mem[waddr] <= wdata;
            endcase
        end
    end 
endmodule

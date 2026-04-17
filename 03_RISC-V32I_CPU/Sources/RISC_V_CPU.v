`timescale 1ns / 1ps

module RISC_V_CPU(

    input   wire clk,
    input   wire rst,
    output  wire [31:0] pc_out,
    input   wire [4:0]  dbg_sel,
    output  wire [31:0] dbg_data
    );
    
    reg [31:0] pc;  //program counter register
    assign pc_out = pc;
    
    //instruction fetch
    wire [31:0] instr;
    instruction_mem imem_inst(
        .addr(pc),
        .instr(instr)
    );
    
    //decode fixed instruction fields
    wire [6:0] opcode   = instr[6:0];
    wire [4:0] rd       = instr[11:7];
    wire [2:0] funct3   = instr[14:12];
    wire [4:0] rs1      = instr[19:15];
    wire [4:0] rs2      = instr[25:20];
    wire [6:0] funct7   = instr[31:25];
    
    //control unit
    wire reg_write;
    wire alu_src;
    wire alu_a_sel;
    wire mem_write;
    wire mem_read;
    wire [1:0] mem_to_reg;
    wire branch;
    wire jump;
    wire jump_reg;
    wire [1:0] alu_op;
    
    control_unit ctrl_unit_inst(
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_a_sel(alu_a_sel),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .alu_op(alu_op)
    );
    
    //immediate generator
    wire [31:0] imm;
    
    imm_gen imm_gen_inst(
        .instr(instr),
        .imm(imm)
    );
    
    //register file
    wire [31:0] rdata1;
    wire [31:0] rdata2;
    wire [31:0] wb_data; //writeback mux output - combinational
    
    reg_file reg_file_inst(
        .clk(clk),
        .rst(rst),
        .we(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wdata(wb_data),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .dbg_sel(dbg_sel),
        .dbg_data(dbg_data) //for debug
    );
    
    //ALU control
    wire [3:0] alu_ctrl;
    
    ALU_control ALU_ctrl_inst(
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7[5]), //only 5th bit is important for RISC V
        .opcode_5(opcode[5]),
        .alu_ctrl(alu_ctrl)
    );
    
    //ALU input muxes
    //A: alu_a_sel = 0 -> A = rs1(rdata1), alu_a_sel = 1 -> A = PC
    //B: alu_src = 0 -> B = rs2(rdata2), alu_a_sel = 1 -> B = imm
    //PC is used for AUIPC
    //imm is used for I/S/U/J format instructions
    wire [31:0] alu_a = alu_a_sel ? pc : rdata1;
    wire [31:0] alu_b = alu_src ? imm : rdata2;
    
    //ALU
    wire [31:0] alu_result;
    wire zero;
    
    ALU ALU_inst(
    .a(alu_a),
    .b(alu_b),
    .alu_sel(alu_ctrl),
    .result(alu_result),
    .zero(zero)
    );
    
    //data memory
    wire [31:0] mem_rdata;
    
    data_mem data_mem_inst(
        .clk(clk),
        .we(mem_write),
        .addr(alu_result),
        .wdata(rdata2),
        .funct3(funct3),
        .rdata(mem_rdata)
    );
    
    //branch logic
    wire branch_taken;
    
    branch_logic branch_logic_inst(
        .branch(branch),
        .funct3(funct3),
        .zero(zero),
        .alu_result_0(alu_result[0]),
        .branch_taken(branch_taken)
    );
    
    //PC next value logic
    wire [31:0] pc_plus4 = pc + 32'd4;
    wire [31:0] pc_branch = pc + imm; //branch / JAL target
    wire [31:0] pc_jalr = {alu_result[31:1], 1'b0}; //JALR rs1 + imm targer, LSB set to 0
    
    reg [31:0] pc_next;
    
    always@(*) begin
        if(jump_reg) begin
            pc_next = pc_jalr;
        end else if(jump) begin
            pc_next = pc_branch;
        end else if(branch_taken) begin
            pc_next = pc_branch;
        end else begin
            pc_next = pc_plus4;
        end
    end
    
    //PC register - synchronous update, asynchronous reset
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            pc <= 32'd0;
        end else begin
            pc <= pc_next;
        end 
    end
    
    //writeback mux
    writeback_mux wb_inst(
        .mem_to_reg(mem_to_reg),
        .alu_result(alu_result),
        .mem_rdata(mem_rdata),
        .pc_plus4(pc_plus4),
        .wb_data(wb_data)
    );
    
endmodule

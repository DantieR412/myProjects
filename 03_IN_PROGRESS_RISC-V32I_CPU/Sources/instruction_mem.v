`timescale 1ns / 1ps

module instruction_mem(

    input wire [31:0] addr,
    output wire [31:0] instr
    );
    
    //opcodes
    localparam OP_REG    = 7'b0110011; //ADD,SUB,AND,OR,XOR,SLL,SRL,SRA,SLT,SLTU
    localparam OP_IMM    = 7'b0010011; //ADDI,SLTI,SLTUI,XORI,ORI,ANDI,SLLI,SRLI,SRAI
    localparam OP_LOAD   = 7'b0000011; //LW,LH,LB,LHU,LBU
    localparam OP_STORE  = 7'b0100011; //SW,SH,SB
    localparam OP_BRANCH = 7'b1100011; //BEQ,BNE,BLT,BGE,BLTU,BGEU
    localparam OP_JAL    = 7'b1101111; //JAL jump to a known program counter iteration
    localparam OP_JALR   = 7'b1100111; //JALR
    localparam OP_LUI    = 7'b0110111; //LUI
    localparam OP_AUIPC  = 7'b0010111; //AUIPC
    
    //funct3
    //R format ALU / I format ALU (depends on the opcode)
    localparam F3_ADD   = 3'b000; //ADD,ADDI or SUB (based on funct7)
    localparam F3_SLL   = 3'b001; //SLL,SLLI
    localparam F3_SLT   = 3'b010; //SLT,SLTI
    localparam F3_SLTU  = 3'b011; //SLTU,SLTUI
    localparam F3_XOR   = 3'b100; //XOR,XORI
    localparam F3_SR    = 3'b101; //SRL/SRA, SRLI/SRAI (based on funct7)
    localparam F3_OR    = 3'b110; //OR,ORI
    localparam F3_AND   = 3'b111; //AND,ANDI
    
    //L format - loads
    localparam F3_LB    = 3'b000; //LB sign-extended byte
    localparam F3_LH    = 3'b001; //LH sign-extended halfword
    localparam F3_LW    = 3'b010; //LW full word
    localparam F3_LBU   = 3'b100; //LBU zero-extended byte
    localparam F3_LHU   = 3'b101; //LHU zero-extended halfword

    //S format - stores
    localparam F3_SB = 3'b000; //SB store byte
    localparam F3_SH = 3'b001; //SH store halfword
    localparam F3_SW = 3'b010; //SW store word
    
    //B format - branches
    localparam F3_BEQ   = 3'b000; //BEQ branch if equal
    localparam F3_BNE   = 3'b001; //BNE branch if not equal
    localparam F3_BLT   = 3'b100; //BLT branch if less than (signed)
    localparam F3_BGE   = 3'b101; //BLT branch if greater or equal (signed)
    localparam F3_BLTU  = 3'b110; //BLTU branch if less than (unsigned)
    localparam F3_BGEU  = 3'b111; //BGEU branch if greater or equal (unsigned)
    
    //J format - unconditioned jumps
    localparam F3_JALR = 3'b000; //JALR jump where the register points
        
    //funct7 - RISCV32I uses only 2 values of this: funct7[5] = 0/1
    localparam F7_ZERO  = 7'b0000000; //ADD,SLL,SLT,SLTU,XOR,SRL,OR,AND
    localparam F7_ALT   = 7'b0100000; //SUB,SRA
    
    
    //----------------FIBONACCI SEQUENCE COUNTER PROGRAM----------------------- 
    
       
    //registers (5 bits), 32 total, each 32 bits wide
    //for our program (Fibonacci counter) we will use only registers X0 and R1-R5
    localparam X0 = 5'd0; //hardwired to 0 (never changes and always reads 0)
    localparam R1 = 5'd1; //current Fibonacci value
    localparam R2 = 5'd2; //next Fibonacci value
    localparam R3 = 5'd3; //loop counter
    localparam R4 = 5'd4; //store address
    localparam R5 = 5'd5; //temp reg (R1 + R2)     
        
    //program constants
    localparam ZERO      = 12'd0;
    localparam ONE       = 12'd1;
    localparam TEN       = 12'd10;
    localparam BASE_ADDR = 12'd256; //results stored from byte address 256
    localparam FOUR      = 12'd4;
    localparam NEG_ONE   = 12'hFFF; //-1 in 12 bit two complement
    
// Instruction encoding reference
    //
    //  I-type: { imm[11:0],                    rs1, f3, rd,       opcode }
    //  R-type: { funct7,          rs2,  rs1,   f3,  rd,           opcode }
    //  S-type: { imm[11:5], rs2,        rs1,   f3,  imm[4:0],     opcode }
    //  B-type: { imm[12],imm[10:5],rs2, rs1,   f3,  imm[4:1],imm[11], opcode }
    //  J-type: { imm[20],imm[10:1],imm[11],imm[19:12], rd,       opcode }
    //  U-type: { imm[31:12],                            rd,       opcode }
    // ─────────────────────────────────────────────

    // --- initialisation ---
    localparam INSTR_0  = {ZERO,      X0, F3_ADD, R1, OP_IMM};   // addi x1, x0, 0     → x1 = 0  (F0)
    localparam INSTR_1  = {ONE,       X0, F3_ADD, R2, OP_IMM};   // addi x2, x0, 1     → x2 = 1  (F1)
    localparam INSTR_2  = {TEN,       X0, F3_ADD, R3, OP_IMM};   // addi x3, x0, 10    → x3 = 10 (counter)
    localparam INSTR_3  = {BASE_ADDR, X0, F3_ADD, R4, OP_IMM};   // addi x4, x0, 256   → x4 = base address

    // --- loop body (word address 4, byte address 0x10) ---
    localparam INSTR_4  = {7'd0,    R1, R4, F3_SW,  5'd0, OP_STORE};      // sw   x1, 0(x4)     → store current value
    localparam INSTR_5  = {F7_ZERO, R2, R1, F3_ADD, R5,   OP_REG};        // add  x5, x1, x2    → x5 = next value
    localparam INSTR_6  = {ZERO,    R2, F3_ADD,     R1,   OP_IMM};        // addi x1, x2, 0     → x1 = x2
    localparam INSTR_7  = {ZERO,    R5, F3_ADD,     R2,   OP_IMM};        // addi x2, x5, 0     → x2 = x5
    localparam INSTR_8  = {FOUR,    R4, F3_ADD,     R4,   OP_IMM};        // addi x4, x4, 4     → advance store addr
    localparam INSTR_9  = {NEG_ONE, R3, F3_ADD,     R3,   OP_IMM};        // addi x3, x3, -1    → decrement counter

    // bne x3, x0, -24  (jump back 6 instructions to INSTR_4)
    // imm = -24 = 13'b1_1111_1110_1000
    // imm[12]=1, imm[11]=1, imm[10:5]=111110, imm[4:1]=1000
    localparam INSTR_10 = {1'b1, 6'b111111, X0, R3, F3_BNE, 4'b0100, 1'b1, OP_BRANCH};

    // jal x0, 0  → halt (jumps to itself forever)
    localparam INSTR_11 = {1'b0, 10'b0, 1'b0, 8'b0, X0, OP_JAL};

    reg [31:0] mem_content = 32'h00000013; //initialize with 0 (NOP)
    
    always@(*) begin
        case(addr[11:2])
            10'd0:  mem_content =   INSTR_0;
            10'd1:  mem_content =   INSTR_1;
            10'd2:  mem_content =   INSTR_2;
            10'd3:  mem_content =   INSTR_3;
            10'd4:  mem_content =   INSTR_4;
            10'd5:  mem_content =   INSTR_5;
            10'd6:  mem_content =   INSTR_6;
            10'd7:  mem_content =   INSTR_7;
            10'd8:  mem_content =   INSTR_8;
            10'd9:  mem_content =   INSTR_9;
            10'd10:  mem_content =  INSTR_10;
            10'd11:  mem_content = INSTR_11;
            default:  mem_content = 32'h00000013; //NOP
        endcase
    end
    
    assign instr = mem_content;
        
endmodule

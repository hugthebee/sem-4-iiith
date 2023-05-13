`timescale 1ns/10ps
`include "fetch_r.v"
`include "dwb_r.v"
`include "execute_r.v"
`include "memory_r.v"
`include "pc_update.v"

module pipe_tb;

reg clk;
reg [63:0]PC; //memory address is 64 bits
reg AOK,HALT,ADR,INS;
reg [2:0]status;
reg [63:0]nextPC;
wire [63:0]f_nextPC;

wire [3:0]f_icode; //first 4 bits of the first byte
wire [3:0]d_icode;
wire [3:0]e_icode;
wire [3:0]m_icode;
wire [3:0]w_icode;

wire [3:0]f_ifun; //last 4 bits of the first byte
wire [3:0]d_ifun; 
wire [3:0]e_ifun; 

wire [3:0]f_rA; //first 4 bits of the second byte
wire [3:0]d_rA;
wire [3:0]e_rA;
wire [3:0]m_rA;
wire [3:0]w_rA;

wire [3:0]f_rB; //last 4 bits of the second byte
wire [3:0]d_rB;
wire [3:0]e_rB;
wire [3:0]m_rB;
wire [3:0]w_rB;   

wire f_hlt;
wire d_hlt;
wire e_hlt;
wire m_hlt;
wire w_hlt;

wire f_in_mem;
wire d_in_mem;
wire e_in_mem;
wire m_in_mem;
wire w_in_mem;

wire f_in_inst;
wire d_in_inst;
wire e_in_inst;
wire m_in_inst;
wire w_in_inst;


wire signed [63:0]d_valA;
wire signed [63:0]e_valA;
wire signed [63:0]m_valA;

wire signed [63:0]d_valB;
wire signed [63:0]e_valB;

wire signed [63:0]f_valC; //stores the constant word
wire signed [63:0]d_valC;
wire signed [63:0]e_valC;
wire signed [63:0]m_valC;
wire signed [63:0]w_valC;

wire e_cond;
wire m_cond;
wire w_cond;

wire signed [63:0]e_valE;
wire signed [63:0]m_valE;
wire signed [63:0]w_valE;

wire signed [63:0]m_valM;
wire signed [63:0]w_valM;

wire signed [63:0]f_valP; //stores the address of next instruction (PC should be this value)
wire signed [63:0]d_valP;
wire signed [63:0]e_valP;
wire signed [63:0]m_valP;

wire signed [63:0]data;
wire ZF;
wire SF;
wire OF;

wire signed[63:0] r1;
wire signed[63:0] r2;
wire signed[63:0] r3;
wire signed[63:0] r4;
wire signed[63:0] r5;
wire signed[63:0] r6;
wire signed[63:0] r7;
wire signed[63:0] r8;
wire signed[63:0] r9;
wire signed[63:0] r10;
wire signed[63:0] r11;
wire signed[63:0] r12;
wire signed[63:0] r13;
wire signed[63:0] r14;
wire signed[63:0] r0;
wire [63:0] newPC;

fetch_reg AA (clk, f_valP, f_nextPC); //nextPC will take f_valP because f_valP will store the value of valP after
fetch A (clk, PC, f_icode, f_ifun, f_rA, f_rB, f_valC, f_valP, f_in_mem, f_in_inst, f_hlt);
decode_reg BB (clk, f_icode, f_ifun, f_rA,f_rB,f_valC,f_valP,f_hlt,f_in_inst,f_in_mem,d_icode,d_ifun,d_rA,d_rB,d_valC,d_valP,d_hlt,d_in_inst,d_in_mem);
//decode UUTB (clk, d_icode, d_rA, d_rB, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, d_valA, d_valB); 
writeback_reg CC(clk, m_icode,m_rA,m_rB,m_valE,m_valM,m_valC,m_cond,m_hlt,m_in_inst,m_in_mem,w_icode,w_rA,w_rB,w_valE,w_valM,w_valC,w_cond,w_hlt,w_in_inst,w_in_mem);
writeback C (clk, d_icode, d_rA, d_rB, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, d_valA, d_valB, w_valE, w_valM,w_icode,w_rA,w_rB,w_cond);
execute_reg DD(clk, e_icode, e_ifun, e_rA, e_rB, e_valA, e_valB, e_valC, e_valP, e_hlt, e_in_mem, e_in_inst, d_icode, d_ifun, d_rA, d_rB, d_valA, d_valB, d_valC, d_valP, d_hlt, d_in_mem, d_in_inst);
execute D (clk, e_icode, e_ifun, e_valA, e_valB, e_valC, e_cond, e_valE, ZF, SF, OF);
memory_reg EE(clk, m_icode, m_cond, m_rA, m_rB, m_valA, m_valE, m_valP, m_valC, m_hlt, m_in_mem, m_in_inst, e_icode, e_cond, e_rA, e_rB, e_valA, e_valE, e_valP, e_valC, e_hlt, e_in_mem, e_in_inst);
memory E (clk, m_icode, m_valA, m_valE, m_valP, m_valM, data);
//writeback UUTE (clk, icode, cond, rA, rB, valE, valM, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14);
pc_update F (clk, newPC, w_icode, f_nextPC, w_valM, w_valC, w_cond);

initial 
begin
    $dumpfile("pipe_tb.vcd");
    $dumpvars(0,pipe_tb);

    AOK = 1;
    HALT = 0;
    ADR = 0;
    INS = 0;
    status = 3'b001;
        
    clk = 0;
    PC = 64'd0;
end

initial
begin
    #10 clk = ~clk; //positive edge 
    #10 clk = ~clk; //negative edge so nothing happens
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk;
    #10 clk = ~clk; //0
    #10 clk = ~clk;
    #10 clk = ~clk; //0
end

always@(*)
begin
    PC = newPC;

    //setting the status codes
    if(w_hlt)
    begin
        AOK = 0;
        HALT= 1;
        INS = 0;
        ADR = 0;
        status = 3'b010;
    end
    else if(w_in_mem)
    begin
        AOK = 0;
        HALT= 0;
        INS = 0;
        ADR = 1;
        status = 3'b011;
    end
    else if(w_in_inst)
    begin
        AOK = 0;
        HALT= 0;
        INS = 1;
        ADR = 0;
        status = 3'b100;
    end
    else
    begin
        AOK = 1;
        HALT = 0;
        INS = 0;
        ADR = 0;
        status = 3'b001;
    end
end

//always @(*)
initial
    $monitor("clk=%d f=%d d=%d e=%d m=%d w=%d r3=%d\n",clk, f_icode, d_icode, e_icode, m_icode, w_icode,r3);
endmodule

`timescale 1ns/10ps
`include "fetch.v"
`include "execute.v"
`include "memory.v"
`include "writeback.v"
`include "pc_update.v"

module seq_tb;

reg clk;
reg [63:0]PC; //memory address is 64 bits
reg AOK,HALT,ADR,INS;
reg [2:0]status;

wire [3:0]icode; //first 4 bits of the first byte
wire [3:0]ifun; //last 4 bits of the first byte
wire [3:0]rA; //first 4 bits of the second byte
wire [3:0]rB; //last 4 bits of the second byte
wire signed [63:0]valC; //stores the constant word
wire [63:0]valP; //stores the address of next instruction (PC should be this value)
wire in_mem;
wire in_inst;
wire hlt;
wire signed [63:0]valA;
wire signed [63:0]valB;
wire cond;
wire signed [63:0]valE;
wire signed [63:0]valM;
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
wire [63:0]newPC;

fetch UUTA (clk,PC,icode,ifun,rA,rB,valC,valP,in_mem,in_inst,hlt);
execute UUTC (clk, icode, ifun, valA, valB, valC, cond, valE, ZF, SF, OF);
memory UUTD (clk, icode, valA, valB, valE, valP, valM, data);
writeback UUTE (clk, icode, cond, rA, rB,r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14,valA,valB,valE,valM);
pc_update UUTF (clk, newPC, icode, valP, valM, valC, cond);

initial 
begin
    $dumpfile("seq_tb.vcd");
    $dumpvars(0,seq_tb);

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
    #10 clk = ~clk;
    #10 clk = ~clk; //0
end

always@(*)
begin
    PC = newPC;

    //setting the status codes
    if(hlt)
    begin
        AOK = 0;
        HALT= 1;
        INS = 0;
        ADR = 0;
        status = 3'b010;
        $finish;
    end
    else if(in_mem)
    begin
        AOK = 0;
        HALT= 0;
        INS = 0;
        ADR = 1;
        status = 3'b011;
    end
    else if(in_inst)
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
    $monitor("clk=%d icode=%b ifun=%b rA=%b rB=%b PC=%d cond=%d valA=%d valB=%d \nvalC=%d valE=%d valM=%d data=%d valP=%d newPC=%d status=%d r0=%d r1 = %d r2=%d r3=%d r4=%d r5=%d r6=%d r7=%d r8=%d r9=%d r10=%d r11=%d r12=%d r13=%d r14=%d",clk, icode, ifun, rA, rB, PC, cond, valA, valB, valC, valE, valM, data, valP, newPC,status,r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14);
endmodule


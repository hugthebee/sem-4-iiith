`timescale 1ns/10ps
`include "fetch.v"
`include "decode.v"
`include "execute.v"

module memory_tb;

reg clk;
reg [63:0]PC; //memory address is 64 bits
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

fetch UUTA (clk,PC,icode,ifun,rA,rB,valC,valP,in_mem,in_inst,hlt);
decode UUTB (clk, icode, rA, rB, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, valA, valB); 
execute UUTC (clk, icode, ifun, valA, valB, valC, cond, valE, ZF, SF, OF);
memory UUTD (clk, icode, valA, valB, valE, valP, valM,data);

initial
    begin
        $dumpfile("memory_tb.vcd");
        $dumpvars(0,memory_tb);
        
        clk = 0;
        PC = 64'd0;

        #10 clk = ~clk; //positive edge 
            PC = 64'd0;
        #10 clk = ~clk; //negative edge so nothing happens
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
        #10 clk = ~clk;    
        #10 clk = ~clk;
            PC = valP;
    end

//always @(*)
initial
    $monitor("clk=%d icode=%b valA=%d valB=%d valE=%d valP=%d valM=%d  data=%d",clk, icode, valA, valB, valE, valP, valM,data);

endmodule


`timescale 1ns/10ps

module fetch_tb;

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

fetch UUT (clk,PC,icode,ifun,rA,rB,valC,valP,in_mem,in_inst,hlt);

initial
    begin
        $dumpfile("fetch_tb.vcd");
        $dumpvars(0,fetch_tb);
        
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

// always @(Z)
initial
    $monitor("clk=%d  PC = %d  icode=%b  ifun=%b  rA=%b  rB=%b  valC=%d  valP=%d  in_mem=%b  in_inst=%b  hlt=%b",clk,PC,icode,ifun,rA,rB,valC,valP,in_mem,in_inst,hlt);

endmodule
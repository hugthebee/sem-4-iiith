`timescale 1ns/10ps

module xorop_tb;

reg [63:0]A;
reg [63:0]B;
wire [63:0]Y;

xorop UUT (A,B,Y);

initial
    begin
        $dumpfile("xorop_tb.vcd");
        $dumpvars(0,xorop_tb);

        #10
        A = 64'd2;
        B = 64'd2;
    end

initial
    $monitor("a=%d b=%d result=%d",A,B,Y);

endmodule
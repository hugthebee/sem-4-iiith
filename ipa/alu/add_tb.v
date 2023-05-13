`timescale 1ns/10ps

module add_tb;

reg signed[63:0]A;
reg signed[63:0]B;
wire signed[63:0]Y;
wire signed c_out;

add UUT (A,B,Y,c_out);

initial
    begin
        $dumpfile("add_tb.vcd");
        $dumpvars(0,add_tb);

        #10
        A = 64'd3;
        B = -64'd2;
    end

initial
$monitor("a=%d b=%d result=%d",A,B,Y);

endmodule
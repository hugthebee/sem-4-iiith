`timescale 1ns/10ps

module sub_tb;

reg signed [63:0]A;
reg signed [63:0]B;
wire signed [63:0]Y;
wire signed c_out;

sub UUT (A,B,Y,c_out);

initial
    begin
        $dumpfile("sub_tb.vcd");
        $dumpvars(0,sub_tb);

        #10;
        A = 64'b0;
        B = 64'b1;

        #10;
        A = -64'd2;
        B = 64'd2;

        #10;
        A = 64'd3;
        B = 64'd0;

        #10;
        A = 64'b1010;
        B = -64'b10;

        #10;
    end

initial
    $monitor("a=%d b=%d result=%d",A,B,Y);

endmodule
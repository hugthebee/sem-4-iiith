`timescale 1ns/10ps

module andop_tb;

reg [63:0]A;
reg [63:0]B;
wire [63:0]Y;

andop UUT (A,B,Y);

initial
    begin
        $dumpfile("andop_tb.vcd");
        $dumpvars(0,andop_tb);

        #10
        A = 64'b0000000000000000000000000000000000000000001111111111111111111111;
        B = 64'b0000000000000000000000000000000000000000000000000000011111111111;
    end

always @(Y)
$display("a = %b , b = %b ,result = %b",A,B,Y);

endmodule
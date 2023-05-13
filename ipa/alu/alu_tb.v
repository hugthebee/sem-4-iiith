`timescale 1ns/10ps

module alu_tb;

reg signed[63:0]P;
reg signed[63:0]Q;
wire signed[63:0]Z;
wire signed carryout;
reg signed [2:0]select;

alu UUT (P, Q, Z, carryout, select);

initial
    begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0,alu_tb);
        
        #50; P=64'd5; Q=-64'd2; select=2'b11;
        #50; P=64'd3; Q=-64'd2; select=2'b10;
        #50; P=-64'd3; Q=64'd2; select=2'b10;
        #50; P=64'd3; Q=64'd2; select=2'b00;
        #50; P=64'd2; Q=64'd2; select=2'b01;
        #50; P=64'd3; Q=64'd2; select=2'b01;
    end

// always @(Z)
initial
    $monitor("a=%d b=%d select=%d result=%d",P,Q,select,Z);

endmodule
`timescale 1ns/10ps

module memory(clk,icode,valA,valB,valE,valP,valM,data);

//[63:0] after regA makes it an array but putting it before means its a net
input clk;
input [3:0]icode; //first 4 bits of the first byte
input [63:0]valP; //stores the address of next instruction (PC should be this value)
input signed [63:0]valA;
input signed [63:0]valB;
input signed [63:0]valE;

output reg [63:0]valM;
output reg [63:0]data;

//setting up data memory (similar structure to instruction memory)
reg [63:0] data_mem[0:1023]; //this means we have a 1024 rows and each data is 64 bits

initial
begin
//for testing memory_tb.v (giving values based only on what will be computed)
data_mem[7]=64'd24;
data_mem[24] = 64'd17;
data_mem[32] = 64'd88;
data_mem[47] = 64'd55;
end

always @(*)
begin
    case(icode)
    4'b0100:
    //rmmov
    begin
        data_mem[valE] = valA;
    end

    4'b0101:
    //mrmov
    begin
        valM = data_mem[valE];
    end

    4'b1000:
    //call
    begin
        data_mem[valE] = valP;
    end

    4'b1001:
    //ret
    begin
        valM = data_mem[valA];
    end

    4'b1010:
    //push
    begin
        data_mem[valE] = valA;
    end

    4'b1011:
    //pop
    begin
        valM = data_mem[valA];
    end
    endcase
    data = data_mem[valE];
end
endmodule
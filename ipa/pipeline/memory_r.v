`timescale 1ns/10ps

module memory(clk,icode,valA,valE,valP,valM,data);

//[63:0] after regA makes it an array but putting it before means its a net
input clk;
input [3:0]icode; //first 4 bits of the first byte
input [63:0]valP; //stores the address of next instruction (PC should be this value)
input signed [63:0]valA;
//input signed [63:0]valB;
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

module memory_reg(clk, m_icode, m_cond, m_rA, m_rB, m_valA, m_valE, m_valP, m_valC, m_hlt, m_in_mem, m_in_inst, e_icode, e_cond, e_rA, e_rB, e_valA, e_valE, e_valP, e_valC, e_hlt, e_in_mem, e_in_inst);
input clk;
input [3:0]e_icode;
input e_cond;
input [3:0]e_rA;
input [3:0]e_rB;
input signed [63:0]e_valA;
input signed [63:0]e_valE;
input signed [63:0]e_valP;
input signed [63:0]e_valC;
input e_hlt;
input e_in_mem;
input e_in_inst;

output reg [3:0]m_icode;
output reg m_cond;
output reg [3:0]m_rA;
output reg [3:0]m_rB;
output reg signed [63:0]m_valA;
output reg signed [63:0]m_valE;
output reg signed [63:0]m_valP;
output reg signed [63:0]m_valC;
output reg m_hlt;
output reg m_in_mem;
output reg m_in_inst;

always @(posedge clk)
begin
    m_icode <= e_icode;
    m_cond <= e_cond;
    m_rA <= e_rA;
    m_rB <= e_rB;
    m_valA <= e_valA;
    m_valE <= e_valE;
    m_valP <= e_valP;
    m_valC <= e_valC;
    m_hlt <= e_hlt;
    m_in_mem <= e_in_mem;
    m_in_inst <= e_in_inst;
end

endmodule
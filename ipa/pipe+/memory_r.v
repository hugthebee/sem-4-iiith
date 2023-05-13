`timescale 1ns/10ps

module memory(clk,M_icode,M_valA,M_valE,M_dstE,M_dstM,M_hlt,M_in_inst,M_in_mem,M_cond,W_stall,W_icode,W_valE,W_valM,W_dstE,W_dstM,m_valM,m_in_inst,m_in_mem,W_in_inst,W_in_mem,W_hlt,data);

//[63:0] after regA makes it an array but putting it before means its a net
input clk;
input [3:0] M_icode,M_dstE,M_dstM; //first 4 bits of the first byte
input signed [63:0] M_valA,M_valE; //stores the address of next instruction (PC should be this value)
//input signed [63:0]valB;
input M_cond,M_hlt,M_in_inst,M_in_mem,W_stall;

output reg signed [63:0] W_valE,W_valM,m_valM;
output reg [3:0] W_icode,W_dstE,W_dstM;
output W_hlt,W_in_inst,W_in_mem,m_hlt,m_in_inst,m_in_mem;

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
    case(M_icode)
    4'b0100:
    //rmmov
    begin
        data_mem[M_valE] = M_valA;
    end

    4'b0101:
    //mrmov
    begin
        W_valM = data_mem[M_valE];
    end

    4'b1000:
    //call
    begin
        data_mem[M_valE] = M_valA;
    end

    4'b1001:
    //ret
    begin
        W_valM = data_mem[M_valA];
    end

    4'b1010:
    //push
    begin
        data_mem[M_valE] = M_valA;
    end

    4'b1011:
    //pop
    begin
        W_valM = data_mem[M_valA];
    end
    endcase
    data = data_mem[M_valE];
end

//writrback register -> between the memory and writeback stage
always@(posedge clk)
    begin
        if(W_stall)
        begin
        end
        else
        begin
            W_hlt <= m_hlt;
            W_in_inst <= m_in_inst;
            W_in_mem <= m_in_mem;
            W_icode <= M_icode;
            W_valE <= M_valE;
            W_valM <= m_valM;
            W_dstE <= M_dstE;
            W_dstM <= M_dstM;
        end
    end
endmodule
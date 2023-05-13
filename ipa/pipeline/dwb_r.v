`timescale 1ns/10ps

//since we have both decode and writeback stages here, it is important that we seperate both the signals as d_rA and w_rA
module writeback(clk, d_icode, d_rA, d_rB, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, d_valA, d_valB, w_valE, w_valM,w_icode,w_rA,w_rB,w_cond);

//IMP -> you can't input a 2D array like reg_file to a module and so we input each register value on its own

input clk;
input [3:0] d_icode;
//input d_cond;
//input ifun[3:0];
input [3:0] d_rA;
input [3:0] d_rB;
output reg signed [63:0] d_valA;
output reg signed [63:0] d_valB;

input [3:0] w_icode;
input w_cond;
//input ifun[3:0];
input [3:0] w_rA;
input [3:0] w_rB;
input signed [63:0] w_valE;
input signed [63:0] w_valM;

output reg signed [63:0] r1;
output reg signed [63:0] r2;
output reg signed [63:0] r3;
output reg signed [63:0] r4;
output reg signed [63:0] r5;
output reg signed [63:0] r6;
output reg signed [63:0] r7;
output reg signed [63:0] r8;
output reg signed [63:0] r9;
output reg signed [63:0] r10;
output reg signed [63:0] r11;
output reg signed [63:0] r12;
output reg signed [63:0] r13;
output reg signed [63:0] r14;
output reg signed [63:0] r0;

reg signed [63:0]reg_file [0:14]; //15 reigsters of size 64 bits

//for the purpose of testing testbench
initial 
begin
reg_file[0] = 64'd5;
reg_file[1] = 64'd45;
reg_file[2] = -64'd90;
reg_file[3] = 64'd54;
reg_file[4] = 64'd32;  //stack pointer register
reg_file[5] = 64'd21;
reg_file[6] = 64'd56;
reg_file[7] = 64'd33;
reg_file[8] = -64'd77;
reg_file[9] = 64'd0;
reg_file[10] = 64'd34;
reg_file[11] = 64'd7;
reg_file[12] = 64'd5;
reg_file[13] = -64'd9;
reg_file[14] = 64'd16;
end

//decode
always @(*) //we need to do this at * and not just at posedge of clk because we need to make sure that the value of rA is first fetched and then only can we use it
begin
  case(d_icode)
    //halt - 4'b0000
    //nop - 4'b0001
    //cmovxx 
    4'b0010:
    begin
        d_valA = reg_file[d_rA];
    end

    //irmovq - 4'b0011
    //rmmovq
    4'b0100:
    begin
        d_valA = reg_file[d_rA];
        d_valB = reg_file[d_rB];
    end

    //mrmovq
    4'b0101:
    begin
        d_valB = reg_file[d_rB];
    end

    //opq
    4'b0110:
    begin
        d_valA = reg_file[d_rA];
        d_valB = reg_file[d_rB];
    end

    //jxx - 4'b0111
    //call
    4'b1000:
    begin
        d_valB = reg_file[4]; //register 4 is the stack pointer register (rsp)
    end

    //ret
    4'b1001:
    begin
        d_valA = reg_file[4];
        d_valB = reg_file[4];
    end

    //pushq
    4'b1010:
    begin
        d_valA = reg_file[d_rA];
        d_valB = reg_file[4];
    end

    //popq
    4'b1011:
    begin
        d_valA = reg_file[4];
        d_valB = reg_file[4];
    end
    endcase

    r0 = reg_file[0];
    r1 = reg_file[1];
    r2 = reg_file[2];
    r3 = reg_file[3];
    r4 = reg_file[4]; //stack pointer register
    r5 = reg_file[5];
    r6 = reg_file[6];
    r7 = reg_file[7];
    r8 = reg_file[8];
    r9 = reg_file[9];
    r10 = reg_file[10];
    r11 = reg_file[11];
    r12 = reg_file[12];
    r13 = reg_file[13];
    r14 = reg_file[14];
end

//writeback
always@(*)
begin

case(w_icode)
    //cmovxx
    4'b0010:
    begin
        if(w_cond)
        begin
            reg_file[w_rB] = w_valE;
        end
    end

    //irmov
    4'b0011:
    begin
        reg_file[w_rB] = w_valE;
    end

    //mrmov
    4'b0101:
    begin
        reg_file[w_rA] = w_valM;
    end

    //opq
    4'b0110:
    begin
        reg_file[w_rB] = w_valE;
    end

    //call
    4'b1000:
    begin
        reg_file[4] = w_valE;
    end

    //ret
    4'b1001:
    begin
        reg_file[4] = w_valE;
    end

    //push
    4'b1010:
    begin
        reg_file[4] = w_valE;
    end

    //pop
    4'b1011:
    begin
        reg_file[4] = w_valE;
        reg_file[w_rA] = w_valM;
    end
endcase
r0 = reg_file[0];
r1 = reg_file[1];
r2 = reg_file[2];
r3 = reg_file[3];
r4 = reg_file[4]; //stack pointer register
r5 = reg_file[5];
r6 = reg_file[6];
r7 = reg_file[7];
r8 = reg_file[8];
r9 = reg_file[9];
r10 = reg_file[10];
r11 = reg_file[11];
r12 = reg_file[12];
r13 = reg_file[13];
r14 = reg_file[14];
end

endmodule

//decode reigster -> present between the fetch and decode stage
module decode_reg(clk,f_icode,f_ifun,f_rA,f_rB,f_valC,f_valP,f_hlt,f_in_inst,f_in_mem,d_icode,d_ifun,d_rA,d_rB,d_valC,d_valP,d_hlt,d_in_inst,d_in_mem);
    input clk;
    input [3:0] f_icode;
    input [3:0] f_ifun;
    input [3:0] f_rA;
    input [3:0] f_rB;
    input signed [63:0] f_valC;
    input signed [63:0] f_valP;
    input f_hlt;
    input f_in_inst; 
    input f_in_mem;

    output reg [3:0] d_icode;
    output reg [3:0] d_ifun;
    output reg [3:0] d_rA;
    output reg [3:0] d_rB;
    output reg signed [63:0] d_valC;
    output reg signed [63:0] d_valP;
    output reg d_hlt;
    output reg d_in_inst; 
    output reg d_in_mem;

    always @(posedge clk)
    begin
        d_icode <= f_icode;
        d_ifun <= f_ifun;
        d_rA <= f_rA;
        d_rB <= f_rB;
        d_valC <= f_valC;
        d_valP <= f_valP;
        d_hlt <= f_hlt;
        d_in_inst <= f_in_inst;
        d_in_mem <= f_in_mem;
    end
endmodule

//writeback reigster -> present between the memory and writeback stage
module writeback_reg(clk,m_icode,m_rA,m_rB,m_valE,m_valM,m_valC,m_cond,m_hlt,m_in_inst,m_in_mem,w_icode,w_rA,w_rB,w_valE,w_valM,w_valC,w_cond,w_hlt,w_in_inst,w_in_mem);
    input clk;
    input [3:0]m_icode;
    input [3:0]m_rA;
    input [3:0]m_rB;
    input signed [63:0]m_valE;
    input signed [63:0]m_valM;
    input signed [63:0]m_valC;
    input m_hlt;
    input m_in_inst; 
    input m_in_mem;
    input m_cond;

    output reg [3:0] w_icode;
    output reg [3:0]w_rA;
    output reg [3:0]w_rB;
    output reg signed [63:0] w_valE;
    output reg signed [63:0] w_valM;
    output reg signed [63:0] w_valC;
    output reg w_hlt;
    output reg w_in_inst; 
    output reg w_in_mem;
    output reg w_cond;

    always @(posedge clk)
    begin
        w_icode <= m_icode;
        w_rA <= m_rA;
        w_rB <= m_rB;
        w_valM <= m_valM;
        w_valE <= m_valE;
        w_valC <= m_valC;
        w_hlt <= m_hlt;
        w_in_inst <= m_in_inst;
        w_in_mem <= m_in_mem;
        w_cond <= m_cond;
    end
endmodule
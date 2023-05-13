`timescale 1ns/10ps

module writeback(clk, icode, cond, rA, rB, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, valA, valB, valE, valM);

//IMP -> you can't input a 2D array like reg_file to a module and so we input each register value on its own

input clk;
input [3:0]icode;
input cond;
//input ifun[3:0];
input [3:0]rA;
input [3:0]rB;
input signed [63:0]valE;
input signed [63:0]valM;

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

output reg signed [63:0]valA;
output reg signed [63:0]valB;

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
  case(icode)
    //halt - 4'b0000
    //nop - 4'b0001
    //cmovxx 
    4'b0010:
    begin
        valA = reg_file[rA];
    end

    //irmovq - 4'b0011
    //rmmovq
    4'b0100:
    begin
        valA = reg_file[rA];
        valB = reg_file[rB];
    end

    //mrmovq
    4'b0101:
    begin
        valB = reg_file[rB];
    end

    //opq
    4'b0110:
    begin
        valA = reg_file[rA];
        valB = reg_file[rB];
    end

    //jxx - 4'b0111
    //call
    4'b1000:
    begin
        valB = reg_file[4]; //register 4 is the stack pointer register (rsp)
    end

    //ret
    4'b1001:
    begin
        valA = reg_file[4];
        valB = reg_file[4];
    end

    //pushq
    4'b1010:
    begin
        valA = reg_file[rA];
        valB = reg_file[4];
    end

    //popq
    4'b1011:
    begin
        valA = reg_file[4];
        valB = reg_file[4];
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
always@(negedge clk)
begin

case(icode)
    //cmovxx
    4'b0010:
    begin
        if(cond)
        begin
            reg_file[rB] = valE;
        end
    end

    //irmov
    4'b0011:
    begin
        reg_file[rB] = valE;
    end

    //mrmov
    4'b0101:
    begin
        reg_file[rA] = valM;
    end

    //opq
    4'b0110:
    begin
        reg_file[rB] = valE;
    end

    //call
    4'b1000:
    begin
        reg_file[4] = valE;
    end

    //ret
    4'b1001:
    begin
        reg_file[4] = valE;
    end

    //push
    4'b1010:
    begin
        reg_file[4] = valE;
    end

    //pop
    4'b1011:
    begin
        reg_file[4] = valE;
        reg_file[rA] = valM;
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
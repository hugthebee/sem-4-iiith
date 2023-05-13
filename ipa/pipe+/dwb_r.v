`timescale 1ns/10ps

//since we have both decode and writeback stages here, it is important that we seperate both the signals as d_rA and w_rA
//has the execute register here
//dstE, dstM -> register ID's (like rA and rB)

module writeback(clk,r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, D_icode, D_ifun, D_rA, D_rB, D_valC, D_valP, D_in_inst, D_hlt, D_in_mem, W_icode, e_dstE, M_dstE, M_dstM, W_dstE, W_dstM,e_valE, M_valE, m_valM,W_valE,W_valM,E_bubble,E_in_inst,E_hlt,E_in_mem,E_icode,E_ifun,E_valC,E_valA,E_valB,E_dstE,E_dstM,E_srcA,E_srcB,d_srcA,d_srcB);
//IMP -> you can't input a 2D array like reg_file to a module and so we input each register value on its own

input clk;
input [3:0] D_icode,D_ifun,D_rA,D_rB,W_icode,e_dstE,M_dstE;
//input d_cond;
//input ifun[3:0];
input D_in_inst, D_in_mem, D_hlt;
input signed [63:0] D_valC,D_valP,e_valE,M_valE,m_valM,W_valE,W_valM;
input E_bubble;

output reg E_hlt,E_in_inst,E_in_mem;
output reg [3:0] E_icode,E_ifun,E_dstE,E_dstM,E_srcA,E_srcB,d_srcA,d_srcB;
output reg signed [63:0] E_valC, E_valA, E_valB;

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

reg [3:0] d_dstE, d_dstM;
reg [63:0] valA,valB;
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
    //initialising decode outputs to invalid register
    d_srcA = 4'b1111;
    d_srcB = 4'b1111;
    d_dstM = 4'b1111;
    d_dstE = 4'b1111;

  case(D_icode)
    //halt - 4'b0000
    //nop - 4'b0001
    //cmovxx 
    4'b0010:
    begin
        d_srcA = D_rA;
        d_dstE = D_rB;
        valA = reg_file[D_rA];
        valB = 64'd0;
    end

    //irmovq - 4'b0011
    4'b0011:
    begin
        d_dstE = D_rB;
        valB = 64'd0;
    end

    //rmmovq
    4'b0100:
    begin
        d_srcA = D_rA;
        d_dstE = D_rB;
        valA = reg_file[D_rA];
        valB = reg_file[D_rB];
    end

    //mrmovq
    4'b0101:
    begin
        d_srcB = D_rB;
        d_dstM = D_rA;
        valB = reg_file[D_rB];
    end

    //opq
    4'b0110:
    begin
        d_srcB = D_rB;
        d_srcA = D_rA;
        d_dstE = D_rB;
        valA = reg_file[D_rA];
        valB = reg_file[D_rB];
    end

    //jxx - 4'b0111
    //call
    4'b1000:
    begin
        d_srcB = 4'b0010;
        d_dstE = 4'b0010;
        valB = reg_file[4]; //register 4 is the stack pointer register (rsp)
    end

    //ret
    4'b1001:
    begin
        d_srcA = 4'b0010;
        d_srcB = 4'b0010;
        d_dstE = 4'b0010;
        valA = reg_file[4];
        valB = reg_file[4];
    end

    //pushq
    4'b1010:
    begin
        d_srcA = D_rA;
        d_srcB = 4'b0010;
        d_dstE = 4'b0010;
        valA = reg_file[D_rA];
        valB = reg_file[4];
    end

    //popq
    4'b1011:
    begin
        d_srcA = 4'b0010;
        d_srcB = 4'b0010;
        d_dstE = 4'b0010;
        d_dstM = D_rA;
        valA = reg_file[4];
        valB = reg_file[4];
    end
    endcase

    // Forwarding control for A register
    if(D_icode == 4'b0111 | D_icode == 4'b1000) //jxx or call
      d_valA = D_valP;
    else if(d_srcA == e_dstE & e_dstE!= 4'b1111) //bitwise AND
      d_valA = e_valE;
    else if(d_srcA == M_dstM & M_dstM!= 4'b1111)
      d_valA = m_valM;
    else if(d_srcA == W_dstM & W_dstM!= 4'b1111)
      d_valA = W_valM;
    else if(d_srcA == M_dstE & M_dstE!= 4'b1111)
      d_valA = M_valE;
    else if(d_srcA == W_dstE & W_dstE!= 4'b1111)
      d_valA = W_valE;
    else
      d_valA = d_rvalA;


    //Forwarding control for B register
    if(d_srcB == e_dstE & e_dstE!= 4'b1111)      // Forwarding from execute
      d_valB = e_valE;
    else if(d_srcB == M_dstM & M_dstM!= 4'b1111) // Forwarding from memory
      d_valB = m_valM;
    else if(d_srcB == W_dstM & W_dstM!= 4'b1111) // Forwarding memory value from write back stage
      d_valB = W_valM;
    else if(d_srcB == M_dstE & M_dstE!= 4'b1111) // Forwarding execute value from memory stage
      d_valB = M_valE;
    else if(d_srcB == W_dstE & W_dstE!= 4'b1111) // Forwarding execute value from write back stage 
      d_valB = W_valE;
    else
      d_valB = d_rvalB;


    r0 <= reg_file[0];
    r1 <= reg_file[1];
    r2 <= reg_file[2];
    r3 <= reg_file[3];
    r4 <= reg_file[4]; //stack pointer register
    r5 <= reg_file[5];
    r6 <= reg_file[6];
    r7 <= reg_file[7];
    r8 <= reg_file[8];
    r9 <= reg_file[9];
    r10 <= reg_file[10];
    r11 <= reg_file[11];
    r12 <= reg_file[12];
    r13 <= reg_file[13];
    r14 <= reg_file[14];
end

//writeback
always@(*)
begin

case(W_icode)
    //cmovxx
    4'b0010:
    begin
        reg_file[W_dstE] = W_valE;
    end

    //irmov
    4'b0011:
    begin
        reg_file[W_dstE] = W_valE;
    end

    //mrmov
    4'b0101:
    begin
        reg_file[W_dstE] = W_valM;
    end

    //opq
    4'b0110:
    begin
        reg_file[W_dstE] = W_valE;
    end

    //call
    4'b1000:
    begin
        reg_file[W_dstE] = W_valE;
    end

    //ret
    4'b1001:
    begin
        reg_file[W_dstE] = W_valE;
    end

    //push
    4'b1010:
    begin
        reg_file[W_dstE] = W_valE;
    end

    //pop
    4'b1011:
    begin
        reg_file[W_dstE] = W_valE;
        reg_file[W_dstM] = W_valM;
    end
endcase
r0 <= reg_file[0];
r1 <= reg_file[1];
r2 <= reg_file[2];
r3 <= reg_file[3];
r4 <= reg_file[4]; //stack pointer register
r5 <= reg_file[5];
r6 <= reg_file[6];
r7 <= reg_file[7];
r8 <= reg_file[8];
r9 <= reg_file[9];
r10 <= reg_file[10];
r11 <= reg_file[11];
r12 <= reg_file[12];
r13 <= reg_file[13];
r14 <= reg_file[14];
end

//execute register -> between decode and execute stage
always@(posedge clk)
begin 
    if(E_bubble)
    begin
        //nop instruction
        E_hlt <= 1'b0;
        E_in_inst <= 1'b0;
        E_in_mem <= 1'b0;
        E_icode <= 4'b0001;
        E_ifun <= 4'b0000;
        E_valC <= 4'b0000;
        E_valA <= 4'b0000;
        E_valB <= 4'b0000;
        E_dstE <= 4'b1111;
        E_dstM <= 4'b1111;
        E_srcA <= 4'b1111;
        E_srcB <= 4'b1111;
    end
    else
    begin
        // Execute register update
        E_hlt <= D_hlt;
        E_in_inst <= D_in_inst;
        E_in_mem <= D_in_mem;
        E_icode <= D_icode;
        E_ifun <= D_ifun;
        E_valC <= D_valC;
        E_valA <= d_valA;
        E_valB <= d_valB;
        E_srcA <= d_srcA;
        E_srcB <= d_srcB;
        E_dstE <= d_dstE;
        E_dstM <= d_dstM;
    end

  end

endmodule

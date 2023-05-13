`timescale 1ns/10ps

`include "../alu/alu.v"

module execute(clk, E_icode, E_ifun, E_valA, E_valB, E_valC, E_hlt, E_in_inst, E_in_mem, E_dstE,E_dstM,m_hlt,m_in_inst,m_in_mem,W_hlt,W_in_inst,W_in_mem,M_bubble,M_icode,M_cond,M_valE,M_valA,e_valE,M_dstE,M_dstM,e_dstE,e_cond);

input clk;
input [3:0] E_icode,E_ifun,E_dstE,E_dstM;
input signed [63:0]E_valA,E_valB,E_valC;
input E_hlt,E_in_inst,E_in_mem,m_hlt,m_in_mem,m_in_inst,W_hlt,W_in_inst,W_in_mem,M_bubble;

output reg ZF;      //condition codes
output reg SF;
output reg OF;
output reg cond;    //based on ifun and CCs
//output reg [63:0]alu_out;

output reg [3:0] M_icode,M_dstE,M_dstM,e_dstE;
output reg signed [63:0] M_valE, M_valA, e_valE;
output reg M_cond,e_cond,M_hlt,M_in_inst,M_in_mem;

//alu 
reg signed [63:0]P;
reg  signed [63:0]Q;
reg [2:0]select;
wire signed carryout;
wire signed [63:0]Z;
reg signed [63:0]vale;

initial
begin
    //initialising alu variables
    select = 2'b00;
    P = 64'b0;
    Q = 64'b0;
end

//this only happens when the instruction is op ie the condition codes are only set when op is called
always @(*)
begin
    if(E_icode == 4'b0110)
    ZF = 0;
    OF = 0;
    SF = 0;
    begin
        if (Z == 1'b0) begin
            ZF = 1;
        end
        if (Z[63] == 1'b1) begin 
            SF = 1;
        end
        if (((P < 64'b0) == (Q < 64'b0)) && ((Z<64'b0) != (P<64'b0))) begin
            OF = 1;
        end
    end
end

alu alu_alu(P, Q, Z, carryout, select);

always @(*)
begin
    e_cond = 0;
    case(E_icode)
        //halt - 4'b0000
        //nop - 4'b0001

        //cmovxx
        4'b0010:
        begin
            e_valE = E_valA;
            case(E_ifun)
                //rrmovq
                4'b0000:  
                begin
                    e_cond = 1;
                end
                //cmovle
                4'b0001:
                begin
                    if ((SF ^ OF) || (ZF)) begin
                        e_cond = 1;
                    end
                end
                //cmovl
                4'b0010:
                begin
                    if (SF ^ OF) begin 
                       e_cond = 1;
                    end
                end
                //cmove
                4'b0011:
                begin
                    if (ZF) begin
                        e_cond = 1;
                    end
                end
                //cmovne
                4'b0100:
                begin
                    if (~ZF) begin
                        e_cond = 1;
                    end
                end
                //cmovge
                4'b0101:
                begin 
                    if (~(SF ^ OF)) begin
                        e_cond = 1;
                    end
                end
                //cmovg
                4'b0110:
                begin
                    if ((~(SF ^ OF)) && (~ZF)) begin
                        e_cond = 1;
                    end
                end
            endcase
        end
        //irmovq    
        4'b0011:
        begin
            e_valE = E_valC;
        end
        //rmmovq
        4'b0100:
        begin
            e_valE = E_valB + E_valC;
        end
        //mrmovq
        4'b0101:
        begin
            e_valE = E_valB + E_valC;
        end
        //opq
        4'b0110:
        begin
            case(E_ifun)
                //addq
                4'b0000:
                begin
                    select = 2'b10;
                    P = E_valA;
                    Q = E_valB;
                end
                //subq
                4'b0001:
                begin
                    select = 2'b11;
                    P = E_valA;
                    Q = E_valB;
                end
                //andq
                4'b0010:
                begin
                    select = 2'b00;
                    P = E_valA;
                    Q = E_valB;
                end
                //xorq
                4'b0011:
                begin
                    select = 2'b01;
                    P = E_valA;
                    Q = E_valB;
                end
            endcase
        assign vale = Z; //cause Z is a wire
        e_valE = vale;
        end
        //jxx
        4'b0111:
        begin
            case(E_ifun)
                //jmp
                4'b0000:
                begin
                    e_cond = 1;
                end
                //jle
                4'b0001:
                begin
                    if ((SF ^ OF) || (ZF)) begin
                        e_cond = 1;
                    end
                end
                //jl
                4'b0010:
                begin
                    if (SF ^ OF) begin
                        e_cond = 1;
                    end
                end
                //je
                4'b0011:
                begin
                    if (ZF) begin
                        e_cond = 1;
                    end
                end
                //jne 
                4'b0100:
                begin 
                    if (~ZF) begin  
                        e_cond = 1;
                    end
                end
                //jge
                4'b0101:
                begin   
                    if(~(SF ^ OF)) begin
                        e_cond = 1;
                    end
                end
                //jg
                4'b0110:
                begin
                    if ((~(SF ^ OF)) && (~ZF)) begin
                        e_cond = 1;
                    end
                end
            endcase
        end
        //call 
        4'b1000:
        begin
            e_valE = E_valB + (-64'd8);
        end
        //ret
        4'b1001:
        begin
            e_valE = E_valB + 64'd8;
        end
        //pushq 
        4'b1010:
        begin
            e_valE = E_valB + (-64'd8);
        end
        //popq
        4'b1011:
        begin
            e_valE = E_valB + 64'd8;
        end
    endcase
end

// memory register -> between execute and memory register
always@(posedge clk)
  begin
    if(M_bubble)
    begin
        //nop instruction
        M_hlt <= 1'b0;
        M_in_inst <= 1'b0;
        M_in_mem <= 1'b0;
        M_icode <= 4'b0001;
        M_cond <= 1;
        M_valE <= 64'd0;
        M_valA <= 64'd0;
        M_dstE <= 4'b1111;
        M_dstM <= 4'b1111;
    end
    else
    begin
        M_hlt <= E_hlt;
        M_in_inst <= E_in_inst;
        M_in_mem <= E_in_mem;
        M_icode <= E_icode;
        M_cnd <= e_cnd;
        M_valE <= e_valE;
        M_valA <= E_valA;
        M_dstE <= e_dstE;
        M_dstM <= E_dstM;
    end
  end
endmodule


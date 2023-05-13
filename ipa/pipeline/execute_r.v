`timescale 1ns/10ps

`include "../alu/alu.v"

module execute(clk, icode, ifun, valA, valB, valC, cond, valE, ZF, SF, OF);

input clk;
input [3:0]icode;
input [3:0]ifun;
input signed [63:0]valA;
input signed [63:0]valB;
input signed [63:0]valC;
output reg ZF;      //condition codes
output reg SF;
output reg OF;
output reg cond;    //based on ifun and CCs
output reg signed [63:0]valE;
//output reg [63:0]alu_out;

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
    if(icode == 4'b0110)
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
    cond = 0;
    case(icode)
        //halt - 4'b0000
        //nop - 4'b0001

        //cmovxx
        4'b0010:
        begin
            valE = valA;
            case(ifun)
                //rrmovq
                4'b0000:  
                begin
                    cond = 1;
                end
                //cmovle
                4'b0001:
                begin
                    if ((SF ^ OF) || (ZF)) begin
                        cond = 1;
                    end
                end
                //cmovl
                4'b0010:
                begin
                    if (SF ^ OF) begin 
                       cond = 1;
                    end
                end
                //cmove
                4'b0011:
                begin
                    if (ZF) begin
                        cond = 1;
                    end
                end
                //cmovne
                4'b0100:
                begin
                    if (~ZF) begin
                        cond = 1;
                    end
                end
                //cmovge
                4'b0101:
                begin 
                    if (~(SF ^ OF)) begin
                        cond = 1;
                    end
                end
                //cmovg
                4'b0110:
                begin
                    if ((~(SF ^ OF)) && (~ZF)) begin
                        cond = 1;
                    end
                end
            endcase
        end
        //irmovq    
        4'b0011:
        begin
            valE = valC;
        end
        //rmmovq
        4'b0100:
        begin
            valE = valB + valC;
        end
        //mrmovq
        4'b0101:
        begin
            valE = valB + valC;
        end
        //opq
        4'b0110:
        begin
            case(ifun)
                //addq
                4'b0000:
                begin
                    select = 2'b10;
                    P = valA;
                    Q = valB;
                end
                //subq
                4'b0001:
                begin
                    select = 2'b11;
                    P = valA;
                    Q = valB;
                end
                //andq
                4'b0010:
                begin
                    select = 2'b00;
                    P = valA;
                    Q = valB;
                end
                //xorq
                4'b0011:
                begin
                    select = 2'b01;
                    P = valA;
                    Q = valB;
                end
            endcase
        assign vale = Z; //cause Z is a wire
        valE = vale;
        end
        //jxx
        4'b0111:
        begin
            case(ifun)
                //jmp
                4'b0000:
                begin
                    cond = 1;
                end
                //jle
                4'b0001:
                begin
                    if ((SF ^ OF) || (ZF)) begin
                        cond = 1;
                    end
                end
                //jl
                4'b0010:
                begin
                    if (SF ^ OF) begin
                        cond = 1;
                    end
                end
                //je
                4'b0011:
                begin
                    if (ZF) begin
                        cond = 1;
                    end
                end
                //jne 
                4'b0100:
                begin 
                    if (~ZF) begin  
                        cond = 1;
                    end
                end
                //jge
                4'b0101:
                begin   
                    if(~(SF ^ OF)) begin
                        cond = 1;
                    end
                end
                //jg
                4'b0110:
                begin
                    if ((~(SF ^ OF)) && (~ZF)) begin
                        cond = 1;
                    end
                end
            endcase
        end
        //call 
        4'b1000:
        begin
            valE = valB + (-64'd8);
        end
        //ret
        4'b1001:
        begin
            valE = valB + 64'd8;
        end
        //pushq 
        4'b1010:
        begin
            valE = valB + (-64'd8);
        end
        //popq
        4'b1011:
        begin
            valE = valB + 64'd8;
        end
    endcase
end
endmodule

module execute_reg(clk, e_icode, e_ifun, e_rA, e_rB, e_valA, e_valB, e_valC, e_valP, e_hlt, e_in_mem, e_in_inst, d_icode, d_ifun, d_rA, d_rB, d_valA, d_valB, d_valC, d_valP, d_hlt, d_in_mem, d_in_inst);

input clk;

input [3:0]d_icode;
input [3:0]d_ifun;
input [3:0]d_rA;
input [3:0]d_rB;
input signed [63:0]d_valA;
input signed [63:0]d_valB;
input signed [63:0]d_valC;
input signed [63:0]d_valP;
input d_hlt;
input d_in_mem;
input d_in_inst;

output reg [3:0]e_icode;
output reg [3:0]e_ifun;
output reg[3:0]e_rA;
output reg[3:0]e_rB;
output reg signed [63:0]e_valA;
output reg signed [63:0]e_valB;
output reg signed [63:0]e_valC;
output reg signed [63:0]e_valP;
output reg e_hlt;
output reg e_in_mem;
output reg e_in_inst;

always @(posedge clk) 
begin
    e_icode <= d_icode;
    e_ifun <= d_ifun;
    e_rA <= d_rA;
    e_rB <= d_rB;
    e_valA <= d_valA;
    e_valB <= d_valB;
    e_valC <= d_valC;
    e_valP <= d_valP;
    e_hlt <= d_hlt;
    e_in_mem <= d_in_mem;
    e_in_inst <= d_in_inst;
end

endmodule
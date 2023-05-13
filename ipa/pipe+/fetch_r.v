`timescale 1ns/10ps

//decode register is also implemented here
//F_nextPC -> the current PC value (in the fetch register)
//f_nextPC -> the next PC value to be considered 
module fetch(clk,F_nextPC,M_icode,W_icode,M_valA,W_valM,M_cond,F_stall,D_stall,D_bubble,f_nextPC,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,D_in_mem,D_in_inst,D_hlt);

//[63:0] after regA makes it an array but putting it before means its a net
input clk;
input [63:0] F_nextPC; //memory address is 64 bits
input F_stall,D_stall,D_bubble;
input signed [63:0] M_valA,W_valM;
input signed [3:0] M_icode,W_icode;
input M_cond;

output reg [3:0]D_icode; //first 4 bits of the first byte
output reg [3:0]D_ifun; //last 4 bits of the first byte
output reg [3:0]D_rA; //first 4 bits of the second byte
output reg [3:0]D_rB; //last 4 bits of the second byte
output reg signed [63:0]D_valC; //stores the constant word
output reg [63:0]D_valP; //stores the address of next instruction (PC should be this value)
output reg D_in_mem; //invalid memory
output reg D_in_inst; //invalid instruction
output reg D_hlt; //inavlid halt

reg [63:0]PC;
reg [3:0]icode; //first 4 bits of the first byte
reg [3:0]ifun; //last 4 bits of the first byte
reg [3:0]rA; //first 4 bits of the second byte
reg [3:0]rB; //last 4 bits of the second byte
reg signed [63:0]valC; //stores the constant word
reg [63:0]valP; //stores the address of next instruction (PC should be this value)
reg in_mem; //invalid memory
reg in_inst; //invalid instruction
reg hlt; //inavlid halt

//setting up instruction memory
reg [7:0] instr_mem[0:1023]; //this means we have a 100 rows of 1 byte instructions
reg [0:15]instr; //80 bits of an instruction (maximum size of instruction is 10 bytes)


always @(*)
begin
    //PC prediction
    if(M_icode == 4'b0111 & !M_cond) //jump failed
    begin
        PC = M_valA;
    end
    else if(W_icode==4'b1001) //ret
    begin
        PC = W_valM;
    end
    else
    begin
        PC = F_nextPC; //default value, PC of current instruction
    end
end


initial 
begin
//for testing fetch_tb.v
//opq - add
instr_mem[0] = 8'b01100000;
instr_mem[1] = 8'b00010011;

//irmovq
instr_mem[2] = 8'b00110000;
instr_mem[3] = 8'b11110011;
instr_mem[4] = 8'b00000000; //constant - 8 bytes
instr_mem[5] = 8'b00000000;
instr_mem[6] = 8'b00000000;
instr_mem[7] = 8'b00000000;
instr_mem[8] = 8'b00000000;
instr_mem[9] = 8'b00000010;
instr_mem[10] = 8'b00000000;
instr_mem[11] = 8'b00000100;

//pushq
instr_mem[12] = 8'b10100000;
instr_mem[13] = 8'b00111111;

//nop
instr_mem[14] = 8'b00010000;

//opq
instr_mem[15]=8'b01100000;
instr_mem[16]=8'b00100010;

//jump-zf
instr_mem[17]=8'b01110011;
instr_mem[18]=8'b00000000; //constant - 8 bytes
instr_mem[19]=8'b00000000;
instr_mem[20]=8'b00000000;
instr_mem[21]=8'b00000000;
instr_mem[22]=8'b00000000;
instr_mem[23]=8'b00000000;
instr_mem[24]=8'b00000010;
instr_mem[25]=8'b00000000;

//cmov-zf
instr_mem[26]=8'b00100011;
instr_mem[27]=8'b00100010;

//cmov-
instr_mem[28]=8'b00100010;
instr_mem[29]=8'b00100010;


//call
instr_mem[30]=8'b10000000;
instr_mem[31]=8'b00000000; //constant
instr_mem[32]=8'b00000000;
instr_mem[33]=8'b00000000;
instr_mem[34]=8'b00000000;
instr_mem[35]=8'b00000000;
instr_mem[36]=8'b00000000;
instr_mem[37]=8'b00000010;
instr_mem[38]=8'b00000010;


//mrmov
instr_mem[30]=8'b01010000;
instr_mem[31]=8'b00010000;
instr_mem[32]=8'b00000000; //constant
instr_mem[33]=8'b00000000;
instr_mem[34]=8'b00000000;
instr_mem[35]=8'b00000000;
instr_mem[36]=8'b00000000;
instr_mem[37]=8'b00000000;
instr_mem[38]=8'b00000000;
instr_mem[39]=8'b00000010;

//rmmov
instr_mem[40]=8'b01000000;
instr_mem[41]=8'b00010011;
instr_mem[42]=8'b00000000; //constant
instr_mem[43]=8'b00000000;
instr_mem[44]=8'b00000000;
instr_mem[45]=8'b00000000;
instr_mem[46]=8'b00000000;
instr_mem[47]=8'b00000000;
instr_mem[48]=8'b00000000;
instr_mem[49]=8'b00000100;

//call
instr_mem[50]=8'b10000000;
instr_mem[51]=8'b00000000; //constant
instr_mem[52]=8'b00000000;
instr_mem[53]=8'b00000000;
instr_mem[54]=8'b00000000;
instr_mem[55]=8'b00000000;
instr_mem[56]=8'b00000000;
instr_mem[57]=8'b00000000;
instr_mem[58]=8'b11000000;

//nop 
instr_mem[192]=8'b00010000;

//ret
instr_mem[193]=8'b10010000;

//popq
instr_mem[59]=8'b10110000;
instr_mem[60]=8'b00011111;

//halt
instr_mem[61]=8'b00000000;

end

always@(*)
begin
    in_mem = 1'b0; //invalid memory = 0
    in_inst = 1'b0;
    hlt = 1'b0;

    if(PC > 1023)
    begin
        //this is an invalid instruction
        in_mem = 1'b1;
    end

    //every instruction will be (PC + 10) max length
    instr = {instr_mem[PC],instr_mem[PC+1]};

    icode = instr[0:3];
    ifun = instr[4:7];

    case(icode)
    4'b0000: 
    begin
        hlt = 1'b1; //halt
        valP = PC + 64'd1; //next instruction is at PC + 1
    end

    4'b0001:
    begin
    valP = PC + 64'd1; //nop
    end

    4'b0010:
    begin
    //cmovxx or rrmovq
    rA = instr[8:11]; //first 4 bits of register byte
    rB = instr[12:15];
    valP = PC + 64'd2;
    hlt = 1'b0;
    end

    4'b0011:
    //irmov
    begin
    rA = instr[8:11]; //will be F because it is constant
    rB = instr[12:15];
    valC = {instr_mem[PC+2],instr_mem[PC+3],instr_mem[PC+4],instr_mem[PC+5],instr_mem[PC+6],instr_mem[PC+7],instr_mem[PC+8],instr_mem[PC+9]};
    valP = PC + 64'd10;
    hlt = 1'b0;
    end

    4'b0011:
    //irmov
    begin
    rA = instr[8:11];
    rB = instr[12:15];
    valC = {instr_mem[PC+2],instr_mem[PC+3],instr_mem[PC+4],instr_mem[PC+5],instr_mem[PC+6],instr_mem[PC+7],instr_mem[PC+8],instr_mem[PC+9]};
    valP = PC + 64'd10;
    hlt = 1'b0;
    end

    4'b0100:
    //rmmov
    begin
    rA = instr[8:11];
    rB = instr[12:15];
    valC = {instr_mem[PC+2],instr_mem[PC+3],instr_mem[PC+4],instr_mem[PC+5],instr_mem[PC+6],instr_mem[PC+7],instr_mem[PC+8],instr_mem[PC+9]};
    valP = PC + 64'd10;
    hlt = 1'b0;
    end

    4'b0101:
    //mrmov
    begin
    rA = instr[8:11];
    rB = instr[12:15];
    valC = {instr_mem[PC+2],instr_mem[PC+3],instr_mem[PC+4],instr_mem[PC+5],instr_mem[PC+6],instr_mem[PC+7],instr_mem[PC+8],instr_mem[PC+9]};
    valP = PC + 64'd10;
    hlt = 1'b0;
    end

    4'b0110:
    //op
    begin
    rA = instr[8:11];
    rB = instr[12:15];
    valP = PC + 64'd2;
    hlt = 1'b0;
    end

    4'b0111:
    //jXX
    begin
    valC = {instr_mem[PC+1],instr_mem[PC+2],instr_mem[PC+3],instr_mem[PC+4],instr_mem[PC+5],instr_mem[PC+6],instr_mem[PC+7],instr_mem[PC+8]};
    valP = PC + 64'd9;
    hlt = 1'b0;
    end

    4'b1000:
    //call
    begin
    valC = {instr_mem[PC+1],instr_mem[PC+2],instr_mem[PC+3],instr_mem[PC+4],instr_mem[PC+5],instr_mem[PC+6],instr_mem[PC+7],instr_mem[PC+8]};
    valP = PC + 64'd9;
    hlt = 1'b0;
    end

    4'b1001:
    begin
    //ret
    valP = PC + 64'd1;
    hlt = 1'b0;
    end

    4'b1001:
    begin
    //ret
    valP = PC + 64'd1;
    hlt = 1'b0;
    end

    4'b1010:
    begin
        //push
        rA = instr[8:11];
        rB = instr[12:15];
        valP = PC + 64'd2;
        hlt = 1'b0;
    end

    4'b1011:
    begin
        //push
        rA = instr[8:11];
        rB = instr[12:15];
        valP = PC + 64'd2;
        hlt = 1'b0;
    end

    default:
    begin
    in_inst = 1'b1;//the instruction is invalid
    hlt = 1'b0; 
    end
    endcase
    f_nextPC = valP; //setting the value of the next PC
end

//decode register -> between fetch and decdode stage
always @(posedge clk)
begin
    if(F_stall)
    begin
        PC = F_nextPC; //since fetch is stalled the PC remains the same and doesn't increment
    end
    else if(D_stall)
    begin
        //nothing in fetch stage
    end
    else if(D_bubble)
    begin
        //setting nop instruction details
        D_icode <= 4'b0001;
        D_ifun <= 4'b0000;
        D_rA <= 4'b0000;
        D_rB <= 4'b0000;
        D_valC <= 64'd0;
        D_valP <= 64'd0;
        D_hlt <= 1'b0;
        D_in_inst <= 1'b0;
        D_in_mem <= 1'b0;
    end
    else
    begin
        D_icode <= icode;
        D_ifun <= ifun;
        D_rA <= rA
        D_rB <= rB;
        D_valC <= valC;
        D_valP <= valP;
        D_hlt <= hlt;
        D_in_inst <= in_inst;
        D_in_mem <= in_mem;
    end
end
endmodule

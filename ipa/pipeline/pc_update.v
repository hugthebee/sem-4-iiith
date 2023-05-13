`timescale 1ns/10ps

module pc_update(clk, newPC, icode, valP, valM, valC, cond);

input clk;
input [3:0]icode;
input [63:0]valC;
input [63:0]valP;
input [63:0]valM;
input cond;
output reg [63:0]newPC;

always @(*)
begin
    //ret
    if (icode == 4'b1001) begin
        newPC = valM;
    end
    //call
    else if (icode == 4'b1000) begin
        newPC = valC;
    end
    //jxx
    else if (icode == 4'b0111) begin
        if (cond == 1) begin
            newPC = valC;
        end 
        else begin
            newPC = valP;
        end
    end
    else
    begin
        //every other instruction will be this
        newPC = valP;
    end
end
endmodule

//mem 16 has valP(59)
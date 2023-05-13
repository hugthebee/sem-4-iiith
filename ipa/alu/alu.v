`timescale 1ns/10ps
module andop(I1,I2,R);
input [63:0]I1;
input [63:0]I2;
output [63:0]R;

genvar i;
generate 
    for(i=0;i<64;i=i+1)
    begin
        and a0(R[i],I1[i],I2[i]);
    end
endgenerate
endmodule

module xorop(I1,I2,R);
input [63:0]I1;
input [63:0]I2;
output [63:0]R;

genvar i;
generate 
    for(i=0;i<64;i=i+1)
    begin
        xor x0(R[i],I1[i],I2[i]);
    end
endgenerate
endmodule

module ha(a, b, sum, carry);
input a, b;
output sum, carry;

xor xor1(sum, a, b);
and and1(carry, a, b);
endmodule

module fa(a, b, cin, sum, carry);
input a, b, cin;
output sum, carry;
wire w1, w2, w3;

xor xor1(w1, a, b);
xor xor2(sum, w1, cin);
and and1(w2, w1, cin);
and and2(w3, a, b);
or or1(carry, w2, w3);
endmodule

module add(a, b, out, cout);
input signed [63:0] a, b;
output signed [63:0] out;
output signed cout;
wire signed [63:0]carry;

genvar i;

generate 
for (i = 0; i < 64; i = i + 1)
begin
    if (i == 0)
        ha ha1(a[0], b[0], out[0], carry[0]);
    else
        fa fa1(a[i], b[i], carry[i - 1], out[i], carry[i]);
    end
    assign cout = carry[63];
endgenerate
endmodule

module sub(a, b, out, cout); //a-b
input signed [63:0] a, b;
output signed [63:0] out;
output signed cout;
wire signed [63:0]carry, temp;
wire signed xx;

assign xx = 1;

genvar p;
generate 
    for(p=0;p<=63;p=p+1)
    begin 
        not n1(temp[p],b[p]);   //temp = bitreveresed b
    end
endgenerate

genvar i;
generate 
for (i = 0; i < 64; i = i + 1)
begin
    if (i == 0)
        fa fa1(a[0], temp[0], xx, out[0], carry[0]);
    else
        fa fa1(a[i], temp[i], carry[i - 1], out[i], carry[i]);
    end
    assign cout = carry[63];
endgenerate
endmodule

module alu(P, Q, Z, carryout, select);
input signed[63:0]P;
input signed[63:0]Q;
input signed[2:0]select;
input signed carryin;
output signed[63:0]Z;
output signed carryout;
output signed[63:0] w1, w2, w3, w4;
reg signed [63:0]Z1;

assign carryout = 1'b0;

andop mod1 (P,Q,w1);
xorop mod2 (P,Q,w2);
add mod3 (P,Q,w3,carryout);
sub mod4 (P,Q, w4, carryout);

always @(P or Q or Z or carryout or select)
begin 
    case(select)
    2'b00: assign Z1 = w1;
    2'b01: assign Z1 = w2;
    2'b10: assign Z1 = w3;
    2'b11: assign Z1 = w4;
    endcase
end

assign Z = Z1;
endmodule

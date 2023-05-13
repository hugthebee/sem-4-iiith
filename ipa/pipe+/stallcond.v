module stallcond(m_hlt,m_in_inst,m_in_mem,,w_hlt,w_in_inst,w_in_mem,D_icode,E_icode,M_icode,d_srcA,d_srcB,E_dstM,e_cond,F_stall,D_stall,W_stall,D_bubble,E_bubble,M_bubble);

input e_cond;
input [3:0] D_icode,E_icode,M_icode,d_srcA,d_srcB,E_dstM;
input m_hlt,m_in_inst,m_in_mem,,w_hlt,w_in_inst,w_in_mem;

output reg F_stall,D_stall,W_stall,D_bubble,E_bubble,M_bubble,e_cond;

//all bubbles are zero initially 
initial 
begin
    F_stall=1'b0;
    D_stall=1'b0;
    D_bubble=1'b0; 
    E_bubble=1'b0;

end

always @(*) 
begin
    if ((((E_icode == 4'b0101)||(E_icode == 4'b1011))&&((E_dstM == d_srcA)||(E_dstM == d_srcB)))||((D_icode == 4'b1001)||(E_icode == 4'b1001)||(M_icode == 4'b1001)))
        F_stall = 1'b1; // ret case is better not considered
    else F_stall = 1'b0;

    if (((E_icode == 4'b0101)||(E_icode == 4'b1011))&&((E_dstM == d_srcA)||(E_dstM == d_srcB)))
        D_stall = 1'b1;
    else D_stall = 1'b0;    

    if (((E_icode == 4'b0111)&&(E_Cnd == 1'b0))||(((((E_icode == 4'b0101)||(E_icode == 4'b1011))&&((E_dstM == d_srcA)||(E_dstM == d_srcB)))) == 1'b0)&&((D_icode == 4'b1001)||(E_icode == 4'b1001)||(M_icode == 4'b1001)))
        D_bubble = 1'b1;
    else D_bubble = 1'b0; 

    if(((E_icode == 4'b0111)&&(e_cond == 1'b0))||(((E_icode == 4'b0101)||(E_icode == 4'b1011))&&((E_dstM == d_srcA)||(E_dstM == d_srcB))))
        E_bubble = 1'b1;
    else E_bubble = 1'b0;

end
endmodule

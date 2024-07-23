`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/10 12:32:02
// Design Name: 
// Module Name: Interrupt_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Interrupt_gen(
    input           i_clk               ,
    input           i_rst               ,
    input           i_user_irp_req      ,
    output [1 :0]   o_interrupt_req     ,
    input  [1 :0]   i_interrupt_ack     
);

reg  [1 :0]         ro_interrupt_req    ;
reg  [15:0]         r_cnt_1             ;
reg  [15:0]         r_cnt_2             ;
reg                 r_st                ;
reg                 ri_user_irp_req     ;

wire w_user_irp_req_pos;

assign w_user_irp_req_pos = i_user_irp_req && !ri_user_irp_req;

assign o_interrupt_req = ro_interrupt_req   ;

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_user_irp_req <= 'd0;
    else
        ri_user_irp_req <= i_user_irp_req;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt_1 <= 'd0;
    else if(r_cnt_2 == 50000)
        r_cnt_1 <= 'd0;
    else if(&r_cnt_1)
        r_cnt_1 <= r_cnt_1;
    else if(w_user_irp_req_pos || r_cnt_1)
        r_cnt_1 <= r_cnt_1 + 1;
    else
        r_cnt_1 <= r_cnt_1;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_cnt_2 <= 'd0;
    else if(r_cnt_2 == 50000)
        r_cnt_2 <= 'd0;
    else if(|i_interrupt_ack || r_cnt_2)
        r_cnt_2 <= r_cnt_2 + 1;
    else 
        r_cnt_2 <= r_cnt_2;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_st <= 'd0;
    else if(r_cnt_2 == 50000)
        r_st <= !r_st;
    else 
        r_st <= r_st;
end


always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_interrupt_req[0] <= 'd0;
    else if(r_cnt_2 == 50000 && r_st == 0)
        ro_interrupt_req[0] <= 'd0;
    else if(&r_cnt_1 && r_st == 0)   
        ro_interrupt_req[0] <= 'd1;
    else 
        ro_interrupt_req[0] <= ro_interrupt_req[0] ;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_interrupt_req[1] <= 'd0;
    else if(r_cnt_2 == 50000 && r_st == 1)
        ro_interrupt_req[1] <= 'd0;
    else if(&r_cnt_1 && r_st == 1)   
        ro_interrupt_req[1] <= 'd1;
    else 
        ro_interrupt_req[1] <= ro_interrupt_req[1] ;
end

endmodule

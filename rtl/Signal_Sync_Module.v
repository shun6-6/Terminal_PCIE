`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/11 00:39:49
// Design Name: 
// Module Name: Signal_Sync_Module
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


module Signal_Sync_Module#(
    parameter       P_CLK_FRQ_A   =   50_000_000    ,
    parameter       P_CLK_FRQ_B   =   50_000_000
)(
    input           i_clk_a             ,
    input           i_rst_a             ,
    input           i_signal_a          ,

    input           i_clk_b             ,
    input           i_rst_b             ,
    output          o_signal_b          
);

localparam          P_CNT_END_B = P_CLK_FRQ_A >= P_CLK_FRQ_B ? 2 : P_CLK_FRQ_B/P_CLK_FRQ_A + 1;

assign o_signal_b = r_signal_b ;

reg             r_signal_a  ;
reg             r_ack_a1    ;
reg             r_ack_a2    ;


always@(posedge i_clk_a,posedge i_rst_a)
begin
   if(i_rst_a)
        r_signal_a <= 'd0;
   else if(r_ack_a2)
        r_signal_a <= 'd0;
   else if(i_signal_a)
        r_signal_a <= 'd1;
   else  
        r_signal_a <= r_signal_a;
end

always@(posedge i_clk_a,posedge i_rst_a)
begin
    if(i_rst_a) begin
        r_ack_a1 <= 'd0;
        r_ack_a2 <= 'd0;
    end else begin
        r_ack_a1 <= r_ack_b;
        r_ack_a2 <= r_ack_a1;
    end
end


/*----------------*/

reg         r_signal_b1     ;
reg         r_signal_b2     ;
reg         r_signal_b      ;
reg         r_ack_b         ;
reg  [7:0]  r_cnt_b         ;
wire        w_signal_b_pos  ;

assign w_signal_b_pos = ~r_signal_b2 & r_signal_b1;

always@(posedge i_clk_b,posedge i_rst_b)
begin
    if(i_rst_b) begin
        r_signal_b1 <= 'd0;
        r_signal_b2 <= 'd0;
    end else if(r_signal_a) begin
        r_signal_b1 <= 'd1;
        r_signal_b2 <= r_signal_b1;
    end else begin
        r_signal_b1 <= 'd0;
        r_signal_b2 <= 'd0;
    end 
end

always@(posedge i_clk_b,posedge i_rst_b)
begin
    if(i_rst_b) 
        r_signal_b <= 'd0;
    else if(w_signal_b_pos)
        r_signal_b <= 'd1;
    else 
        r_signal_b <= 'd0;
end

always@(posedge i_clk_b,posedge i_rst_b)
begin
    if(i_rst_b) 
        r_ack_b <= 'd0;
    else if(r_cnt_b == P_CNT_END_B - 1)
        r_ack_b <= 'd0;
    else if(w_signal_b_pos)
        r_ack_b <= 'd1;
    else 
        r_ack_b <= r_ack_b;
end


always@(posedge i_clk_b,posedge i_rst_b)
begin
    if(i_rst_b) 
        r_cnt_b <= 'd0;
    else if(r_ack_b)
        r_cnt_b <= r_cnt_b + 1;
    else 
        r_cnt_b <= 'd0;
end
endmodule

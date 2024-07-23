`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2024 02:28:39 PM
// Design Name: 
// Module Name: XDMA_Interrupt_CTRL
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


module XDMA_Interrupt_CTRL(
    input           i_clk                   ,
    input           i_rst                   ,

    input           i_xdma_clk              ,
    input           i_xdma_rst              ,
    
    input           i_write_interr_req      ,
    output          o_write_interr_ack      ,
    output [1 :0]   o_xdma_interrupt        ,
    input           i_interrupt0_ack        
);

reg                 ri_write_interr_req     ;
reg                 ro_write_interr_ack     ;
reg  [1 :0]         ro_xdma_interrupt       ;
reg                 ro_xdma_interrupt_1d    ;
reg                 ro_xdma_interrupt_2d    ;

assign o_write_interr_ack = ro_write_interr_ack ;
assign o_xdma_interrupt   = {1'b0,ro_xdma_interrupt_2d}   ;

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_write_interr_req <= 'd0;
    else 
        ri_write_interr_req <= i_write_interr_req;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_xdma_interrupt <= 'd0;
    else if(i_interrupt0_ack || (!i_write_interr_req && ri_write_interr_req))
        ro_xdma_interrupt <= 'd0;
    else if(i_write_interr_req && !ri_write_interr_req)
        ro_xdma_interrupt <= 'd1;
    else 
        ro_xdma_interrupt <= ro_xdma_interrupt;
end
//跨时钟打俩拍
always@(posedge i_xdma_clk,posedge i_xdma_rst)
begin
    if(i_xdma_rst)begin
        ro_xdma_interrupt_1d <= 'd0;
        ro_xdma_interrupt_2d <= 'd0;
    end
    else begin
        ro_xdma_interrupt_1d <= ro_xdma_interrupt[0];
        ro_xdma_interrupt_2d <= ro_xdma_interrupt_1d;
    end
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_write_interr_ack <= 'd0;
    else if(i_interrupt0_ack)
        ro_write_interr_ack <= 'd1;
    else 
        ro_write_interr_ack <= 'd0;
end


endmodule

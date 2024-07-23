`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2024 10:07:54 AM
// Design Name: 
// Module Name: GT8B10B_DW_32to64
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


module GT8B10B_DW_32to64(
    input           i_clk                   ,
    input           i_rst                   ,

    input  [31:0]   i_8b10b_32b_axis_data   ,
    input  [3 :0]   i_8b10b_32b_axis_keep   ,
    input           i_8b10b_32b_axis_valid  ,
    input           i_8b10b_32b_axis_last   ,

    output [63:0]   o_8b10b_64b_axis_data   ,
    output [7 :0]   o_8b10b_64b_axis_keep   ,
    output          o_8b10b_64b_axis_valid  ,
    output          o_8b10b_64b_axis_last   ,
    input           i_8b10b_64b_axis_ready    
);

reg  [31:0] ri_8b10b_32b_axis_data  ;
reg  [3 :0] ri_8b10b_32b_axis_keep  ;
reg         ri_8b10b_32b_axis_valid ;
reg         ri_8b10b_32b_axis_last  ;

reg  [63:0] ro_8b10b_64b_axis_data  ;
reg  [7 :0] ro_8b10b_64b_axis_keep  ;
reg         ro_8b10b_64b_axis_valid ;
reg         ro_8b10b_64b_axis_last  ;

reg  [1 :0] r_recv_cnt              ;

assign o_8b10b_64b_axis_data  = ro_8b10b_64b_axis_data  ;
assign o_8b10b_64b_axis_keep  = ro_8b10b_64b_axis_keep  ;
assign o_8b10b_64b_axis_valid = ro_8b10b_64b_axis_valid ;
assign o_8b10b_64b_axis_last  = ro_8b10b_64b_axis_last  ;


always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)begin
        ri_8b10b_32b_axis_data  <= 'd0;
        ri_8b10b_32b_axis_keep  <= 'd0;
        ri_8b10b_32b_axis_valid <= 'd0;
        ri_8b10b_32b_axis_last  <= 'd0;
    end
    else begin
        ri_8b10b_32b_axis_data  <= i_8b10b_32b_axis_data ;
        ri_8b10b_32b_axis_keep  <= i_8b10b_32b_axis_keep ;
        ri_8b10b_32b_axis_valid <= i_8b10b_32b_axis_valid;
        ri_8b10b_32b_axis_last  <= i_8b10b_32b_axis_last ;
    end

end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        r_recv_cnt <= 'd0;
    else if(ri_8b10b_32b_axis_last)
        r_recv_cnt <= 'd0;
    else if(r_recv_cnt == 1)
        r_recv_cnt <= 'd0;
    else if(ri_8b10b_32b_axis_valid)
        r_recv_cnt <= r_recv_cnt + 1;
    else
        r_recv_cnt <= r_recv_cnt;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_8b10b_64b_axis_data <= 64'd0;
    else if(ri_8b10b_32b_axis_valid && ri_8b10b_32b_axis_last && r_recv_cnt == 0)
        ro_8b10b_64b_axis_data <= {ri_8b10b_32b_axis_data,32'd0};
    else if(ri_8b10b_32b_axis_valid)
        ro_8b10b_64b_axis_data <= {ro_8b10b_64b_axis_data[31:0],ri_8b10b_32b_axis_data};
    else
        ro_8b10b_64b_axis_data <= ro_8b10b_64b_axis_data;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_8b10b_64b_axis_valid <= 'd0;
    else if(r_recv_cnt == 1 || ri_8b10b_32b_axis_last)
        ro_8b10b_64b_axis_valid <= 'd1;
    else
        ro_8b10b_64b_axis_valid <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_8b10b_64b_axis_last <= 'd0;
    else if(ro_8b10b_64b_axis_last && ro_8b10b_64b_axis_valid)
        ro_8b10b_64b_axis_last <= 'd0;
    else if(ri_8b10b_32b_axis_last)
        ro_8b10b_64b_axis_last <= 'd1;
    else
        ro_8b10b_64b_axis_last <= 'd0;
end

always @(posedge i_clk or posedge i_rst)begin
    if(i_rst)
        ro_8b10b_64b_axis_keep <= 8'b1111_1111;
    else if(ri_8b10b_32b_axis_last && r_recv_cnt == 0)
        ro_8b10b_64b_axis_keep <= {ri_8b10b_32b_axis_keep,4'b0000};
    else if(ri_8b10b_32b_axis_last && r_recv_cnt == 1)
        ro_8b10b_64b_axis_keep <= {4'b1111,ri_8b10b_32b_axis_keep};
    else
        ro_8b10b_64b_axis_keep <= 8'b1111_1111;
end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2024 10:39:57 AM
// Design Name: 
// Module Name: AXIS_Data_Buffer
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


module AXIS_Data_Buffer#(
    parameter                   P_DATA_WIDTH = 64   ,
    parameter                   P_KEEP_WIDTH = 8    ,
    parameter                   P_USER_WIDTH = 16    
)(
    input                       i_pre_clk           ,
    input                       i_pre_rst           ,
    input  [P_DATA_WIDTH-1:0]   i_pre_axis_data     ,
    input  [P_USER_WIDTH-1:0]   i_pre_axis_user     ,
    input  [P_KEEP_WIDTH-1:0]   i_pre_axis_keep     ,
    input                       i_pre_axis_last     ,
    input                       i_pre_axis_valid    ,
    output                      o_pre_axis_ready    ,

    input                       i_post_clk          ,
    input                       i_post_rst          ,
    output [P_DATA_WIDTH-1:0]   o_post_axis_data    ,
    output [15:0]               o_post_axis_user    ,
    output [P_KEEP_WIDTH-1:0]   o_post_axis_keep    ,
    output                      o_post_axis_last    ,
    output                      o_post_axis_valid   ,
    input                       i_post_axis_ready    
);
//*********************************************parameter*************************************************//

//*********************************************function**************************************************//

//***********************************************FSM*****************************************************//

//***********************************************reg*****************************************************//
(* MARK_DEBUG = "TRUE" *)reg  [P_DATA_WIDTH-1:0] ri_pre_axis_data    ;
(* MARK_DEBUG = "TRUE" *)reg  [P_USER_WIDTH-1:0] ri_pre_axis_user    ;
(* MARK_DEBUG = "TRUE" *)reg  [P_KEEP_WIDTH-1:0] ri_pre_axis_keep    ;
(* MARK_DEBUG = "TRUE" *)reg                     ri_pre_axis_last    ;
(* MARK_DEBUG = "TRUE" *)reg                     ri_pre_axis_valid   ;
(* MARK_DEBUG = "TRUE" *)reg                     ro_pre_axis_ready   ;

(* MARK_DEBUG = "TRUE" *)reg  [P_DATA_WIDTH-1:0] ro_post_axis_data   ;
(* MARK_DEBUG = "TRUE" *)reg  [P_USER_WIDTH-1:0] ro_post_axis_user   ;
(* MARK_DEBUG = "TRUE" *)reg  [P_KEEP_WIDTH-1:0] ro_post_axis_keep   ;
(* MARK_DEBUG = "TRUE" *)reg                     ro_post_axis_last   ;
(* MARK_DEBUG = "TRUE" *)reg                     ro_post_axis_valid  ;

(* MARK_DEBUG = "TRUE" *)reg  [15:0]             r_recv_cnt          ;
(* MARK_DEBUG = "TRUE" *)reg  [15:0]             r_send_cnt          ;
(* MARK_DEBUG = "TRUE" *)reg                     r_fifo_data_rden    ;
reg                     r_fifo_data_rden_1d ;
(* MARK_DEBUG = "TRUE" *)reg                     r_fifo_keep_rden    ;
(* MARK_DEBUG = "TRUE" *)reg                     r_fifo_len_rden     ; 
(* MARK_DEBUG = "TRUE" *)reg                     r_fifo_len_lock     ;

(* MARK_DEBUG = "TRUE" *)reg  [15:0]             r_fifo_len_dout     ;
(* MARK_DEBUG = "TRUE" *)reg  [P_KEEP_WIDTH-1:0] r_fifo_keep_dout    ;
//***********************************************wire****************************************************//
wire [P_DATA_WIDTH-1:0] w_fifo_data_dout    ;
wire                    w_fifo_data_full    ;
wire                    w_fifo_data_empty   ;
wire [P_KEEP_WIDTH-1:0] w_fifo_keep_dout    ;
wire                    w_fifo_keep_full    ;
wire                    w_fifo_keep_empty   ;
wire [15:0]             w_fifo_len_dout     ;
wire                    w_fifo_len_full     ;
wire                    w_fifo_len_empty    ;

wire                    w_pre_active        ;
wire                    w_post_active       ;
//**********************************************assign***************************************************//
assign o_pre_axis_ready     = ro_pre_axis_ready ;
assign o_post_axis_data     = ro_post_axis_data ;
assign o_post_axis_user     = ro_post_axis_user ;
assign o_post_axis_keep     = ro_post_axis_keep ;
assign o_post_axis_last     = ro_post_axis_last ;
assign o_post_axis_valid    = ro_post_axis_valid;
assign w_pre_active         = o_pre_axis_ready && i_pre_axis_valid;
assign w_post_active        = o_post_axis_valid && i_post_axis_ready ;
//*********************************************component*************************************************//
FIFO_Ind_64X1024 FIFO_Ind_64X1024_AXIS_DATA_Buf (
    .wr_clk     (i_pre_clk          ),
    .wr_rst     (i_pre_rst          ),
    .rd_clk     (i_post_clk         ),
    .rd_rst     (i_post_rst         ),
    .din        (ri_pre_axis_data   ),
    .wr_en      (ri_pre_axis_valid  ),
    .rd_en      (r_fifo_data_rden   ),
    .dout       (w_fifo_data_dout   ),
    .full       (w_fifo_data_full   ),
    .empty      (w_fifo_data_empty  )
);

FIFO_Ind_8X128 FIFO_Ind_8X128_AXIS_KEEP_Buf (
    .wr_clk     (i_pre_clk          ),
    .wr_rst     (i_pre_rst          ),
    .rd_clk     (i_post_clk         ),
    .rd_rst     (i_post_rst         ),
    .din        (ri_pre_axis_keep   ),
    .wr_en      (ri_pre_axis_last   ),
    .rd_en      (r_fifo_keep_rden   ),
    .dout       (w_fifo_keep_dout   ),
    .full       (w_fifo_keep_full   ),
    .empty      (w_fifo_keep_empty  )
);

FIFO_Ind_16X128 FIFO_Ind_16X128_AXIS_DATA_Len (
    .wr_clk     (i_pre_clk          ),
    .wr_rst     (i_pre_rst          ),
    .rd_clk     (i_post_clk         ),
    .rd_rst     (i_post_rst         ),
    .din        (r_recv_cnt         ),
    .wr_en      (ri_pre_axis_last   ),
    .rd_en      (r_fifo_len_rden    ),
    .dout       (w_fifo_len_dout    ),
    .full       (w_fifo_len_full    ),
    .empty      (w_fifo_len_empty   )
);
//**********************************************always***************************************************//

always @(posedge i_pre_clk or posedge i_pre_rst)begin
    if(i_pre_rst)begin
        ri_pre_axis_data  <= 'd0;
        ri_pre_axis_user  <= 'd0;
        ri_pre_axis_keep  <= 'd0;
        ri_pre_axis_last  <= 'd0;
        ri_pre_axis_valid <= 'd0;
    end
    else if(w_pre_active)begin
        ri_pre_axis_data  <= i_pre_axis_data ;
        ri_pre_axis_user  <= i_pre_axis_user ;
        ri_pre_axis_keep  <= i_pre_axis_keep ;
        ri_pre_axis_last  <= i_pre_axis_last ;
        ri_pre_axis_valid <= i_pre_axis_valid;
    end
    else begin
        ri_pre_axis_data  <= 'd0;
        ri_pre_axis_user  <= 'd0;
        ri_pre_axis_keep  <= 'd0;
        ri_pre_axis_last  <= 'd0;
        ri_pre_axis_valid <= 'd0; 
    end

end
//**************** pre_clk ****************//
//记录输入数据长度
always @(posedge i_pre_clk or posedge i_pre_rst)begin
    if(i_pre_rst)
        r_recv_cnt <= 'd0;
    else if(ri_pre_axis_last)
        r_recv_cnt <= 'd0;
    else if(i_pre_axis_valid)
        r_recv_cnt <= r_recv_cnt + 'd1;
    else
        r_recv_cnt <= r_recv_cnt;
end

always @(posedge i_pre_clk or posedge i_pre_rst)begin
    if(i_pre_rst)
        ro_pre_axis_ready <= 'd0;
    else if(w_fifo_data_full)
        ro_pre_axis_ready <= 'd0;
    else
        ro_pre_axis_ready <= 'd1;
end

//**************** post_clk ****************//
//完成一次传输后才可以读下一次长度信息，通过r_fifo_len_lock控制读长度FIFO
always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_len_lock <= 'd0;
    else if(ro_post_axis_last && w_post_active)
        r_fifo_len_lock <= 'd0;
    else if(!w_fifo_len_empty && !r_fifo_len_lock)
        r_fifo_len_lock <= 'd1;
    else
        r_fifo_len_lock <= r_fifo_len_lock;
end
//get data length
always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_len_rden <= 'd0;
    else if(!w_fifo_len_empty && !r_fifo_len_lock)
        r_fifo_len_rden <= 'd1;
    else
        r_fifo_len_rden <= 'd0;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_len_dout <= 'd0;
    else
        r_fifo_len_dout <= w_fifo_len_dout;
end
//get last data's keep 
always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_keep_rden <= 'd0;
    else if(!w_fifo_keep_empty && !r_fifo_len_lock)
        r_fifo_keep_rden <= 'd1;
    else
        r_fifo_keep_rden <= 'd0;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_keep_dout <= 'd0;
    else
        r_fifo_keep_dout <= w_fifo_keep_dout;
end

//开始读数据
always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_data_rden <= 'd0;
    else if(r_send_cnt == r_fifo_len_dout - 1)
        r_fifo_data_rden <= 'd0;
    else if(r_fifo_len_rden)
        r_fifo_data_rden <= 'd1;
    else
        r_fifo_data_rden <= r_fifo_data_rden;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_fifo_data_rden_1d <= 'd0;
    else
        r_fifo_data_rden_1d <= r_fifo_data_rden;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        r_send_cnt <= 'd0;
    else if((r_send_cnt == r_fifo_len_dout) && r_send_cnt != 0)
        r_send_cnt <= 'd0;
    else if(r_fifo_data_rden)
        r_send_cnt <= r_send_cnt + 1;
    else
        r_send_cnt <= r_send_cnt;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        ro_post_axis_data <= 'd0;
    else if(r_fifo_data_rden_1d)
        ro_post_axis_data <= w_fifo_data_dout;
    else
        ro_post_axis_data <= 'd0;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        ro_post_axis_valid <= 'd0;
    else if(r_fifo_data_rden_1d)
        ro_post_axis_valid <= 'd1;
    else
        ro_post_axis_valid <= 'd0;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        ro_post_axis_keep <= 8'b1111_1111;
    else if(r_send_cnt == r_fifo_len_dout && r_send_cnt != 0)
        ro_post_axis_keep <= r_fifo_keep_dout;
    else
        ro_post_axis_keep <=  8'b1111_1111;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        ro_post_axis_last <= 1'b0;
    else if(r_send_cnt == r_fifo_len_dout && r_send_cnt != 0)
        ro_post_axis_last <= 1'b1;
    else
        ro_post_axis_last <= 1'b0;
end

always @(posedge i_post_clk or posedge i_post_rst)begin
    if(i_post_rst)
        ro_post_axis_user <= 'd0; 
    else
        ro_post_axis_user <= r_fifo_len_dout;
end


endmodule

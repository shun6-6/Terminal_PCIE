`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2024 11:27:31 AM
// Design Name: 
// Module Name: Memory_manage
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


module Memory_manage(
    input               i_clk                           ,
    input               i_rst                           ,

    input  [15:0]       i_req0_len                      ,
    input               i_req0_valid                    ,
    output              o_req0_ready                    ,
    output [31:0]       o_ack0_addr                     ,
    output              o_ack0_valid                    ,
    input               i_ack0_ready                    ,

    input  [15:0]       i_req1_len                      ,
    input               i_req1_valid                    ,
    output              o_req1_ready                    ,
    output [31:0]       o_ack1_addr                     ,
    output              o_ack1_valid                    ,
    input               i_ack1_ready                    ,

    output [31:0]       o_bar_w_len                     ,
    output [31:0]       o_bar_w_addr                    ,
    output              o_bar_w_valid                   ,

    output              o_interrupt_req                 ,
    input               i_interrupt_ack                 ,

    output [7 :0]       o_stream_id                     ,
    output              o_stream_valid                

    // input               i_trans_end                     ,

    // input  [7 :0]       i_packet_queue                  ,
    // input               i_packet_valid                  ,
    // output [31:0]       o_packet_addr                   ,
    // output [31:0]       o_packet_len                    ,
    // output [7 :0]       o_packet_id                     ,
  
);
//*********************************************function**************************************************//

//*********************************************parameter*************************************************//

//***********************************************FSM*****************************************************//

//***********************************************reg*****************************************************//
reg                     ro_req0_ready                   ;
reg  [31:0]             ro_ack0_addr                    ;
reg                     ro_ack0_valid                   ;
reg                     ro_req1_ready                   ;
reg  [31:0]             ro_ack1_addr                    ;
reg                     ro_ack1_valid                   ;
reg  [31:0]             ro_bar_w_len                    ;
reg  [31:0]             ro_bar_w_addr                   ;
reg                     ro_bar_w_valid                  ;
reg                     ro_interrupt_req                ;
reg  [15:0]             r_req0_len                      ;
reg  [15:0]             r_req1_len                      ;
reg  [7 :0]             r_arbiter                       ;
reg                     r_req0_active                   ;
reg                     r_req1_active                   ;

reg  [31:0]             r_ddr_len                       ;
reg  [31:0]             r_ddr_addr                      ;
reg  [7 :0]             r_list_num                      ;
reg  [15:0]             r_cnt_0                         ;
reg  [15:0]             r_cnt_1                         ;
reg  [31:0]             r_initial_addr                  ;
reg  [15:0]             r_cnt_interrupt_0               ;
reg  [15:0]             r_cnt_interrupt_1               ;
reg  [7 :0]             ro_stream_id                    ;
reg                     ro_stream_valid                 ;
//***********************************************wire****************************************************//
wire                    w_req0_active                   ;
wire                    w_req1_active                   ;
wire                    w_ack0_active                   ;
wire                    w_ack1_active                   ;
//**********************************************assign***************************************************//
assign o_bar_w_len     = ro_bar_w_len                   ;
assign o_bar_w_addr    = ro_bar_w_addr                  ;
assign o_bar_w_valid   = ro_bar_w_valid                 ;
assign o_interrupt_req = ro_interrupt_req               ;
assign o_req0_ready    = ro_req0_ready                  ;
assign o_ack0_addr     = ro_ack0_addr                   ;
assign o_ack0_valid    = ro_ack0_valid                  ;
assign o_req1_ready    = ro_req1_ready                  ;
assign o_ack1_addr     = ro_ack1_addr                   ;
assign o_ack1_valid    = ro_ack1_valid                  ;
assign w_req0_active   = i_req0_valid & o_req0_ready    ;
assign w_req1_active   = i_req1_valid & o_req1_ready    ;
assign w_ack0_active   = o_ack0_valid & i_ack0_ready    ;
assign w_ack1_active   = o_ack1_valid & i_ack1_ready    ;
//*********************************************component*************************************************//

//**********************************************always***************************************************//
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst) begin
        r_req0_active <= 'd0;
        r_req1_active <= 'd0;
    end else begin
        r_req0_active <= w_req0_active;
        r_req1_active <= w_req1_active;
    end
end
//r_arbiter = 1 : ACK for UDP, r_arbiter = 2 : ACK for 8b10b GT phy 
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_arbiter <= 'd1;
    else if((i_req0_valid | i_req1_valid) & r_arbiter == 2)
        r_arbiter <= 'd1;
    else if(i_req0_valid | i_req1_valid)       
        r_arbiter <= r_arbiter + 1;
    else 
        r_arbiter <= r_arbiter;
end 
//req readay
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        ro_req0_ready <= 'd0;
    else if(w_req0_active)
        ro_req0_ready <= 'd0;
    else if(r_arbiter == 1)
        ro_req0_ready <= 'd1;
    else        
        ro_req0_ready <= ro_req0_ready;
end 

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        ro_req1_ready <= 'd0;
    else if(w_req1_active)
        ro_req1_ready <= 'd0;
    else if(r_arbiter == 2)
        ro_req1_ready <= 'd1;
    else        
        ro_req1_ready <= ro_req1_ready;
end 
//get req's length
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_req0_len <= 'd0;
    else if(w_req0_active)
        r_req0_len <= i_req0_len;
    else 
        r_req0_len <= r_req0_len;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_req1_len <= 'd0;
    else if(w_req1_active)
        r_req1_len <= i_req1_len;
    else 
        r_req1_len <= r_req1_len;
end
//compute ddr address
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_ddr_len <= 'd0;
    else if(ro_bar_w_valid)
        r_ddr_len <= 'd0;
    else if(r_req0_active)
        r_ddr_len <= r_ddr_len + (r_req0_len << 3); 
    else if(r_req1_active)
        r_ddr_len <= r_ddr_len + (r_req1_len << 3);  
    else 
        r_ddr_len <= r_ddr_len;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_ddr_addr <= 'd0;
    else if((r_req0_active | r_req1_active) && r_ddr_addr >= 1073741824 - 2048)
        r_ddr_addr <= 'd0;
    else if(r_req0_active)
        r_ddr_addr <= r_ddr_addr + (r_req0_len << 3);
    else if(r_req1_active)
        r_ddr_addr <= r_ddr_addr + (r_req1_len << 3);
    else        
        r_ddr_addr <= r_ddr_addr;
end
//ACK ddr address
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst) begin
        ro_ack0_addr  <= 'd0;
        ro_ack0_valid <= 'd0;
    end else if(r_req0_active) begin
        ro_ack0_addr  <= r_ddr_addr;
        ro_ack0_valid <= 'd1;
    end else begin
        ro_ack0_addr  <= 'd0;
        ro_ack0_valid <= 'd0;
    end
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst) begin
        ro_ack1_addr  <= 'd0;
        ro_ack1_valid <= 'd0;
    end else if(r_req1_active) begin
        ro_ack1_addr  <= r_ddr_addr;
        ro_ack1_valid <= 'd1;
    end else begin
        ro_ack1_addr  <= 'd0;
        ro_ack1_valid <= 'd0;
    end
end
//记录已经存入的数据包数目，当达到56个包或者1s内没有数据输入则开始通过XDMA输出数据
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_list_num <= 'd0;
    else if(r_list_num == 56 || (r_cnt_1 == 10000 - 1 && r_list_num))
        r_list_num <= 'd0;
    else if(r_req0_active | r_req1_active)
        r_list_num <= r_list_num + 1;
    else 
        r_list_num <= r_list_num;
end
//通过俩个计数器相套达到计时1s功能
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_cnt_0 <= 'd0;
    else if(w_req0_active | w_req1_active)
        r_cnt_0 <= 'd0;
    else if(r_cnt_0 == 20000 - 1)//100us
        r_cnt_0 = 'd0;
    else
        r_cnt_0 <= r_cnt_0 + 1;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_cnt_1 <= 'd0;
    else if(w_req0_active | w_req1_active)
        r_cnt_1 <= 'd0;
    else if(r_cnt_1 == 10000 - 1)//1S
        r_cnt_1 <= 'd0;
    else if(r_cnt_0 == 20000 - 1)//100us
        r_cnt_1 <= r_cnt_1 + 1;
    else
        r_cnt_1 <= r_cnt_1;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst) begin
        ro_stream_id    <= 'd0;
        ro_stream_valid <= 'd0;
    end else if(ro_stream_valid) begin
        ro_stream_id    <= 'd0;
        ro_stream_valid <= 'd0;
    end else if(r_req0_active) begin
        ro_stream_id    <= 'd0;
        ro_stream_valid <= 'd1;
    end else if(r_req1_active) begin
        ro_stream_id    <= 'd1;
        ro_stream_valid <= 'd1;
    end else begin
        ro_stream_id    <= 'd0;
        ro_stream_valid <= 'd0;
    end
end
//告知XDMA一整个数据包的起始地址r_initial_addr
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_initial_addr <= 'd0;
    else if(r_list_num == 0 && (r_req0_active | r_req1_active))
        r_initial_addr <= r_ddr_addr;
    else 
        r_initial_addr <= r_initial_addr;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst) begin
        ro_bar_w_len   <= 'd0;
        ro_bar_w_addr  <= 'd0;
        ro_bar_w_valid <= 'd0;
    end else if(ro_bar_w_valid) begin
        ro_bar_w_len   <= 'd0;
        ro_bar_w_addr  <= 'd0;
        ro_bar_w_valid <= 'd0;
    end else if(r_list_num == 56 || (r_cnt_1 == 10000 - 1 && r_list_num)) begin
        ro_bar_w_len   <= r_ddr_len;
        ro_bar_w_addr  <= r_initial_addr;
        ro_bar_w_valid <= 'd1;
    end else begin
        ro_bar_w_len   <= 'd0;
        ro_bar_w_addr  <= 'd0;
        ro_bar_w_valid <= 'd0;
    end
end
//产生中断
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ro_interrupt_req <= 'd0;
    else if(i_interrupt_ack || r_cnt_interrupt_1 == 500 - 1)
        ro_interrupt_req <= 'd0;
    else if(ro_bar_w_valid)
        ro_interrupt_req <= 'd1;
    else 
        ro_interrupt_req <= ro_interrupt_req;
end
//中断计数器
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_cnt_interrupt_0 <= 'd0;
    else if(!ro_interrupt_req)
        r_cnt_interrupt_0 <= 'd0;
    else if(r_cnt_interrupt_0 == 20000 - 1)//100us
        r_cnt_interrupt_0 = 'd0;
    else
        r_cnt_interrupt_0 <= r_cnt_interrupt_0 + 1;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_cnt_interrupt_1 <= 'd0;
    else if(!ro_interrupt_req)
        r_cnt_interrupt_1 <= 'd0;
    else if(r_cnt_interrupt_1 == 500 - 1)//50ms
        r_cnt_interrupt_1 <= 'd0;
    else if(r_cnt_interrupt_0 == 20000 - 1)//100us
        r_cnt_interrupt_1 <= r_cnt_interrupt_1 + 1;
    else
        r_cnt_interrupt_1 <= r_cnt_interrupt_1;
end

endmodule

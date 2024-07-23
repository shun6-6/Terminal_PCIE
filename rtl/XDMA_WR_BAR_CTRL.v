`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2024 03:08:58 PM
// Design Name: 
// Module Name: XDMA_WR_BAR_CTRL
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
//reg0 - write address   只能由FPGA写，上位机只读
//reg1 - write length    只能由FPGA写，上位机只读
//reg2 - interrupt clear 只能由FPGA读，上位机只写
//reg3 - Sub Num
//reg4....n - Sub ID

module XDMA_WR_BAR_CTRL#(
	parameter integer                           C_S_AXI_DATA_WIDTH	= 32    ,
	parameter integer                           C_S_AXI_ADDR_WIDTH	= 11    ,
    parameter integer                           C_S_AXI_BASE_ADDR   = 32'h0000_0000
)(
	input wire                                  S_AXI_ACLK          ,
	input wire                                  S_AXI_ARESETN       ,
	input wire [C_S_AXI_ADDR_WIDTH-1 : 0]       S_AXI_AWADDR        ,
	input wire [2 : 0]                          S_AXI_AWPROT        ,
	input wire                                  S_AXI_AWVALID       ,
	output wire                                 S_AXI_AWREADY       ,
	input wire [C_S_AXI_DATA_WIDTH-1 : 0]       S_AXI_WDATA         ,
	input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0]   S_AXI_WSTRB         ,
	input wire                                  S_AXI_WVALID        ,
	output wire                                 S_AXI_WREADY        ,
	output wire [1 : 0]                         S_AXI_BRESP         ,
	output wire                                 S_AXI_BVALID        ,
	input wire                                  S_AXI_BREADY        ,
	input wire [C_S_AXI_ADDR_WIDTH-1 : 0]       S_AXI_ARADDR        ,
	input wire [2 : 0]                          S_AXI_ARPROT        ,
	input wire                                  S_AXI_ARVALID       ,
	output wire                                 S_AXI_ARREADY       ,
	output wire [C_S_AXI_DATA_WIDTH-1 : 0]      S_AXI_RDATA         ,
	output wire [1 : 0]                         S_AXI_RRESP         ,
	output wire                                 S_AXI_RVALID        ,
	input wire                                  S_AXI_RREADY        ,

    input                                       i_clk_200MHz        ,
    input                                       i_rst_200MHz        ,
    input  [31:0]                               i_bar_addr          ,
    input  [31:0]                               i_bar_len           ,
    input                                       i_bar_valid         ,
    input  [7 :0]                               i_stream_id         ,
    input                                       i_stream_valid      ,
    output                                      o_interrupt_clear   
);
//*********************************************function**************************************************//

//*********************************************parameter*************************************************//

//***********************************************FSM*****************************************************//

//***********************************************reg*****************************************************//
reg                 rS_AXI_AWREADY      ;
reg                 rS_AXI_WREADY       ;
reg  [1 :0]         rS_AXI_BRESP        ;
reg                 rS_AXI_BVALID       ;
reg                 rS_AXI_ARREADY      ;
reg  [31:0]         rS_AXI_RDATA        ;
reg  [1 :0]         rS_AXI_RRESP        ;
reg                 rS_AXI_RVALID       ;

reg                 r_fifo_rden         ;
reg                 r_fifo_rden_1d      ;
reg                 r_fifo_rden_2d      ;
reg                 r_fifo_id_rden      ;
reg                 r_fifo_id_rden_1d   ;

reg  [31:0]         r_reg[0:3]          ;
reg  [7 :0]         r_reg_addr          ;
reg                 ri_bar_valid        ;
reg                 ri_bar_valid_1d     ;
reg  [31:0]         ri_bar_addr         ;
reg  [31:0]         ri_bar_len          ;
reg                 ro_interrupt_clear  ;
reg                 r_w_active          ;
reg                 r_ar_active         ;
//***********************************************wire****************************************************//
wire                i_clk               ;
wire                i_rst               ;
wire [31:0]         w_bar_addr          ;
wire [31:0]         w_bar_len           ;
wire   				w_fifo_empty		;
wire                w_aw_active         ;
wire                w_w_active          ;
wire                w_b_active          ;
wire                w_ar_active         ;
wire                w_r_active          ;
wire                w_interr_act        ;
wire                w_interr_act_200    ;
wire [31:0]         w_stream_id         ;
//**********************************************assign***************************************************//
assign i_clk = S_AXI_ACLK               ;
assign i_rst = ~S_AXI_ARESETN           ;
assign S_AXI_AWREADY = rS_AXI_AWREADY   ;
assign S_AXI_WREADY  = rS_AXI_WREADY    ;
assign S_AXI_BRESP   = rS_AXI_BRESP     ;
assign S_AXI_BVALID  = rS_AXI_BVALID    ;
assign S_AXI_ARREADY = rS_AXI_ARREADY   ;
assign S_AXI_RDATA   = rS_AXI_RDATA     ;
assign S_AXI_RRESP   = rS_AXI_RRESP     ;
assign S_AXI_RVALID  = rS_AXI_RVALID    ;
assign w_aw_active   = S_AXI_AWREADY & S_AXI_AWVALID;
assign w_w_active    = S_AXI_WREADY  & S_AXI_WVALID ;
assign w_b_active    = S_AXI_BREADY  & S_AXI_BVALID ;
assign w_ar_active   = S_AXI_ARREADY & S_AXI_ARVALID;
assign w_r_active    = S_AXI_RREADY  & S_AXI_RVALID ;
assign o_interrupt_clear = ro_interrupt_clear;
assign w_interr_act  = r_w_active && r_reg[2] == 1;
//*********************************************component*************************************************//
FIFO_Ind_32X16 FIFO_Ind_32X16_BAR_addr (
  .wr_clk   (i_clk_200MHz   ),
  .wr_rst   (i_rst_200MHz   ),
  .rd_clk   (i_clk          ),
  .rd_rst   (i_rst          ),
  .din      (i_bar_addr     ),
  .wr_en    (i_bar_valid    ),
  .rd_en    (r_fifo_rden    ),
  .dout     (w_bar_addr     ),
  .full     (),
  .empty    (w_fifo_empty	)
);

FIFO_Ind_32X16 FIFO_Ind_32X16_BAR_len (
  .wr_clk   (i_clk_200MHz   ),
  .wr_rst   (i_rst_200MHz   ),
  .rd_clk   (i_clk          ),
  .rd_rst   (i_rst          ),
  .din      (i_bar_len      ),
  .wr_en    (i_bar_valid    ),
  .rd_en    (r_fifo_rden    ),
  .dout     (w_bar_len		),
  .full     (),
  .empty    ()
);

FIFO_Ind_32X64 FIFO_Ind_32X64_stream_id (
  .wr_clk   (i_clk_200MHz   ),
  .wr_rst   (i_rst_200MHz   ),
  .rd_clk   (i_clk          ),
  .rd_rst   (i_rst          ),
  .din      ({24'd0,i_stream_id}),
  .wr_en    (i_stream_valid	),
  .rd_en    (r_fifo_id_rden	),
  .dout     (w_stream_id	),
  .full     (),
  .empty    ()
);
//将XDMA接收到的250Mhz时钟域下的中断信号跨到200Mhz下
Signal_Sync_Module#(
    .P_CLK_FRQ_A   (250_000_000      ),
    .P_CLK_FRQ_B   (200_000_000      ) 
)
Signal_Sync_Module_u0
(
    .i_clk_a       (i_clk           ),
    .i_rst_a       (i_rst           ),
    .i_signal_a    (w_interr_act    ),

    .i_clk_b       (i_clk_200MHz    ),
    .i_rst_b       (i_rst_200MHz    ),
    .o_signal_b    (w_interr_act_200)
);
//**********************************************always***************************************************//
//中断清除信号
always@(posedge i_clk_200MHz,posedge i_rst_200MHz)begin
    if(i_rst_200MHz)
        ro_interrupt_clear <= 'd0;
    else if(w_interr_act_200)
        ro_interrupt_clear <= 'd1;
    else 
        ro_interrupt_clear <= 'd0;
end
//当FIFO不为空的时候开始读出BAR LEN ADDR 等信息，然后通过AXILITE写入BAR空间
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_fifo_rden <= 'd0;
    else if(r_fifo_rden)
        r_fifo_rden <= 'd0;
    else if(!w_fifo_empty)
        r_fifo_rden <= 'd1;
    else 
        r_fifo_rden <= 'd0;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst) begin
        ri_bar_valid <= 'd0;
        ri_bar_valid_1d <= 'd0;
        r_w_active <= 'd0;
        r_ar_active <= 'd0;
        r_fifo_rden_1d <= 'd0;
        r_fifo_rden_2d <= 'd0;
    end else begin 
        ri_bar_valid <= r_fifo_rden_1d && r_fifo_rden_2d;
        ri_bar_valid_1d <= ri_bar_valid;
        r_w_active <= w_w_active;
        r_ar_active <= w_ar_active;
        r_fifo_rden_1d <= r_fifo_rden;
        r_fifo_rden_2d <= r_fifo_rden_1d;
    end
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        rS_AXI_AWREADY <= 'd1;
    else if(w_aw_active)
        rS_AXI_AWREADY <= 'd0;
    else if(w_b_active)
        rS_AXI_AWREADY <= 'd1;
    else 
        rS_AXI_AWREADY <= rS_AXI_AWREADY;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        rS_AXI_WREADY <= 'd0;
    else if(w_w_active)
        rS_AXI_WREADY <= 'd0;
    else if(w_aw_active)
        rS_AXI_WREADY <= 'd1;
    else 
        rS_AXI_WREADY <= rS_AXI_WREADY;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst) begin 
        rS_AXI_BRESP  <= 'd0;
        rS_AXI_BVALID <= 'd0;
    end else if(w_b_active) begin
        rS_AXI_BRESP  <= 'd0;
        rS_AXI_BVALID <= 'd0;
    end else if(w_w_active) begin
        rS_AXI_BRESP  <= 'd0;
        rS_AXI_BVALID <= 'd1;
    end else begin
        rS_AXI_BRESP  <= rS_AXI_BRESP ;
        rS_AXI_BVALID <= rS_AXI_BVALID;
    end
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        rS_AXI_ARREADY <= 'd1;
    else if(w_ar_active)
        rS_AXI_ARREADY <= 'd0;
    else if(w_r_active)
        rS_AXI_ARREADY <= 'd1;
    else 
        rS_AXI_ARREADY <= rS_AXI_ARREADY;
end
//获取XDMA的读写地址
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_reg_addr <= 'd0;
    else if(w_aw_active)
        r_reg_addr <= (S_AXI_AWADDR - C_S_AXI_BASE_ADDR) >> 2;
    else if(w_ar_active)
        r_reg_addr <= (S_AXI_ARADDR - C_S_AXI_BASE_ADDR) >> 2;
    else 
        r_reg_addr <= r_reg_addr;
end
//当读地址大于3时，从FIFO当中读取流ID
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_id_rden <= 'd0;
    else if(r_ar_active && r_reg_addr >= 3)
        r_fifo_id_rden <= 'd1;
    else 
        r_fifo_id_rden <= 'd0;
end

always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        r_fifo_id_rden_1d <= 'd0;
    else 
        r_fifo_id_rden_1d <= r_fifo_id_rden;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst) begin
        rS_AXI_RDATA  <= 'd0;
        rS_AXI_RRESP  <= 'd0;
        rS_AXI_RVALID <= 'd0;
    end else if(w_r_active) begin
        rS_AXI_RDATA  <= 'd0;
        rS_AXI_RRESP  <= 'd0;
        rS_AXI_RVALID <= 'd0;
    end else if(r_reg_addr < 3 && r_ar_active) begin
        rS_AXI_RDATA  <= r_reg[r_reg_addr];
        rS_AXI_RRESP  <= 'd0;
        rS_AXI_RVALID <= 'd1;
    end else if(r_fifo_id_rden_1d) begin
        rS_AXI_RDATA  <= w_stream_id;
        rS_AXI_RRESP  <= 'd0;
        rS_AXI_RVALID <= 'd1;
    end else begin
        rS_AXI_RDATA  <= rS_AXI_RDATA ;
        rS_AXI_RRESP  <= rS_AXI_RRESP ;
        rS_AXI_RVALID <= rS_AXI_RVALID;
    end 
end

always@(posedge i_clk)
begin
    if(r_reg[2] > 0)
        r_reg[2] <= 'd0;
    else if(r_fifo_rden_1d && !r_fifo_rden_2d) begin
        r_reg[0] <= w_bar_addr;
        r_reg[1] <= w_bar_len;
    end  else if(w_w_active)
        r_reg[2] <= S_AXI_WDATA;
end

endmodule

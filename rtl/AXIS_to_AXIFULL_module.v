`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2024 09:26:49 AM
// Design Name: 
// Module Name: AXIS_to_AXIFULL_module
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


module AXIS_to_AXIFULL_module#(
	parameter           C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000  ,
	parameter integer   C_M_AXI_BURST_LEN	        = 16            ,
	parameter integer   C_M_AXI_ID_WIDTH	        = 1             ,
	parameter integer   C_M_AXI_ADDR_WIDTH	        = 32            ,
	parameter integer   C_M_AXI_DATA_WIDTH	        = 32            ,
	parameter integer   C_M_AXI_AWUSER_WIDTH	    = 0             ,
	parameter integer   C_M_AXI_ARUSER_WIDTH	    = 0             ,
	parameter integer   C_M_AXI_WUSER_WIDTH	        = 0             ,
	parameter integer   C_M_AXI_RUSER_WIDTH	        = 0             ,
	parameter integer   C_M_AXI_BUSER_WIDTH	        = 0             
)(
	input  wire                                 M_AXI_ACLK          ,
	input  wire                                 M_AXI_ARESETN       ,  

    (* MARK_DEBUG = "TRUE" *)input       [63: 0]                         S_AXIS_DATA         ,
    (* MARK_DEBUG = "TRUE" *)input       [15: 0]                         S_AXIS_USER         ,
    (* MARK_DEBUG = "TRUE" *)input       [7 : 0]                         S_AXIS_KEEP         ,
    (* MARK_DEBUG = "TRUE" *)input                                       S_AXIS_VALID        ,
    (* MARK_DEBUG = "TRUE" *)input                                       S_AXIS_LAST         ,  

	output wire [C_M_AXI_ID_WIDTH-1 : 0]        M_AXI_AWID          ,
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0]      M_AXI_AWADDR        ,
	output wire [7 : 0]                         M_AXI_AWLEN         ,
	output wire [2 : 0]                         M_AXI_AWSIZE        ,
	output wire [1 : 0]                         M_AXI_AWBURST       ,
	output wire                                 M_AXI_AWLOCK        ,
	output wire [3 : 0]                         M_AXI_AWCACHE       ,
	output wire [2 : 0]                         M_AXI_AWPROT        ,
	output wire [3 : 0]                         M_AXI_AWQOS         ,
	output wire [C_M_AXI_AWUSER_WIDTH-1 : 0]    M_AXI_AWUSER        ,
	output wire                                 M_AXI_AWVALID       ,
	input  wire                                 M_AXI_AWREADY       ,

	output wire [C_M_AXI_DATA_WIDTH-1 : 0]      M_AXI_WDATA         ,
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0]    M_AXI_WSTRB         ,
	output wire                                 M_AXI_WLAST         ,
	output wire [C_M_AXI_WUSER_WIDTH-1 : 0]     M_AXI_WUSER         ,
	output wire                                 M_AXI_WVALID        ,
	input  wire                                 M_AXI_WREADY        ,   

	input  wire [C_M_AXI_ID_WIDTH-1 : 0]        M_AXI_BID           ,
	input  wire [1 : 0]                         M_AXI_BRESP         ,
	input  wire [C_M_AXI_BUSER_WIDTH-1 : 0]     M_AXI_BUSER         ,
	input  wire                                 M_AXI_BVALID        ,
	output wire                                 M_AXI_BREADY        ,

	output wire [C_M_AXI_ID_WIDTH-1 : 0]        M_AXI_ARID          ,
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0]      M_AXI_ARADDR        ,
	output wire [7 : 0]                         M_AXI_ARLEN         ,
	output wire [2 : 0]                         M_AXI_ARSIZE        ,
	output wire [1 : 0]                         M_AXI_ARBURST       ,
	output wire                                 M_AXI_ARLOCK        ,   
	output wire [3 : 0]                         M_AXI_ARCACHE       ,
	output wire [2 : 0]                         M_AXI_ARPROT        ,
	output wire [3 : 0]                         M_AXI_ARQOS         ,
	output wire [C_M_AXI_ARUSER_WIDTH-1 : 0]    M_AXI_ARUSER        ,
	output wire                                 M_AXI_ARVALID       ,
	input  wire                                 M_AXI_ARREADY       ,

	input  wire [C_M_AXI_ID_WIDTH-1 : 0]        M_AXI_RID           ,
	input  wire [C_M_AXI_DATA_WIDTH-1 : 0]      M_AXI_RDATA         ,
	input  wire [1 : 0]                         M_AXI_RRESP         ,
	input  wire                                 M_AXI_RLAST         ,
	input  wire [C_M_AXI_RUSER_WIDTH-1 : 0]     M_AXI_RUSER         ,
	input  wire                                 M_AXI_RVALID        ,
	output wire                                 M_AXI_RREADY        ,

    output      [15:0]                          o_mem_req_len       ,
    output                                      o_mem_req_valid     ,
    input                                       i_mem_req_ready     ,

    input       [31:0]                          i_mem_ack_addr      ,
    input                                       i_mem_ack_valid     ,
    output                                      o_mem_ack_ready     
);
//*********************************************function**************************************************//
function integer clogb2 (input integer bit_depth);              
	  begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	      bit_depth = bit_depth >> 1;                                 
	    end                                                           
endfunction
//*********************************************parameter*************************************************//
localparam                              P_DATA_BYTE = C_M_AXI_DATA_WIDTH/8;
localparam                              P_M_AXI_SIZE = clogb2((C_M_AXI_DATA_WIDTH/8) - 1);
//***********************************************FSM*****************************************************//
reg  [7 :0]                             r_cur_state         ;
reg  [7 :0]                             r_nxt_state         ;
reg  [15:0]                             r_st_cnt            ;

localparam                              P_ST_IDLE    =  0   ,
                                        P_ST_WRITE   =  1   ;
//***********************************************reg*****************************************************//
reg  [C_M_AXI_ID_WIDTH-1 : 0]           ro_M_AXI_AWID       ;
reg  [C_M_AXI_ADDR_WIDTH-1 : 0]         ro_M_AXI_AWADDR     ;
reg  [7 : 0]                            ro_M_AXI_AWLEN      ;
reg  [2 : 0]                            ro_M_AXI_AWSIZE     ;
reg  [1 : 0]                            ro_M_AXI_AWBURST    ;
reg                                     ro_M_AXI_AWLOCK     ;
reg  [3 : 0]                            ro_M_AXI_AWCACHE    ;
reg  [2 : 0]                            ro_M_AXI_AWPROT     ;
reg  [3 : 0]                            ro_M_AXI_AWQOS      ;
reg  [C_M_AXI_AWUSER_WIDTH-1 : 0]       ro_M_AXI_AWUSER     ;
reg                                     ro_M_AXI_AWVALID    ;
reg  [C_M_AXI_DATA_WIDTH-1 : 0]         ro_M_AXI_WDATA      ;
reg  [C_M_AXI_DATA_WIDTH/8-1 : 0]       ro_M_AXI_WSTRB      ;
reg                                     ro_M_AXI_WLAST      ;
reg  [C_M_AXI_WUSER_WIDTH-1 : 0]        ro_M_AXI_WUSER      ;
reg                                     ro_M_AXI_WVALID     ;
reg                                     ro_M_AXI_BREADY     ;
reg [C_M_AXI_ID_WIDTH-1 : 0]            ro_M_AXI_ARID       ;
reg [C_M_AXI_ADDR_WIDTH-1 : 0]          ro_M_AXI_ARADDR     ;
reg [7 : 0]                             ro_M_AXI_ARLEN      ;
reg [2 : 0]                             ro_M_AXI_ARSIZE     ;
reg [1 : 0]                             ro_M_AXI_ARBURST    ;
reg                                     ro_M_AXI_ARLOCK     ;
reg [3 : 0]                             ro_M_AXI_ARCACHE    ;
reg [2 : 0]                             ro_M_AXI_ARPROT     ;
reg [3 : 0]                             ro_M_AXI_ARQOS      ;
reg [C_M_AXI_ARUSER_WIDTH-1 : 0]        ro_M_AXI_ARUSER     ;
reg                                     ro_M_AXI_ARVALID    ;
reg                                     ro_M_AXI_RREADY     ;
reg [C_M_AXI_DATA_WIDTH-1 : 0]          ri_M_AXI_RDATA      ;
reg                                     ri_M_AXI_RLAST      ;
reg                                     ri_M_AXI_RVALID     ;

(* MARK_DEBUG = "TRUE" *)reg  [63: 0]                            rS_AXIS_DATA        ;
(* MARK_DEBUG = "TRUE" *)reg  [15: 0]                            rS_AXIS_USER        ;
(* MARK_DEBUG = "TRUE" *)reg  [7 : 0]                            rS_AXIS_KEEP        ;
(* MARK_DEBUG = "TRUE" *)reg                                     rS_AXIS_VALID       ;
(* MARK_DEBUG = "TRUE" *)reg                                     rS_AXIS_LAST        ;

(* MARK_DEBUG = "TRUE" *)reg  [15: 0]                            ro_mem_req_len      ;
(* MARK_DEBUG = "TRUE" *)reg                                     ro_mem_req_valid    ;
(* MARK_DEBUG = "TRUE" *)reg  [31: 0]                            ri_mem_ack_addr     ;

reg  [15:0]                             r_write_cnt         ;

//FIFO
reg                                     r_fifo_len_rden     ;
reg                                     r_fifo_len_rden_1d  ;
reg                                     r_fifo_len_lock     ;
reg                                     r_fifo_data_rden_1d ;
//***********************************************wire****************************************************//
wire                                    i_clk               ;
(* MARK_DEBUG = "TRUE" *)wire                                    i_rst               ;
wire                                    w_fifo_data_rden    ;
wire  [63: 0]                           w_fifo_data_dout    ;
wire                                    w_fifo_data_full    ;
wire                                    w_fifo_data_empty   ;

wire  [15: 0]                           w_fifo_len_dout     ;
wire                                    w_fifo_len_full     ;
wire                                    w_fifo_len_empty    ;

wire                                    w_ack_active        ;
wire                                    w_req_active        ;
wire  [15:0]                            w_axis_byte_len     ;
//**********************************************assign***************************************************//
assign M_AXI_AWID       = ro_M_AXI_AWID     ;
assign M_AXI_AWADDR     = ro_M_AXI_AWADDR   ;
assign M_AXI_AWLEN      = ro_M_AXI_AWLEN    ;
assign M_AXI_AWSIZE     = ro_M_AXI_AWSIZE   ;
assign M_AXI_AWBURST    = ro_M_AXI_AWBURST  ;
assign M_AXI_AWLOCK     = ro_M_AXI_AWLOCK   ;
assign M_AXI_AWCACHE    = ro_M_AXI_AWCACHE  ;
assign M_AXI_AWPROT     = ro_M_AXI_AWPROT   ;
assign M_AXI_AWQOS      = ro_M_AXI_AWQOS    ;
assign M_AXI_AWUSER     = ro_M_AXI_AWUSER   ;
assign M_AXI_AWVALID    = ro_M_AXI_AWVALID  ;
assign M_AXI_WDATA      = w_fifo_data_dout  ;
assign M_AXI_WSTRB      = ro_M_AXI_WSTRB    ;
assign M_AXI_WLAST      = ro_M_AXI_WLAST    ;
assign M_AXI_WUSER      = ro_M_AXI_WUSER    ;
assign M_AXI_WVALID     = ro_M_AXI_WVALID   ;
assign M_AXI_BREADY     = ro_M_AXI_BREADY   ;
assign M_AXI_ARID       = ro_M_AXI_ARID     ;
assign M_AXI_ARADDR     = ro_M_AXI_ARADDR   ;
assign M_AXI_ARLEN      = ro_M_AXI_ARLEN    ;
assign M_AXI_ARSIZE     = ro_M_AXI_ARSIZE   ;
assign M_AXI_ARBURST    = ro_M_AXI_ARBURST  ;
assign M_AXI_ARLOCK     = ro_M_AXI_ARLOCK   ;
assign M_AXI_ARCACHE    = ro_M_AXI_ARCACHE  ;
assign M_AXI_ARPROT     = ro_M_AXI_ARPROT   ;
assign M_AXI_ARQOS      = ro_M_AXI_ARQOS    ;
assign M_AXI_ARUSER     = ro_M_AXI_ARUSER   ;
assign M_AXI_ARVALID    = ro_M_AXI_ARVALID  ;
assign M_AXI_RREADY     = ro_M_AXI_RREADY   ;
assign w_AW_active      = M_AXI_AWVALID & M_AXI_AWREADY;
assign w_W_active       = M_AXI_WVALID  & M_AXI_WREADY ;
assign w_B_active       = M_AXI_BVALID  & M_AXI_BREADY ;
assign w_AR_active      = M_AXI_ARVALID & M_AXI_ARREADY;
assign w_R_active       = M_AXI_RVALID  & M_AXI_RREADY ;

assign i_clk            = M_AXI_ACLK        ;
assign i_rst            = !M_AXI_ARESETN    ;
assign w_ack_active     = o_mem_ack_ready && i_mem_ack_valid   ;
assign w_req_active     = ro_mem_req_valid && i_mem_req_ready   ;
assign w_fifo_data_rden = w_W_active        ;
assign o_mem_req_len    = ro_mem_req_len    ;
assign o_mem_req_valid  = ro_mem_req_valid  ;
assign o_mem_ack_ready  = 1                 ;
//assign w_axis_byte_len  = (rS_AXIS_USER[2:0] == 0) ? (rS_AXIS_USER << 3) : (rS_AXIS_USER << 3 + 1);
//*********************************************component*************************************************//
FIFO_Com_64X512 FIFO_Com_64X512_data (
  .clk      (i_clk              ),
  .srst     (i_rst              ),
  .din      (rS_AXIS_DATA       ),
  .wr_en    (rS_AXIS_VALID      ),
  .rd_en    (w_fifo_data_rden   ),
  .dout     (w_fifo_data_dout   ),
  .full     (w_fifo_data_full   ),
  .empty    (w_fifo_data_empty  ) 
);

FIFO_Com_16X64 FIFO_Com_16X64_len (
  .clk      (i_clk              ),
  .srst     (i_rst              ),
  .din      (rS_AXIS_USER       ),
  .wr_en    (rS_AXIS_LAST       ),
  .rd_en    (r_fifo_len_rden    ),
  .dout     (w_fifo_len_dout    ),
  .full     (w_fifo_len_full    ),
  .empty    (w_fifo_len_empty   ) 
);
//**********************************************always***************************************************//
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst) begin
        rS_AXIS_DATA  <= 'd0;
        rS_AXIS_USER  <= 'd0;
        rS_AXIS_KEEP  <= 'd0;
        rS_AXIS_VALID <= 'd0;
        rS_AXIS_LAST  <= 'd0;
    end else begin
        rS_AXIS_DATA  <= S_AXIS_DATA ;
        rS_AXIS_USER  <= S_AXIS_USER ;
        rS_AXIS_KEEP  <= S_AXIS_KEEP ;
        rS_AXIS_VALID <= S_AXIS_VALID;
        rS_AXIS_LAST  <= S_AXIS_LAST ;
    end
end
//发出一次内存请求
always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_fifo_len_rden <= 'd0;
    else if(!w_fifo_len_empty && !r_fifo_len_lock)
        r_fifo_len_rden <= 'd1;
    else    
        r_fifo_len_rden <= 'd0;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_fifo_len_rden_1d <= 'd0;
    else
        r_fifo_len_rden_1d <= r_fifo_len_rden;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        r_fifo_len_lock <= 'd0;
    else if(ro_M_AXI_WLAST && w_W_active)
        r_fifo_len_lock <= 'd0;
    else if(!w_fifo_len_empty && !r_fifo_len_lock)
        r_fifo_len_lock <= 'd1;
    else    
        r_fifo_len_lock <= r_fifo_len_lock;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        ro_mem_req_len <= 'd0;
    else if(r_fifo_len_rden_1d)
        ro_mem_req_len <= w_fifo_len_dout;
    else    
        ro_mem_req_len <= ro_mem_req_len;
end

always@(posedge i_clk,posedge i_rst)begin
    if(i_rst)
        ro_mem_req_valid <= 'd0;
    else if(w_req_active)
        ro_mem_req_valid <= 'd0;
    else if(r_fifo_len_rden_1d)
        ro_mem_req_valid <= 'd1;
    else 
        ro_mem_req_valid <= ro_mem_req_valid;
end

//get ACK and memory address
always@(posedge i_clk,posedge i_rst)
begin
    if(i_rst)
        ri_mem_ack_addr <= 'd0;
    else if(w_ack_active)
        ri_mem_ack_addr <= i_mem_ack_addr;
    else 
        ri_mem_ack_addr <= ri_mem_ack_addr;
end

always@(posedge M_AXI_ACLK,negedge M_AXI_ARESETN)
begin
    if(!M_AXI_ARESETN)
        r_cur_state <= P_ST_IDLE;
    else 
        r_cur_state <= r_nxt_state;
end

always@(posedge M_AXI_ACLK,negedge M_AXI_ARESETN)
begin
    if(!M_AXI_ARESETN)
        r_st_cnt <= 'd0;
    else if(r_cur_state != r_nxt_state)
        r_st_cnt <= 'd0;
    else 
        r_st_cnt <= r_st_cnt + 1;
end

always@(*)
begin
    case(r_cur_state)
        P_ST_IDLE  : r_nxt_state = w_ack_active   ? P_ST_WRITE : P_ST_IDLE    ;
        P_ST_WRITE : r_nxt_state = w_B_active     ? P_ST_IDLE  : P_ST_WRITE   ;
        default    : r_nxt_state = P_ST_IDLE;
    endcase
end

//AXI FULL interface
always@(posedge M_AXI_ACLK,negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN) begin
        ro_M_AXI_AWID    <= 'd0;
        ro_M_AXI_AWADDR  <= 'd0;
        ro_M_AXI_AWLEN   <= 'd0;
        ro_M_AXI_AWSIZE  <= 'd0;
        ro_M_AXI_AWBURST <= 'd0;
        ro_M_AXI_AWLOCK  <= 'd0;
        ro_M_AXI_AWCACHE <= 'd0;
        ro_M_AXI_AWPROT  <= 'd0;
        ro_M_AXI_AWQOS   <= 'd0;
        ro_M_AXI_AWUSER  <= 'd0;
        ro_M_AXI_AWVALID <= 'd0;
    end else if(w_AW_active) begin
        ro_M_AXI_AWID    <= 'd0;
        ro_M_AXI_AWADDR  <= 'd0;
        ro_M_AXI_AWLEN   <= 'd0;
        ro_M_AXI_AWSIZE  <= 'd0;
        ro_M_AXI_AWBURST <= 'd0;
        ro_M_AXI_AWLOCK  <= 'd0;
        ro_M_AXI_AWCACHE <= 'd0;
        ro_M_AXI_AWPROT  <= 'd0;
        ro_M_AXI_AWQOS   <= 'd0;
        ro_M_AXI_AWUSER  <= 'd0;
        ro_M_AXI_AWVALID <= 'd0;
    end else if(r_cur_state == P_ST_WRITE && r_st_cnt == 0) begin
        ro_M_AXI_AWID    <= 'd0;
        ro_M_AXI_AWADDR  <= ri_mem_ack_addr;
        ro_M_AXI_AWLEN   <= ro_mem_req_len - 1;
        ro_M_AXI_AWSIZE  <= P_M_AXI_SIZE;
        ro_M_AXI_AWBURST <= 2'b01;
        ro_M_AXI_AWLOCK  <= 'd0;
        ro_M_AXI_AWCACHE <= 4'b0010;
        ro_M_AXI_AWPROT  <= 'd0;
        ro_M_AXI_AWQOS   <= 'd0;
        ro_M_AXI_AWUSER  <= 'd0;
        ro_M_AXI_AWVALID <= 'd1;
    end else begin  
        ro_M_AXI_AWID    <= ro_M_AXI_AWID   ;
        ro_M_AXI_AWADDR  <= ro_M_AXI_AWADDR ;
        ro_M_AXI_AWLEN   <= ro_M_AXI_AWLEN  ;
        ro_M_AXI_AWSIZE  <= ro_M_AXI_AWSIZE ;
        ro_M_AXI_AWBURST <= ro_M_AXI_AWBURST;
        ro_M_AXI_AWLOCK  <= ro_M_AXI_AWLOCK ;
        ro_M_AXI_AWCACHE <= ro_M_AXI_AWCACHE;
        ro_M_AXI_AWPROT  <= ro_M_AXI_AWPROT ;
        ro_M_AXI_AWQOS   <= ro_M_AXI_AWQOS  ;
        ro_M_AXI_AWUSER  <= ro_M_AXI_AWUSER ;
        ro_M_AXI_AWVALID <= ro_M_AXI_AWVALID;
    end
end

always@(posedge M_AXI_ACLK,negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN) begin
        ro_M_AXI_WDATA <= 'd0;
        ro_M_AXI_WSTRB <= {P_DATA_BYTE{1'b1}};
        ro_M_AXI_WUSER <= 'd0;
    end else begin
        ro_M_AXI_WDATA <= w_fifo_data_dout;
        ro_M_AXI_WSTRB <= {P_DATA_BYTE{1'b1}};
        ro_M_AXI_WUSER <= 'd0;
    end 
end

always@(posedge M_AXI_ACLK,negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN)
        ro_M_AXI_WVALID <= 'd0;
    else if(ro_M_AXI_WLAST && w_W_active)
        ro_M_AXI_WVALID <= 'd0;
    else if(w_AW_active)   
        ro_M_AXI_WVALID <= 'd1;
    else 
        ro_M_AXI_WVALID <= ro_M_AXI_WVALID;
end

always@(posedge M_AXI_ACLK,negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN)
        r_write_cnt <= 'd0;
    else if(w_W_active && r_write_cnt == ro_mem_req_len - 1)
        r_write_cnt <= 'd0;
    else if(w_W_active)   
        r_write_cnt <= r_write_cnt + 'd1;
    else 
        r_write_cnt <= r_write_cnt;
end

always@(posedge M_AXI_ACLK,negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN)
        ro_M_AXI_WLAST <= 'd0;
    else if(ro_M_AXI_WLAST && w_W_active)
        ro_M_AXI_WLAST <= 'd0;
    else if(w_W_active && r_write_cnt == ro_mem_req_len - 2)   
        ro_M_AXI_WLAST <= 'd1;
    else        
        ro_M_AXI_WLAST <= ro_M_AXI_WLAST;
end

always@(posedge M_AXI_ACLK,negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN)
        ro_M_AXI_BREADY <= 'd0;
    else if(w_B_active)
        ro_M_AXI_BREADY <= 'd0;
    else if(ro_M_AXI_WLAST)
        ro_M_AXI_BREADY <= 'd1;
    else 
        ro_M_AXI_BREADY <= ro_M_AXI_BREADY;
end

endmodule

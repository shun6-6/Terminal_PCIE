`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2024 04:43:52 PM
// Design Name: 
// Module Name: Terminal_Top
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


module Terminal_Top#(
    parameter       P_SRC_MAC = 48'h01_02_03_04_05_06,
    parameter       P_DST_MAC = 48'hff_ff_ff_ff_ff_ff
)(
    output [14:0]   DDR3_0_addr             ,
    output [2:0]    DDR3_0_ba               ,
    output          DDR3_0_cas_n            ,
    output [0:0]    DDR3_0_ck_n             ,
    output [0:0]    DDR3_0_ck_p             ,
    output [0:0]    DDR3_0_cke              ,
    output [0:0]    DDR3_0_cs_n             ,
    output [3:0]    DDR3_0_dm               ,
    inout [31:0]    DDR3_0_dq               ,
    inout [3:0]     DDR3_0_dqs_n            ,
    inout [3:0]     DDR3_0_dqs_p            ,
    output [0:0]    DDR3_0_odt              ,
    output          DDR3_0_ras_n            ,
    output          DDR3_0_reset_n          ,
    output          DDR3_0_we_n             ,
    input           SYS_CLK_0_clk_n         ,
    input           SYS_CLK_0_clk_p         ,
    output          init_calib_complete_0   ,
    input [7:0]     pcie_mgt_0_rxn          ,
    input [7:0]     pcie_mgt_0_rxp          ,
    output [7:0]    pcie_mgt_0_txn          ,
    output [7:0]    pcie_mgt_0_txp          ,
    input           pcie_sys_clk_p          ,
    input           pcie_sys_clk_n          ,
    input           pcie_sys_rst_n_0        ,
    output          user_lnk_up_0           ,

    input           i_gt_refclk_p           ,
    input           i_gt_refclk_n           ,
    output [1 :0]   o_gt_txp                ,
    output [1 :0]   o_gt_txn                ,
    input  [1 :0]   i_gt_rxp                ,
    input  [1 :0]   i_gt_rxn                ,
    output [1 :0]   o_sfp_disable           
);
assign          o_sfp_disable = 2'b00;
//XDMA
wire            w_mig_sys_rst           ;
wire            w_pcie_gt_clk           ;
wire [1:0]      w_usr_irq_ack_0         ;
wire [1:0]      w_usr_irq_req_0         ;
//GT 8B10B      
wire            w_tx0_rst               ;
wire            w_rx0_rst               ;
wire            w_tx0_done              ;
wire            w_rx0_done              ;
wire            w_rx0_ByteAlign         ;
wire            w_rx0_clk               ;
wire [31:0]     w_rx0_data              ;
wire [3 :0]     w_rx0_char              ;
wire            w_tx0_clk               ;
wire [31:0]     w_tx0_data              ;
wire [3 :0]     w_tx0_char              ;

wire            w_gtrefclk              ;

wire [31:0]     w_8b10b_tx_axis_data    ;
wire [3 :0]     w_8b10b_tx_axis_keep    ;
wire            w_8b10b_tx_axis_valid   ;
wire            w_8b10b_tx_axis_last    ;
wire            w_8b10b_tx_axis_ready   ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]     w_8b10b_rx_axis_data    ;
(* MARK_DEBUG = "TRUE" *)wire [3 :0]     w_8b10b_rx_axis_keep    ;
(* MARK_DEBUG = "TRUE" *)wire            w_8b10b_rx_axis_valid   ;
(* MARK_DEBUG = "TRUE" *)wire            w_8b10b_rx_axis_last    ;

wire [63:0]     w_8b10b_64b_axis_data   ;
wire [7 :0]     w_8b10b_64b_axis_keep   ;
wire            w_8b10b_64b_axis_valid  ;
wire            w_8b10b_64b_axis_last   ;
wire            w_8b10b_64b_axis_ready  ;

wire [63:0]     w_mem_8b10b_axis_data   ;
wire [15:0]     w_mem_8b10b_axis_user   ;
wire [7 :0]     w_mem_8b10b_axis_keep   ;
wire            w_mem_8b10b_axis_last   ;
wire            w_mem_8b10b_axis_valid  ;

//=======================10G UDP===================
reg             r_sim_ctrl = 0          ;
wire            w_tx_disable            ;
    
wire            w_gt_refclk             ;
wire            w_qplllock              ;
wire            w_qplloutclk            ;
wire            w_qplloutrefclk         ;
wire            w_qpllrefclklost        ;
wire            w_qpllreset             ;
wire            w_qpllreset_gt_phy;
wire            w_qpllreset_10g_mac;
    
wire            w_xgmii_clk             ;
wire            w_xgmii_rst             ;
wire [63 : 0]   w_xgmii_txd             ;
wire [7  : 0]   w_xgmii_txc             ;
wire [63 : 0]   w_xgmii_rxd             ;
wire [7  : 0]   w_xgmii_rxc             ;
    
(* MARK_DEBUG = "TRUE" *)wire            w_block_sync            ;
(* MARK_DEBUG = "TRUE" *)wire            w_rst_done              ;
(* MARK_DEBUG = "TRUE" *)wire            w_pma_link              ;
(* MARK_DEBUG = "TRUE" *)wire            w_pcs_rx_link           ;

(* MARK_DEBUG = "TRUE" *)wire [63:0]     wm_udp_axis_user_data   ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]     wm_udp_axis_user_user   ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]     wm_udp_axis_user_keep   ;
(* MARK_DEBUG = "TRUE" *)wire            wm_udp_axis_user_last   ;
(* MARK_DEBUG = "TRUE" *)wire            wm_udp_axis_user_valid  ;
wire [63:0]     ws_udp_axis_user_data   ;
wire [31:0]     ws_udp_axis_user_user   ;
wire [7 :0]     ws_udp_axis_user_keep   ;
wire            ws_udp_axis_user_last   ;
wire            ws_udp_axis_user_valid  ;
wire            ws_udp_axis_user_ready  ;

wire [63:0]     w_mem_udp_axis_data     ;
wire [15:0]     w_mem_udp_axis_user     ;
wire [7 :0]     w_mem_udp_axis_keep     ;
wire            w_mem_udp_axis_last     ;
wire            w_mem_udp_axis_valid    ;

//PLL
wire            w_pll_locked        ;
wire            w_clk_100Mhz        ;
wire            w_clk_150Mhz        ;
wire            w_clk_200Mhz        ;
wire            w_clk_250Mhz        ;
wire            w_clk_100Mhz_rst    ;
wire            w_clk_150Mhz_rst    ;
wire            w_clk_200Mhz_rst    ;
wire            w_clk_250Mhz_rst    ;

assign w_mig_sys_rst = w_pll_locked;
assign w_qpllreset = w_qpllreset_gt_phy || w_qpllreset_10g_mac;

SYS_CLK_PLL SYS_CLK_PLL_u0
   (
    .clk_out1   (w_clk_100Mhz),    
    .clk_out2   (w_clk_200Mhz),      
    .locked     (w_pll_locked       ),      
    .clk_in1_p  (SYS_CLK_0_clk_n    ),   
    .clk_in1_n  (SYS_CLK_0_clk_p    )    
);

IBUFDS_GTE2 #(
    .CLKCM_CFG("TRUE"),  
    .CLKRCV_TRST("TRUE"),
    .CLKSWING_CFG(2'b11) 
 )
 IBUFDS_GTE2_inst (
    .O      (w_pcie_gt_clk  ),
    .ODIV2  (),               
    .CEB    (0),              
    .I      (pcie_sys_clk_p ),
    .IB     (pcie_sys_clk_n ) 
 );


design_1_wrapper design_1_wrapper_u0(
    .DDR3_0_addr                            (DDR3_0_addr            ),
    .DDR3_0_ba                              (DDR3_0_ba              ),
    .DDR3_0_cas_n                           (DDR3_0_cas_n           ),
    .DDR3_0_ck_n                            (DDR3_0_ck_n            ),
    .DDR3_0_ck_p                            (DDR3_0_ck_p            ),
    .DDR3_0_cke                             (DDR3_0_cke             ),
    .DDR3_0_cs_n                            (DDR3_0_cs_n            ),
    .DDR3_0_dm                              (DDR3_0_dm              ),
    .DDR3_0_dq                              (DDR3_0_dq              ),
    .DDR3_0_dqs_n                           (DDR3_0_dqs_n           ),
    .DDR3_0_dqs_p                           (DDR3_0_dqs_p           ),
    .DDR3_0_odt                             (DDR3_0_odt             ),
    .DDR3_0_ras_n                           (DDR3_0_ras_n           ),
    .DDR3_0_reset_n                         (DDR3_0_reset_n         ),
    .DDR3_0_we_n                            (DDR3_0_we_n            ),
    // .MIG_SYS_CLK_0_clk_n                    (SYS_CLK_0_clk_n        ),//mig clk
    // .MIG_SYS_CLK_0_clk_p                    (SYS_CLK_0_clk_p        ),//mig clk
    .mig_sys_clk_i_0                        (w_clk_200Mhz           ),
    .init_calib_complete_0                  (init_calib_complete_0  ),
    .mig_sys_rst_0                          (w_mig_sys_rst          ),//MIG reset :low active
    .mmcm_locked_0                          (),
    .msi_enable_0                           (),
    .msi_vector_width_0                     (),
    .pcie_mgt_0_rxn                         (pcie_mgt_0_rxn         ),
    .pcie_mgt_0_rxp                         (pcie_mgt_0_rxp         ),
    .pcie_mgt_0_txn                         (pcie_mgt_0_txn         ),
    .pcie_mgt_0_txp                         (pcie_mgt_0_txp         ),
    .pcie_sys_clk_0                         (w_pcie_gt_clk          ),
    .pcie_sys_rst_n_0                       (pcie_sys_rst_n_0       ),//xdma resetn
    .user_lnk_up_0                          (user_lnk_up_0          ),
//    .usr_irq_ack_0                          (w_usr_irq_ack_0        ),
//    .usr_irq_req_0                          (w_usr_irq_req_0        ),
    .AXIS2AXI_clk0                          (w_clk_200Mhz           ),
    .AXIS2AXI_clk1                          (w_clk_200Mhz           ),
    .AXIS2AXI_rstn0                         (!w_clk_200Mhz_rst      ),
    .AXIS2AXI_rstn1                         (!w_clk_200Mhz_rst      ),
    .S_AXIS_DATA_0                          (w_mem_udp_axis_data    ),
    .S_AXIS_DATA_1                          (w_mem_8b10b_axis_data  ),
    .S_AXIS_KEEP_0                          (w_mem_udp_axis_keep    ),
    .S_AXIS_KEEP_1                          (w_mem_8b10b_axis_keep  ),
    .S_AXIS_LAST_0                          (w_mem_udp_axis_last    ),
    .S_AXIS_LAST_1                          (w_mem_8b10b_axis_last  ),
    .S_AXIS_USER_0                          (w_mem_udp_axis_user    ),
    .S_AXIS_USER_1                          (w_mem_8b10b_axis_user  ),
    .S_AXIS_VALID_0                         (w_mem_udp_axis_valid   ),
    .S_AXIS_VALID_1                         (w_mem_8b10b_axis_valid ),
    .i_clk_200MHz_0                         (w_clk_200Mhz           ),
    .i_rst_200MHz_0                         (w_clk_200Mhz_rst       )
);

rst_gen_module#(
    .P_RST_CYCLE    (100             )   
)
rst_gen_module_100Mhz_rst
(
    .i_clk          (w_clk_100Mhz       ),
    .i_rst          (0),
    .o_rst          (w_clk_100Mhz_rst   )
);

rst_gen_module#(
    .P_RST_CYCLE    (100             )   
)
rst_gen_module_200Mhz_rst
(
    .i_clk          (w_clk_200Mhz       ),
    .i_rst          (0),
    .o_rst          (w_clk_200Mhz_rst   )
);
//GT share logic
IBUFDS_GTE2 IBUFDS_GTE2_gtrefclk
(
    .O     (w_gt_refclk ),
    .ODIV2 (),
    .CEB   (1'b0),
    .I     (i_gt_refclk_p),
    .IB    (i_gt_refclk_n)
);

gtwizard_0_common#(
    .WRAPPER_SIM_GTRESET_SPEEDUP("TRUE"),
    .SIM_QPLLREFCLK_SEL         (3'b010)
)
common0_i
(
    .QPLLREFCLKSEL_IN           (3'b010             ),//1:参考时钟0；2：参考时钟1 3：北时钟 4：南时钟
    .GTREFCLK0_IN               (0                  ),
    .GTREFCLK1_IN               (w_gt_refclk        ),
    .QPLLLOCK_OUT               (w_qplllock         ),
    .QPLLLOCKDETCLK_IN          (w_clk_100Mhz       ),
    .QPLLOUTCLK_OUT             (w_qplloutclk       ),
    .QPLLOUTREFCLK_OUT          (w_qplloutrefclk    ),
    .QPLLREFCLKLOST_OUT         (w_qpllrefclklost   ),    
    .QPLLRESET_IN               (w_qpllreset_gt_phy        ) 
);

//************************* 10G UDP **********************************//
//************************* clock 156.25Mhz **************************//
//************************* data width 64bit *************************//
rst_gen_module#(
    .P_RST_CYCLE            (100        )   
)
rst_gen_module_xgmii_rst 
(
    .i_clk                  (w_xgmii_clk),
    .i_rst                  (~w_rst_done),
    .o_rst                  (w_xgmii_rst)
);

AXIS_Data_Buffer#(
    .P_DATA_WIDTH                           (64)   ,
    .P_KEEP_WIDTH                           (8 )   ,
    .P_USER_WIDTH                           (16)    
)AXIS_Data_Buffer_udp2mem(
    .i_pre_clk                              (w_xgmii_clk              ),
    .i_pre_rst                              (w_xgmii_rst || (!w_block_sync) ),
    .i_pre_axis_data                        (wm_udp_axis_user_data  ),
    .i_pre_axis_user                        (0),
    .i_pre_axis_keep                        (wm_udp_axis_user_keep  ),
    .i_pre_axis_last                        (wm_udp_axis_user_last  ),
    .i_pre_axis_valid                       (wm_udp_axis_user_valid ),
    .o_pre_axis_ready                       (), 

    .i_post_clk                             (w_clk_200Mhz           ),
    .i_post_rst                             (w_clk_200Mhz_rst       ),
    .o_post_axis_data                       (w_mem_udp_axis_data    ),
    .o_post_axis_user                       (w_mem_udp_axis_user    ),
    .o_post_axis_keep                       (w_mem_udp_axis_keep    ),
    .o_post_axis_last                       (w_mem_udp_axis_last    ),
    .o_post_axis_valid                      (w_mem_udp_axis_valid   ),
    .i_post_axis_ready                      (1) 
);

UDP_10G_Stack#(
    .P_SRC_MAC        (P_SRC_MAC                    ),
    .P_DST_MAC        (P_DST_MAC                    ),
    .P_SRC_IP_ADDR    ({8'd192,8'd168,8'd100,8'd100} ),
    .P_DST_IP_ADDR    ({8'd192,8'd168,8'd100,8'd100}),
    .P_SRC_UDP_PORT   (16'h8080                     ),
    .P_DST_UDP_PORT   (16'h8080                     )

)UDP_10G_Stack_u0(
    .i_xgmii_clk                (w_xgmii_clk        ),
    .i_xgmii_rst                (w_xgmii_rst || (!w_block_sync)),
    .i_xgmii_rxd                (w_xgmii_rxd        ),
    .i_xgmii_rxc                (w_xgmii_rxc        ),
    .o_xgmii_txd                (w_xgmii_txd        ),
    .o_xgmii_txc                (w_xgmii_txc        ),
    .i_dynamic_src_mac          (48'd0),
    .i_dynamic_src_mac_valid    (0),
    .i_dynamic_dst_mac          (48'd0),
    .i_dynamic_dst_mac_valid    (0),
    .i_dymanic_src_port         (0),
    .i_dymanic_src_port_valid   (0),
    .i_dymanic_dst_port         (0),
    .i_dymanic_dst_port_valid   (0),
    .i_dynamic_src_ip           (0),
    .i_dynamic_src_ip_valid     (0),
    .i_dynamic_dst_ip           (0),
    .i_dynamic_dst_ip_valid     (0),
    .i_arp_active               (0),
    .i_arp_active_dst_ip        (0),
    /****user data****/
    .m_axis_user_data           (wm_udp_axis_user_data      ),
    .m_axis_user_user           (wm_udp_axis_user_user      ),
    .m_axis_user_keep           (wm_udp_axis_user_keep      ),
    .m_axis_user_last           (wm_udp_axis_user_last      ),
    .m_axis_user_valid          (wm_udp_axis_user_valid     ),
    .s_axis_user_data           (ws_udp_axis_user_data      ),
    .s_axis_user_user           (ws_udp_axis_user_user      ),
    .s_axis_user_keep           (ws_udp_axis_user_keep      ),
    .s_axis_user_last           (ws_udp_axis_user_last      ),
    .s_axis_user_valid          (ws_udp_axis_user_valid     ),
    .s_axis_user_ready          (ws_udp_axis_user_ready     ) 

);

TEN_GIG_ETH_PCSPMA TEN_GIG_ETH_PCSPMA_u0(
    .i_gt_refclk            (w_gt_refclk        ),
    .i_sys_clk              (w_clk_100Mhz       ),
    .i_rst                  (0),
    .i_qplllock             (w_qplllock         ),
    .i_qplloutclk           (w_qplloutclk       ),
    .i_qplloutrefclk        (w_qplloutrefclk    ),
    .o_qpllreset            (w_qpllreset_10g_mac),
    .txp                    (o_gt_txp[0]        ),
    .txn                    (o_gt_txn[0]        ),
    .rxp                    (i_gt_rxp[0]        ),
    .rxn                    (i_gt_rxn[0]        ),
    .i_sim_speedup_control  (r_sim_ctrl         ),
    .o_xgmii_clk            (w_xgmii_clk        ),   
    .i_xgmii_txd            (w_xgmii_txd        ),
    .i_xgmii_txc            (w_xgmii_txc        ),
    .o_xgmii_rxd            (w_xgmii_rxd        ),
    .o_xgmii_rxc            (w_xgmii_rxc        ),
    .o_block_sync           (w_block_sync       ),
    .o_rst_done             (w_rst_done         ),
    .o_pma_link             (w_pma_link         ),
    .o_pcs_rx_link          (w_pcs_rx_link      ),
    .o_tx_disable           (w_tx_disable       ) 
);
always @(posedge w_xgmii_clk)begin
    if(!w_clk_100Mhz_rst)
        r_sim_ctrl <= 'd1;
end

//******************** GT 8B10B ***********************//
//******************** 257.8125Mhz ********************//
//******************** 32bit **************************//
rst_gen_module#(
    .P_RST_CYCLE    (100             )   
)
rst_gen_module_gttx_rst
(
    .i_clk          (w_tx0_clk       ),
    .i_rst          (0),
    .o_rst          (w_tx0_rst       )
);

rst_gen_module#(
    .P_RST_CYCLE    (100             )   
)
rst_gen_module_gtrx_rst
(
    .i_clk          (w_rx0_clk       ),
    .i_rst          (0),
    .o_rst          (w_rx0_rst       )
);

AXIS_Data_Buffer#(
    .P_DATA_WIDTH                           (64)   ,
    .P_KEEP_WIDTH                           (8 )   ,
    .P_USER_WIDTH                           (16)    
)AXIS_Data_Buffer_gtphy2mem(
    .i_pre_clk                              (w_rx0_clk              ),
    .i_pre_rst                              (w_rx0_rst              ),
    .i_pre_axis_data                        (w_8b10b_64b_axis_data  ),
    .i_pre_axis_user                        (0),
    .i_pre_axis_keep                        (w_8b10b_64b_axis_keep  ),
    .i_pre_axis_last                        (w_8b10b_64b_axis_last  ),
    .i_pre_axis_valid                       (w_8b10b_64b_axis_valid ),
    .o_pre_axis_ready                       (),

    .i_post_clk                             (w_clk_200Mhz           ),
    .i_post_rst                             (w_clk_200Mhz_rst       ),
    .o_post_axis_data                       (w_mem_8b10b_axis_data  ),
    .o_post_axis_user                       (w_mem_8b10b_axis_user  ),
    .o_post_axis_keep                       (w_mem_8b10b_axis_keep  ),
    .o_post_axis_last                       (w_mem_8b10b_axis_last  ),
    .o_post_axis_valid                      (w_mem_8b10b_axis_valid ),
    .i_post_axis_ready                      (1) 
);

GT8B10B_DW_32to64 GT8B10B_DW_32to64_u0(
    .i_clk                                  (w_rx0_clk              ),
    .i_rst                                  (w_rx0_rst              ),

    .i_8b10b_32b_axis_data                  (w_8b10b_rx_axis_data   ),
    .i_8b10b_32b_axis_keep                  (w_8b10b_rx_axis_keep   ),
    .i_8b10b_32b_axis_valid                 (w_8b10b_rx_axis_valid  ),
    .i_8b10b_32b_axis_last                  (w_8b10b_rx_axis_last   ),

    .o_8b10b_64b_axis_data                  (w_8b10b_64b_axis_data  ),
    .o_8b10b_64b_axis_keep                  (w_8b10b_64b_axis_keep  ),
    .o_8b10b_64b_axis_valid                 (w_8b10b_64b_axis_valid ),
    .o_8b10b_64b_axis_last                  (w_8b10b_64b_axis_last  ),
    .i_8b10b_64b_axis_ready                 (1 ) 
);

PHY_module PHY_module_u0(
    .i_tx_clk                               (w_tx0_clk              ),
    .i_tx_rst                               (w_tx0_rst              ),
    .i_rx_clk                               (w_rx0_clk              ),
    .i_rx_rst                               (w_rx0_rst              ),
    .i_tx_axis_data                         (w_8b10b_tx_axis_data   ),
    .i_tx_axis_keep                         (w_8b10b_tx_axis_keep   ),    
    .i_tx_axis_valid                        (w_8b10b_tx_axis_valid  ),
    .i_tx_axis_last                         (w_8b10b_tx_axis_last   ),
    .o_tx_axis_ready                        (w_8b10b_tx_axis_ready  ),
    .o_rx_axis_data                         (w_8b10b_rx_axis_data   ),
    .o_rx_axis_keep                         (w_8b10b_rx_axis_keep   ),    
    .o_rx_axis_valid                        (w_8b10b_rx_axis_valid  ),
    .o_rx_axis_last                         (w_8b10b_rx_axis_last   ),
    .i_rx_axis_ready                        (1),
    .i_gt_tx_done                           (w_tx0_done             ),
    .o_gt_tx_data                           (w_tx0_data             ),
    .o_gt_tx_char                           (w_tx0_char             ),
    .i_rx_ByteAlign                         (w_rx0_ByteAlign        ),
    .i_gt_rx_data                           (w_rx0_data             ),
    .i_gt_rx_char                           (w_rx0_char             )
);
      
gt_module gt_module_u0(
    .i_sysclk                               (w_clk_100Mhz       ),
    .i_qplllock                             (w_qplllock         ),
    .i_qpllrefclklost                       (w_qpllrefclklost   ),
    .o_qpllreset                            (w_qpllreset_gt_phy),
    .i_qplloutclk                           (w_qplloutclk       ),
    .i_qplloutrefclk                        (w_qplloutrefclk    ),
     
    .i_rx0_rst                              (1          ),
    .i_tx0_rst                              (1          ),
    .o_tx0_done                             (w_tx0_done         ),
    .o_rx0_done                             (w_rx0_done         ),
    .i_tx0_polarity                         (0),
    .i_tx0_diffctrl                         (4'b1100            ),
    .i_tx0postcursor                        (5'b00011           ),
    .i_tx0percursor                         (5'b00111           ),     
    .i_rx0_polarity                         (0),
    .i_loopback0                            (0),
    .i_0_drpaddr                            (0), 
    .i_0_drpclk                             (w_clk_100Mhz),
    .i_0_drpdi                              (0), 
    .o_0_drpdo                              (), 
    .i_0_drpen                              (0),
    .o_0_drprdy                             (), 
    .i_0_drpwe                              (0),
    .o_rx0_ByteAlign                        (w_rx0_ByteAlign    ),
    .o_rx0_clk                              (w_rx0_clk          ),
    .o_rx0_data                             (w_rx0_data         ),
    .o_rx0_char                             (w_rx0_char         ),
    .o_tx0_clk                              (w_tx0_clk          ),
    .i_tx0_data                             (w_tx0_data         ),
    .i_tx0_char                             (w_tx0_char         ),

    .o_gt_tx0_p                             (o_gt_txp[1]        ),
    .o_gt_tx0_n                             (o_gt_txn[1]        ),
    .i_gt_rx0_p                             (i_gt_rxp[1]        ),
    .i_gt_rx0_n                             (i_gt_rxn[1]        )
);


endmodule

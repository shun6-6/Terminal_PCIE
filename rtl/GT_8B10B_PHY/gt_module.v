`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/26 16:55:55
// Design Name: 
// Module Name: gt_module
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


module gt_module(
    input                   i_sysclk                    ,
    input                   i_qplllock                  ,
    input                   i_qpllrefclklost            ,
    output                  o_qpllreset                 ,
    input                   i_qplloutclk                ,
    input                   i_qplloutrefclk             ,

    input                   i_rx0_rst                   ,
    input                   i_tx0_rst                   ,
    output                  o_tx0_done                  ,
    output                  o_rx0_done                  ,
    input                   i_tx0_polarity              ,
    input  [3 :0]           i_tx0_diffctrl              ,
    input  [4 :0]           i_tx0postcursor             ,
    input  [4 :0]           i_tx0percursor              ,     
    input                   i_rx0_polarity              ,
    input  [2 :0]           i_loopback0                 ,
    input  [8 :0]           i_0_drpaddr                 , 
    input                   i_0_drpclk                  ,
    input  [15:0]           i_0_drpdi                   , 
    output [15:0]           o_0_drpdo                   , 
    input                   i_0_drpen                   ,
    output                  o_0_drprdy                  , 
    input                   i_0_drpwe                   ,
    output                  o_rx0_ByteAlign             ,
    output                  o_rx0_clk                   ,
    output [31:0]           o_rx0_data                  ,
    output [3 :0]           o_rx0_char                  ,
    output                  o_tx0_clk                   ,
    input  [31:0]           i_tx0_data                  ,
    input  [3 :0]           i_tx0_char                  ,


    output                  o_gt_tx0_p                  ,
    output                  o_gt_tx0_n                  ,
    input                   i_gt_rx0_p                  ,
    input                   i_gt_rx0_n                  
);

// wire    w_gtrefclk          ;


// assign w_gtrefclk   =   i_gtrefclk  ;
// wire    w_qplllock          ;
// wire    w_qpllrefclklost    ;
// wire    w_qpllreset         ;
// wire    w_qplloutclk        ;
// wire    w_qplloutrefclk     ;

// IBUFDS_GTE2 IBUFDS_GTE2_u0  
// (
//     .O               (w_gtrefclk    ),
//     .ODIV2           (),
//     .CEB             (0),
//     .I               (i_gtrefclk_p  ),
//     .IB              (i_gtrefclk_n  )
// );

// gtwizard_0_common #
// (
//     .WRAPPER_SIM_GTRESET_SPEEDUP(),
//     .SIM_QPLLREFCLK_SEL         (3'b010)
// )
// common0_i
// (
//     .QPLLREFCLKSEL_IN           (3'b010             ),//1:参考时钟0；2：参考时钟1 3：北时钟 4：南时钟
//     .GTREFCLK0_IN               (0                  ),
//     .GTREFCLK1_IN               (w_gtrefclk         ),
//     .QPLLLOCK_OUT               (w_qplllock         ),
//     .QPLLLOCKDETCLK_IN          (i_sysclk           ),
//     .QPLLOUTCLK_OUT             (w_qplloutclk       ),
//     .QPLLOUTREFCLK_OUT          (w_qplloutrefclk    ),
//     .QPLLREFCLKLOST_OUT         (w_qpllrefclklost   ),    
//     .QPLLRESET_IN               (w_qpllreset        ) 
// );

gt_channel gt_channel_u0(
    .i_sysclk                    (i_sysclk          ),
    //.i_gtrefclk                  (w_gtrefclk        ),
    .i_rx_rst                    (i_rx0_rst         ),
    .i_tx_rst                    (i_tx0_rst         ),
    .o_tx_done                   (o_tx0_done        ),
    .o_rx_done                   (o_rx0_done        ),
    .i_tx_polarity               (i_tx0_polarity    ),
    .i_tx_diffctrl               (i_tx0_diffctrl    ),
    .i_txpostcursor              (i_tx0postcursor   ),
    .i_txpercursor               (i_tx0percursor    ),     
    .i_rx_polarity               (i_rx0_polarity    ),
    .i_loopback                  (i_loopback0       ),
    .i_drpaddr                   (i_0_drpaddr       ), 
    .i_drpclk                    (i_0_drpclk        ),
    .i_drpdi                     (i_0_drpdi         ), 
    .o_drpdo                     (o_0_drpdo         ), 
    .i_drpen                     (i_0_drpen         ),
    .o_drprdy                    (o_0_drprdy        ), 
    .i_drpwe                     (i_0_drpwe         ),
    .i_qplllock                  (i_qplllock        ), 
    .i_qpllrefclklost            (i_qpllrefclklost  ), 
    .o_qpllreset                 (o_qpllreset       ),
    .i_qplloutclk                (i_qplloutclk      ), 
    .i_qplloutrefclk             (i_qplloutrefclk   ), 
    .o_rx_ByteAlign              (o_rx0_ByteAlign   ),
    .o_rx_clk                    (o_rx0_clk         ),
    .o_rx_data                   (o_rx0_data        ),
    .o_rx_char                   (o_rx0_char        ),
    .o_tx_clk                    (o_tx0_clk         ),
    .i_tx_data                   (i_tx0_data        ),
    .i_tx_char                   (i_tx0_char        ),

    .o_gt_tx_p                   (o_gt_tx0_p        ),
    .o_gt_tx_n                   (o_gt_tx0_n        ),
    .i_gt_rx_p                   (i_gt_rx0_p        ),
    .i_gt_rx_n                   (i_gt_rx0_n        )
);


endmodule

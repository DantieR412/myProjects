//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
//Date        : Tue Mar 10 15:10:46 2026
//Host        : DESKTOP-C55JFEV running 64-bit major release  (build 9200)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (Clk,
    LED,
    reset,
    usb_uart_rxd,
    usb_uart_txd);
  input Clk;
  output [15:0]LED;
  input reset;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire Clk;
  wire [15:0]LED;
  wire reset;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  system system_i
       (.Clk(Clk),
        .LED(LED),
        .reset(reset),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule

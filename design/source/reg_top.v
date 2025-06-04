`include "reg_rtl.v"
`include "reg_decoder.v"

module reg_top # (
  parameter REG_ADDR = 0,
  parameter W_WIDTH = 8
)(
  input clk, rst_n,
  input sel_en, wr_rd_s,
  input [W_WIDTH-1:0] addr, wr_data,

  output [W_WIDTH-1:0] rd_data,
  output [W_WIDTH-1:0] reg_data2port_out,
  output ack
);

  wire [7:0] reg_data2port_w;
  wire wr_en_w;

  reg_rtl # (
    .W_WIDTH(W_WIDTH)
  ) CONF_PORT_REG_DUT (
    .clk(clk), 
    .rst_n(rst_n), 
    .wr_en(wr_en_w), 
    .d(wr_data), 
    .q(reg_data2port_w)
  );

  reg_decoder # (
    .REG_ADDR(REG_ADDR),
    .W_WIDTH(W_WIDTH)
  ) DEC_REG_DUT (
    .clk(clk), 
    .rst_n(rst_n),
    .sel_en(sel_en),
    .wr_rd_s(wr_rd_s),
    .addr(addr),
    .reg_data2port_in(reg_data2port_w),
    .wr_en(wr_en_w),
    .rd_data(rd_data),
    .ack(ack)
  );

  assign reg_data2port_out = reg_data2port_w;
endmodule : reg_top

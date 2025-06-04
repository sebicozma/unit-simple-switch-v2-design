`include "fsm_top.v"
`include "fifo_module.v"


module port_top # (
  parameter FIFO_SIZE = 64,
  parameter W_WIDTH = 8 //WORD width
)(
  input clk, rst_n,
  //-----------------------INPUT if
  input sw_en,
  input [W_WIDTH-1:0] port_data, port_addr,
  output rd_out,
  //------------------------OUTPUT if
  input port_rd,
  output [W_WIDTH-1:0] port_out,
  output port_rdy
);  

  wire fifo_full_w, wr_en_w, ffe;

  fifo # (
    .FIFO_SIZE(FIFO_SIZE),
    .W_WIDTH(W_WIDTH)
  ) DUT_PORT_FIFO (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en_w),
    .rd_en(port_rd),
    .data_in(port_data),
    .data_out(port_out),
    .empty(port_rdy),
    .full(fifo_full_w)
  );

  fsm_top # (
    .W_WIDTH(W_WIDTH)
  ) DUT_PORT_FSM (
    .clk(clk),
    .rst_n(rst_n),
    .sw_en(sw_en),
    .port_busy(fifo_full_w),
    .port_addr(port_addr),
    .data_in(port_data),
    .wr_en(wr_en_w)
  );

  assign rd_out = !fifo_full_w;
endmodule : port_top
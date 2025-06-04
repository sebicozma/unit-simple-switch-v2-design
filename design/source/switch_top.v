// Code your design here
`include "port_top.v"
`include "reg_top.v"


module switch_top # (
  parameter NUM_OF_PORTS = 4,
  parameter FIFO_SIZE = 64,
  parameter WORD_WIDTH = 8
)(
  input clk, rst_n,

  input [WORD_WIDTH-1:0] data_in,
  input sw_enable_in,

  input [NUM_OF_PORTS-1:0] port_read,
  
  input mem_sel_en, mem_wr_rd_s,
  input [WORD_WIDTH-1:0] mem_addr,
  input [WORD_WIDTH-1:0] mem_wr_data, 

  output read_out,
  output [(NUM_OF_PORTS*WORD_WIDTH)-1:0] port_out,
  output [NUM_OF_PORTS-1:0] port_ready,
  output [WORD_WIDTH-1:0] mem_rd_data,
  output mem_ack
);

  wire [WORD_WIDTH-1:0] mem_reg2port [NUM_OF_PORTS-1:0];
  wire [NUM_OF_PORTS-1:0] rd_port2out;

  //============================================

  genvar i;
  generate 
    for(i = 1; i <= NUM_OF_PORTS; i = i + 1) begin
      reg_top # (
        .REG_ADDR(i-1),
        .W_WIDTH(WORD_WIDTH)
      ) DUT_REG (
        .clk(clk),
        .rst_n(rst_n),
        .sel_en(mem_sel_en),
        .wr_rd_s(mem_wr_rd_s),
        .addr(mem_addr),
        .wr_data(mem_wr_data),
        .rd_data(mem_rd_data),
        .ack(mem_ack),
        .reg_data2port_out(mem_reg2port[i-1])
      );


      port_top # (
        .FIFO_SIZE(FIFO_SIZE),
        .W_WIDTH(WORD_WIDTH)
      ) DUT_PORT (
        .clk(clk),
        .rst_n(rst_n),
        .sw_en(sw_enable_in),
        .port_data(data_in),
        .rd_out(rd_port2out[i-1]),
        .port_addr(mem_reg2port[i-1]),
        .port_out(port_out[(i*WORD_WIDTH)-1:(i*WORD_WIDTH-WORD_WIDTH)]),
        .port_rdy(port_ready[i-1]),
        .port_rd(port_read[i-1])
      );
    end
  endgenerate

  assign read_out = |rd_port2out;
endmodule : switch_top
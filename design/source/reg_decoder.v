module reg_decoder # (
  parameter REG_ADDR = 0,
  parameter W_WIDTH = 8
)(
  input clk, rst_n,
  input sel_en, wr_rd_s,
  input [W_WIDTH-1:0] addr,
  input [W_WIDTH-1:0] reg_data2port_in,
  
  output wr_en,
  output [W_WIDTH-1:0] rd_data,
  output ack
);

  reg ack_nxt, ack_ff;
  reg [7:0] rd_data_nxt, rd_data_ff;
  reg wr_en_nxt, wr_en_ff;

  //combinational
  always @(*) begin
    ack_nxt = ack_ff;
    rd_data_nxt = rd_data_ff;
    wr_en_nxt = wr_en_ff;

    if(sel_en && addr == REG_ADDR) begin
      if(wr_rd_s) begin
        wr_en_nxt = 1;
        ack_nxt = 1;
      end	
      else begin
        rd_data_nxt = reg_data2port_in;
        ack_nxt = 1;
      end	
    end
    else begin
      ack_nxt = 0;
      rd_data_nxt = 0;
      wr_en_nxt = 0;
    end	
  end	

  //sequential
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      ack_ff <= 0;
      rd_data_ff <= 0;
      wr_en_ff <= 0;
    end 
    else begin
      ack_ff <= ack_nxt;
      rd_data_ff <= rd_data_nxt;
      wr_en_ff <= wr_en_nxt;
    end 
  end 

  assign rd_data = rd_data_ff;
  assign ack = ack_ff;
  assign wr_en = wr_en_ff;

endmodule : reg_decoder

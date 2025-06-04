module reg_rtl #(
  parameter W_WIDTH = 8
)(
  input clk, rst_n, wr_en,
  input [W_WIDTH-1:0] d,
  output [W_WIDTH-1:0] q
);

  reg [W_WIDTH-1:0] reg_data;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
      reg_data <= 0;
    end 
    else if(wr_en) begin
      reg_data <= d;
    end 
  end 

  assign q = reg_data;
endmodule : reg_rtl
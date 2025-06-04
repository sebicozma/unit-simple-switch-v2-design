`include "fsm_wd_module.v"

module fsm # (
    parameter W_WIDTH = 8
)(
    input clk, rst_n,
    input sw_en, port_busy, wdog,
    input [W_WIDTH-1:0] port_addr,
    input [W_WIDTH-1:0] data_in,
    output wr_en, feed
);

    localparam IDLE_ST = 3;
    localparam ADDR_WAIT_ST = 0;
    localparam DATA_LOAD_ST = 1;
    localparam PARITY_LOAD_ST = 2;

    reg wr_en_ff, wr_en_nxt;
    reg [2:1] state_ff, state_nxt;
    reg feed_wd_ff, feed_wd_nxt;

    always @(posedge clk or rst_n) begin
        if(!rst_n) begin
            state_ff <= IDLE_ST;
            wr_en_ff <= 1'b0;
            feed_wd_ff <= 1'b0;
        end 
        else begin
            state_ff <= state_nxt;
            wr_en_ff <= wr_en_nxt;
            feed_wd_ff <= feed_wd_nxt;
        end 
    end

    always @( * ) begin
        state_nxt = state_ff;
        wr_en_nxt = wr_en_ff;
        feed_wd_nxt = feed_wd_ff;

        //the delimitation between the packets is done by releasing sw_en for one cock in between the packets, for consecutive packets
        //see about the port busy while ini the middle of the packet
        case(state_ff)
            IDLE_ST: begin
                if(!sw_en || port_busy) begin
                    state_nxt = IDLE_ST;
                end 
                else begin
                    state_nxt = ADDR_WAIT_ST;
                end 
            end

            ADDR_WAIT_ST : begin
                if(data_in == port_addr) begin
                    state_nxt = DATA_LOAD_ST;
                    wr_en_nxt = 1'b1;
                    feed_wd_nxt = 1'b0;
                end 
                else if(wdog) begin
                    state_nxt = IDLE_ST;
                    feed_wd_nxt = 1'b0;
                end
                else begin
                    state_nxt = ADDR_WAIT_ST;
                    feed_wd_nxt = 1'b1;
                end
            end 

            DATA_LOAD_ST : begin
                if(port_busy) begin
                    state_nxt = IDLE_ST;
                    wr_en_nxt = 1'b0;
                end 
                else if(!sw_en) begin // TODO there is a requirement for an additional last field for the parity 
                    state_nxt = PARITY_LOAD_ST;
                    wr_en_nxt = 1'b0;
                end 
                else begin
                    state_nxt = DATA_LOAD_ST;
                    wr_en_nxt = 1'b1;
                end 
            end 

            PARITY_LOAD_ST : begin
                if(!sw_en || port_busy) begin
                    state_nxt = IDLE_ST;
                end 
                else begin
                    state_nxt = ADDR_WAIT_ST;
                end 
            end
        endcase
    end

    assign wr_en = wr_en_ff;
    assign feed = feed_wd_ff;
endmodule : fsm
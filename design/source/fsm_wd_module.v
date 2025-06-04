module watchdog (
    input clk,      // Clock input
    input rst_n,      // Reset input
    input feed,     // Watchdog feed input
    output wdog // Watchdog output
);

    // Parameters
    parameter TIMEOUT = 100; // Timeout value (adjust as needed)

    // State machine states
    localparam IDLE = 2'b00;
    localparam ACTIVE = 2'b01;
    localparam TIMEOUT_STATE = 2'b10;

    // Internal counter
    reg [15:0] count_ff, count_nxt;
    reg wdog_s;

    // State machine variable
    reg [1:0] state_ff, state_nxt;

    always @(*) begin
        count_nxt = count_ff;
        state_nxt = state_ff;

        case (state_ff)
            IDLE: begin
                wdog_s = 0;
                state_nxt = (feed) ? ACTIVE : IDLE;
            end

            ACTIVE: begin
                if (count_ff == TIMEOUT) begin
                    state_nxt = TIMEOUT_STATE;
                    count_nxt = 0;
                end 
                else if (~feed) begin
                    state_nxt = IDLE;
                    count_nxt = 0;
                end
                else begin
                    count_nxt = count_nxt + 1;
                end 
            end

            TIMEOUT_STATE: begin
                wdog_s = 1;
                state_nxt = IDLE;
            end
        endcase
    end

    // Initializations
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_ff <= 0;
            state_ff <= IDLE;
        end 
        else begin
            count_ff <= count_nxt;
            state_ff <= state_nxt; 
        end
    end

    assign wdog = wdog_s;
endmodule : watchdog

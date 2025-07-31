    module Baud_Generator #(
        parameter CLK_FREQ  = 50_000_000,  // 50 MHz
        parameter BAUD_RATE = 9_600        // 9 600 baud
    )(
        input  wire clk,
        input  wire reset,     // synchronous or async, as you prefer
        output wire TX_TICK,   // single‐cycle pulse @ BAUD_RATE
        output wire RX_TICK    // single‐cycle pulse @ 16× BAUD_RATE
    );

        // Calculate divisors
        localparam integer TX_DIV = CLK_FREQ / BAUD_RATE;
        localparam integer RX_DIV = TX_DIV / 16;

        // Counters and tick regs
        reg [15:0] tx_cnt;
        reg [15:0] rx_cnt;
        reg        tx_tick_reg;
        reg        rx_tick_reg;

        // TX‐tick generator: one‐cycle pulse every TX_DIV clocks
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                tx_cnt      <= 0;
                tx_tick_reg <= 0;
            end
            else if (tx_cnt == TX_DIV-1) begin
                tx_cnt      <= 0;
                tx_tick_reg <= 1;
            end
            else begin
                tx_cnt      <= tx_cnt + 1;
                tx_tick_reg <= 0;
            end
        end

        // RX‐tick generator: one‐cycle pulse every RX_DIV clocks (16× oversample)
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                rx_cnt      <= 0;
                rx_tick_reg <= 0;
            end
            else if (rx_cnt == RX_DIV-1) begin
                rx_cnt      <= 0;
                rx_tick_reg <= 1;
            end
            else begin
                rx_cnt      <= rx_cnt + 1;
                rx_tick_reg <= 0;
            end
        end

        assign TX_TICK = tx_tick_reg;
        assign RX_TICK = rx_tick_reg;

    endmodule

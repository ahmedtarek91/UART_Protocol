module uart_Rx #(
    parameter DATA_BITS = 8
) (
    input clk,
    input reset,
    input RxD,
    output [DATA_BITS-1:0] RxData,
    output valid_rx, Parity_error, Stop_error
);
    // State Encoding
    localparam IDLE = 2'b00;
    localparam DATA = 2'b01;
    localparam PARITY_BIT = 2'b10;
    localparam STOP_BIT = 2'b11;

    reg [1:0] state, next_state;
    reg [DATA_BITS-1:0] data_shift, next_data_shift;
    reg [DATA_BITS-1:0] data_reg, next_data_reg;
    reg [3:0] bit_counter, next_bit_counter;
    reg [4:0] tick_counter, next_tick_counter;
    reg parity_bit, next_parity_bit;
    reg stop_bit, next_stop_bit;
    reg valid_reg, next_valid_reg;
    reg parity_err_reg, next_parity_err_reg;
    reg stop_err_reg, next_stop_err_reg;

    // State memory
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            data_shift <= 0;
            data_reg <= 0;
            bit_counter <= 0;
            tick_counter <= 0;
            parity_bit <= 0;
            stop_bit <= 0;
            valid_reg <= 0;
            parity_err_reg <= 0;
            stop_err_reg <= 0;
        end 
        else begin
            state <= next_state;
            data_shift <= next_data_shift;
            data_reg <= next_data_reg;
            bit_counter <= next_bit_counter;
            tick_counter <= next_tick_counter;
            parity_bit <= next_parity_bit;
            stop_bit <= next_stop_bit;
            valid_reg <= next_valid_reg;
            parity_err_reg <= next_parity_err_reg;
            stop_err_reg <= next_stop_err_reg;
        end
    end

    // Next state logic
    always @(*) begin
        // Default: hold values
        next_state = state;
        next_data_shift = data_shift;
        next_data_reg = data_reg;
        next_bit_counter = bit_counter;
        next_tick_counter = tick_counter;
        next_parity_bit = parity_bit;
        next_stop_bit = stop_bit;
        next_valid_reg = valid_reg;
        next_parity_err_reg = parity_err_reg;
        next_stop_err_reg = stop_err_reg;

        case (state)
            IDLE: begin
                if (RxD == 0) begin
                    next_tick_counter = tick_counter + 1;
                    if (tick_counter == 0) begin
                        // Clear flags on new frame
                        next_valid_reg = 0;
                        next_parity_err_reg = 0;
                        next_stop_err_reg = 0;
                    end
                    if (tick_counter == 7 && RxD) // False start
                        next_tick_counter = 0;
                    else if (tick_counter == 15) begin
                        next_state = DATA;
                        next_tick_counter = 0;
                        next_bit_counter = 0;
                        next_data_shift = 0;
                    end
                end
                else next_tick_counter = 0;
            end

            DATA: begin
                next_tick_counter = (tick_counter == 15) ? 0 : tick_counter + 1;
                
                if (tick_counter == 7)
                    next_data_shift = {RxD, data_shift[DATA_BITS-1:1]};
                    
                if (tick_counter == 15) begin
                    if (bit_counter == DATA_BITS-1) begin
                        next_state = PARITY_BIT;
                        next_data_reg = data_shift;
                    end
                    else next_bit_counter = bit_counter + 1;
                end
            end

            PARITY_BIT: begin
                next_tick_counter = (tick_counter == 15) ? 0 : tick_counter + 1;
                
                if (tick_counter == 7)
                    next_parity_bit = RxD;
                    
                if (tick_counter == 15) begin
                    if ((^data_reg) == parity_bit) 
                        next_state = STOP_BIT;
                    else begin
                        next_state = IDLE;
                        next_parity_err_reg = 1;
                    end
                end
            end

            STOP_BIT: begin
                next_tick_counter = (tick_counter == 15) ? 0 : tick_counter + 1;
                
                if (tick_counter == 7)
                    next_stop_bit = RxD;
                    
                if (tick_counter == 15) begin
                    next_state = IDLE;
                    next_valid_reg = (stop_bit == 1'b1);
                    next_stop_err_reg = (stop_bit != 1'b1);
                end
            end
        endcase
    end

    // Output logic
    assign RxData = data_reg;
    assign valid_rx = valid_reg;
    assign Parity_error = parity_err_reg;
    assign Stop_error = stop_err_reg;
endmodule
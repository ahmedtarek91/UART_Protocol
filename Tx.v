module uart_Tx #(
    parameter DATA_BITS = 8
)(
    input clk,
    input reset,
    input transmit, // Start transmission
    input [7:0] TxData, // Parallel data input
    output TxD, // UART TX line
    output busy // Transmitter busy flag
);

    // State Encoding
    localparam IDLE       = 3'b000;
    localparam START_BIT  = 3'b001;
    localparam DATA_BIT   = 3'b010;
    localparam PARITY_BIT = 3'b011;
    localparam STOP_BIT   = 3'b100;

    reg [2:0] state, next_state;
    reg [2:0] Bit_Counter, next_Bit_Counter;
    reg [7:0] shift_reg, next_shift_reg;
    reg       parity_bit, next_parity_bit;

    //State memory 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            Bit_Counter <= 0;
            shift_reg <= 0;
            parity_bit<= 0;
        end 
        else begin
            state <= next_state;
            Bit_Counter <= next_Bit_Counter;
            shift_reg <= next_shift_reg;
            parity_bit <= next_parity_bit;
        end
    end

    //Next state logic
    always @(*) begin
        case (state)
            IDLE: begin 
                if (transmit) begin
                    next_state = START_BIT;
                    next_shift_reg = TxData;
                    next_parity_bit = ^TxData;
                    next_Bit_Counter = 0;
                end
                else
                    next_state = IDLE;
            end

            START_BIT:  next_state = DATA_BIT;

            DATA_BIT: begin 
                if (Bit_Counter == DATA_BITS-1) begin
                    next_state = PARITY_BIT;
                    next_Bit_Counter = 0;
                end
                else begin
                    next_state = DATA_BIT;
                    next_Bit_Counter = next_Bit_Counter + 1;
                end
            end

            PARITY_BIT: next_state = STOP_BIT;

            STOP_BIT:   next_state = IDLE;

            default:    next_state = IDLE;
        endcase
    end

    //output logic
    assign TxD = (state == START_BIT)  ? 1'b0 :
                 (state == DATA_BIT)   ? shift_reg[Bit_Counter] :
                 (state == PARITY_BIT) ? parity_bit : 
                                         1'b1;    // IDLE & STOP_BIT default high

    assign busy = (state != IDLE);

endmodule


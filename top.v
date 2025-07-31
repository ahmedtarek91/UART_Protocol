module top #(
    parameter DATA_BITS = 8,
    parameter CLK_FREQ = 50_000_000,  // Default 50MHz clock
    parameter BAUD_RATE = 9600
) (
    input clk,
    input reset,

    //Transmitter
    input transmit, // Start transmission
    input [DATA_BITS-1:0] TxData, // Parallel data input
    output busy, // Transmitter busy flag

    //Receiver
    output [DATA_BITS-1:0] RxData,
    output valid_rx, 
    output Parity_error, 
    output Stop_error
);
    wire RxD; // Internal wire
    wire TX_TICK, RX_TICK; // Baud generator clocks
    
    // UART Transmitter instantiation
    uart_Tx #(.DATA_BITS(DATA_BITS)) Transmitter (
        .clk(TX_TICK),
        .reset(reset),
        .transmit(transmit),
        .TxData(TxData),
        .TxD(RxD),  // Connected to internal wire
        .busy(busy)
    );

    // UART Receiver instantiation
    uart_Rx #(.DATA_BITS(DATA_BITS)) Receiver (
        .clk(RX_TICK),
        .reset(reset),
        .RxD(RxD),  // Connected to internal wire
        .RxData(RxData),
        .valid_rx(valid_rx),
        .Parity_error(Parity_error),
        .Stop_error(Stop_error)
    );

    // Baud_Generator instantiation
    Baud_Generator #(
        .CLK_FREQ(CLK_FREQ), 
        .BAUD_RATE(BAUD_RATE)
    ) Baud_Gen (
        .clk(clk),
        .reset(reset),
        .TX_TICK(TX_TICK),
        .RX_TICK(RX_TICK)
    );

endmodule

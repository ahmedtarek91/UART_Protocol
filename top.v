module top #(
    parameter DATA_BITS = 8,
    parameter CLK_FREQ = 50_000_000,  // Default 50MHz clock
    parameter BAUD_RATE = 9600
) (
    input clk,
    input reset,

    //Transmitter
    input transmit, // Start transmission
    input [7:0] TxData, // Parallel data input
    output TxD, // UART TX line
    output busy, // Transmitter busy flag

    //Receiver
    input RxD,
    output [DATA_BITS-1:0] RxData,
    output valid_rx, Parity_error, Stop_error,

    //Baud_Gen
    output wire TX_TICK, // Output tick at desired baud rate
    output wire RX_TICK    // 16x oversampling clock (for receiver)
);
    
    // UART Transmitter instantiation
    uart_Tx #( .DATA_BITS(DATA_BITS)) Transmitter (
        .clk(TX_TICK),
        .reset(reset),
        .transmit(transmit),
        .TxData(TxData),
        .TxD(TxD),
        .busy(busy)
    );

    // UART Receiver instantiation
    uart_Rx #( .DATA_BITS(DATA_BITS)) Receiver (
        .clk(RX_TICK),
        .reset(reset),
        .RxD(RxD),
        .RxData(RxData),
        .valid_rx(valid_rx),
        .Parity_error(Parity_error),
        .Stop_error(Stop_error),
    );

    // Baud_Generator instantiation
    Baud_Generator #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE))
    Baud_Gen (
        .clk(clk),
        .reset(reset),
        .RX_TICK(RX_TICK),
        .TX_TICK(TX_TICK)
    )

endmodule
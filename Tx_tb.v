module uart_Tx_tb ();

    reg clk,reset, transmit;
    reg [7:0] TxData;
    wire TxD, busy;

    uart_Tx #(.DATA_BITS(8)) DUT (
        .clk(clk),
        .reset(reset),
        .transmit(transmit),
        .TxData(TxData),
        .TxD(TxD),
        .busy(busy)
    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin 
        $monitor("Time: %0t, TxD: %b, busy: %b", $time, TxD, busy);
    end

    integer i;

    initial begin 
        reset = 1;
        transmit = 1;
        TxData = 8'b10101010;
        @(negedge clk);
        // Check reset functionality 
        //state should be IDLE, TxD should be high, and busy should be low
        if (TxD != 1'b1 || busy != 1'b0) begin
            $display("ERROR: Reset is corrupted!");
            $stop;
        end
        reset = 0;
        for (i = 0; i < 10; i = i + 1) begin
            transmit = 1;
            TxData = $random;
            repeat (12) @(negedge clk);
        end
    $stop;
    end
endmodule
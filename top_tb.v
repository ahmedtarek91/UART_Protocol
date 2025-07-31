module top_tb ();

 // Parameters
    parameter DATA_BITS = 8;
    parameter CLK_FREQ = 50_000_000;
    parameter BAUD_RATE = 9600;
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ; // in ns
    

    reg clk, reset, transmit;
    reg [7:0] TxData;
    wire busy;
    wire [7:0] RxData;
    wire valid_rx, Parity_error, Stop_error;

    // Instantiate top module as DUT
    top #(
        .DATA_BITS(DATA_BITS),
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .transmit(transmit),
        .TxData(TxData),
        .busy(busy),
        .RxData(RxData),
        .valid_rx(valid_rx),
        .Parity_error(Parity_error),
        .Stop_error(Stop_error)
    );
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk; // 50MHz clock: period = 20ns (toggle every 10ns)
    end

    initial begin 
        $monitor("Time: %0t, TxD: %b, RxData: %h, valid_rx: %b, Parity_error: %b, Stop_error: %b", 
                 $time, DUT.Transmitter.TxD, RxData, valid_rx, Parity_error, Stop_error);
    end

    integer i;
    initial begin 
        // Initialize
        reset = 1;
        transmit = 0;
        TxData = 0;
        repeat(10) @(negedge clk);

        reset = 0;
        repeat(20) @(negedge clk);

       // 10 Random data tests
        for (i = 0; i < 10; i = i + 1) begin

            // Send random data
            TxData = $random;
            transmit = 1;
            @(posedge DUT.busy);
            transmit = 0;
            
            // Wait for reception
            wait (valid_rx);
            
            // Check result
            if (RxData == TxData) begin
                $display(" PASS: Received 0x%h", RxData);
            end else begin
                $display(" FAIL: Expected 0x%h, got 0x%h", TxData, RxData);
            end
            repeat (10) @(negedge clk);
        end
        
        $display("Test completed");
        $stop;
    end

endmodule

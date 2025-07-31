module uart_Rx_tb ();
    
    reg clk, reset, RxD;
    wire [7:0] RxData;
    wire valid_rx, Parity_error, Stop_error;
    localparam IDLE = 2'b00;

    // Instantiate uart_Rx as DUT
    uart_Rx DUT (
        .clk(clk),
        .reset(reset),
        .RxD(RxD),
        .RxData(RxData),
        .valid_rx(valid_rx),
        .Parity_error(Parity_error),
        .Stop_error(Stop_error)
    );

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    initial begin 
        $monitor("Time: %0t, RxD: %b, RxData: %h, valid_rx: %b, Parity_error: %b, Stop_error: %b", 
                 $time, RxD, RxData, valid_rx, Parity_error, Stop_error);
    end
    
    integer i = 0;

    initial begin
        
        // Check reset functionality
        reset = 1;
        RxD = 0;
        repeat (16) @(negedge clk);
        
        if (DUT.state != IDLE) begin 
            $display("ERROR: Reset is corrupted!");
            $stop;
        end

        reset = 0;
        RxD = 1; // Idle state
        repeat (32) @(negedge clk);

        // Test 1: Check Stop_error (send frame with stop bit = 0)
        $display("Test 1: Stop Error Test");
        for (i = 0; i < 3; i = i + 1) begin
            RxD = 0;                        //start bit
            repeat (16) @(negedge clk); 
            // Send data 10101010 (0xAA) - LSB first
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 0;                        // parity bit (correct for even parity)
            repeat (16) @(negedge clk); 
            RxD = 0;                        // stop bit (ERROR - should be 1)
            repeat (16) @(negedge clk);
            
            // Wait
            repeat (8) @(negedge clk);
            
            if (Stop_error != 1) begin
                $display("ERROR: Stop error flag not set when stop bit is 0!");
            end else begin
                $display("Stop error correctly detected");
            end
            
            // Return to idle
            RxD = 1;
            repeat (32) @(negedge clk);
        end

        // Test 2: Check Parity_error
        $display("\n=== Test 2: Parity Error Test ===");
        for (i = 0; i < 3; i = i + 1) begin
            RxD = 0;                        //start bit
            repeat (16) @(negedge clk); 
            // Send data 10101010 (0xAA) - LSB first
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 1;                        // parity bit (ERROR - should be 0)
            repeat (16) @(negedge clk); 
            
            // Wait for receiver to process and return to IDLE
            repeat (8) @(negedge clk);
            
            if (Parity_error != 1) begin
                $display("ERROR: Parity error flag not set when parity is wrong!");
            end else begin
                $display("Parity error correctly detected");
            end
            
            // Return to idle
            RxD = 1;
            repeat (32) @(negedge clk);
        end

        // Test 3: Check valid frame
        $display("\n=== Test 3: Valid Frame Test ===");
        for (i = 0; i < 3; i = i + 1) begin
            RxD = 0;                        //start bit
            repeat (16) @(negedge clk); 
            // Send data 10001010 (0x8A) - LSB first
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 0;
            repeat (16) @(negedge clk);
            RxD = 0;
            repeat (16) @(negedge clk); 
            RxD = 1;
            repeat (16) @(negedge clk);
            RxD = 1;                        // parity bit (correct)
            repeat (16) @(negedge clk); 
            RxD = 1;                        // stop bit (correct)
            repeat (16) @(negedge clk);
            
            // Wait for receiver to process
            repeat (8) @(negedge clk);
            
            if (valid_rx != 1) begin
                $display("ERROR: valid_rx not set for valid frame!");
            end else begin
                $display("Valid frame received successfully!");
            end
            
            if (RxData != 8'h8A) begin
                $display("ERROR: Received data %h doesn't match expected 0x8A", RxData);
            end
            
            // Return to idle
            RxD = 1;
            repeat (32) @(negedge clk);
        end
        
        $display("All tests completed");
        $stop;
    end
endmodule

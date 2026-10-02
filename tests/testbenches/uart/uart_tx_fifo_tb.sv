/**
 * @file uart_tx_fifo_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the uart_tx_fifo module
 */

module uart_tx_fifo_tb #(
    parameter int CLOCK_PERIOD=100,
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int FIFO_SIZE=8,

    localparam int OVERSAMPLING=6
) ();
    // inputs
    logic clk;
    logic rst;
    logic write;
    logic [DATA_BITS-1:0] data;
    
    // outputs
    logic uart_tx;
    logic full;

    uart_tx_fifo #(
        .CLOCK_SPEED(BAUD_RATE*OVERSAMPLING),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .FIFO_SIZE(FIFO_SIZE)
    ) dut (
        .clk,
        .rst,
        .write,
        .data,
    
        .uart_tx,
        .full
    );
    
    int cycle = 0;
    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
            if (clk) cycle = cycle + 1;
        end  // forever
    end  // initial

    bit [DATA_BITS-1:0] random_bits [0:7];
    bit [DATA_BITS-1:0] dropped_bits;
    initial begin
        $urandom('hCAFEBABE);
        $dumpfile("waveforms/uart_tx_fifo_tb.vcd");
        $dumpvars;
        rst = 1;
        write = 0;
        data = 0;
        @(posedge clk); #5;
        rst = 0;

        $display(" -- Testing idle state -- ");
        repeat(100) begin
            assert(uart_tx);
            assert(~full);
            @(posedge clk); #5;
        end

        $display(" -- Single Pre-defined '0 Frame -- ");
        write = 1;
        data = '0;
        @(posedge clk); #5;
        assert(~full);
        @(posedge clk); #5;
        repeat(OVERSAMPLING) begin
            assert(~full);
            assert(~uart_tx);
            @(posedge clk); #5;
        end

        // // frame added to FIFO
        // @(negedge empty); #5;
        // assert(out == 0);

        // // read from FIFO
        // read = 1;
        // @(posedge clk) #5;
        // read = 0;
        // assert(empty);

        // $display(" -- Sinlge Pre-defined '1 Frame -- ");
        // uart_rx = 0;  // start bit
        // repeat(OVERSAMPLING) begin
        //     @(posedge clk); #5;
        // end
        // uart_rx = 1;  // data bits
        // repeat(DATA_BITS) begin
        //     repeat(OVERSAMPLING) begin
        //         @(posedge clk); #5;
        //     end
        // end
        // uart_rx = 1;  // stop bit

        // // frame added to FIFO
        // @(negedge empty); #5;
        // assert(out == '1);
        // @(posedge clk); #5;

        // read = 1;
        // @(posedge clk); #5;
        // read = 0;
        // assert(empty);

        // $display(" -- FIFO_SIZE Pre-defined Random Frames -- ");
        // for (int j = 0; j < FIFO_SIZE; j++) begin
        //     uart_rx = 0;  // start bit
        //     repeat(OVERSAMPLING) begin
        //         @(posedge clk); #5;
        //     end
        //     // generate random bit and send
        //     for (int i = 0; i < DATA_BITS; i++) begin
        //         random_bits[j][i] = 1'($urandom()); 
        //         uart_rx = random_bits[j][i];  // data bits
        //         repeat(OVERSAMPLING) begin
        //             @(posedge clk); #5;
        //         end
        //     end
        //     uart_rx = 1;  // stop bit
        //     $display("TX: %b", random_bits[j]);
        //     repeat(OVERSAMPLING) begin
        //         @(posedge clk); #5;
        //     end
        // end

        // for (int j = 0; j < FIFO_SIZE; j++) begin
        //     assert(~empty);
        //     $display("RX: %b", out);
        //     assert(out == random_bits[j]);
        //     read = 1;
        //     @(posedge clk); #5;
        // end
        // read = 0;
        // assert(empty);

        // $display(" -- FIFO_SIZE*2 Pre-defined Random Frames -- ");
        // $display("Should drop frames after FIFO_SIZE");
        // for (int j = 0; j < FIFO_SIZE; j++) begin
        //     uart_rx = 0;  // start bit
        //     repeat(OVERSAMPLING) begin
        //         @(posedge clk); #5;
        //     end
        //     // generate random bit and send
        //     for (int i = 0; i < DATA_BITS; i++) begin
        //         random_bits[j][i] = 1'($urandom()); 
        //         uart_rx = random_bits[j][i];  // data bits
        //         repeat(OVERSAMPLING) begin
        //             @(posedge clk); #5;
        //         end
        //     end
        //     uart_rx = 1;  // stop bit
        //     $display("TX: %b", random_bits[j]);
        //     repeat(OVERSAMPLING) begin
        //         @(posedge clk); #5;
        //     end
        // end
        // // these should be dropped
        // for (int j = 0; j < FIFO_SIZE; j++) begin
        //     uart_rx = 0;  // start bit
        //     repeat(OVERSAMPLING) begin
        //         @(posedge clk); #5;
        //     end
        //     // generate random bit and send
        //     for (int i = 0; i < DATA_BITS; i++) begin
        //         dropped_bits[i] = 1'($urandom());
        //         uart_rx = dropped_bits[i];  // data bits
        //         repeat(OVERSAMPLING) begin
        //             @(posedge clk); #5;
        //         end
        //     end
        //     uart_rx = 1;  // stop bit
        //     $display("Dropped: %b", dropped_bits);
        //     repeat(OVERSAMPLING) begin
        //         @(posedge clk); #5;
        //     end
        // end

        // for (int j = 0; j < FIFO_SIZE; j++) begin
        //     assert(~empty);
        //     $display("RX: %b", out);
        //     assert(out == random_bits[j]);
        //     read = 1;
        //     @(posedge clk); #5;
        // end
        // read = 0;
        // assert(empty);

        $finish;
    end  // initial

endmodule  // uart_tx_fifo_tb

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
    parameter int STOP_BITS=1,

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
        .FIFO_SIZE(FIFO_SIZE),
        .STOP_BITS(STOP_BITS)
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
        write = 0;
        assert(~full);
        @(posedge clk); #5;
        // start bit
        repeat(OVERSAMPLING) begin
            assert(~full);
            assert(~uart_tx);
            @(posedge clk); #5;
        end
        // data bits
        repeat (DATA_BITS) begin
            repeat(OVERSAMPLING) begin
                assert(~full);
                assert(~uart_tx);
                @(posedge clk); #5;
            end
        end
        // stop bits
        repeat (STOP_BITS) begin
            repeat(OVERSAMPLING) begin
                assert(~full);
                assert(uart_tx);
                @(posedge clk); #5;
            end
        end

        $display(" -- Single Pre-defined '1 Frame -- ");
        write = 1;
        data = '1;
        @(posedge clk); #5;
        write = 0;
        assert(~full);
        @(posedge clk); #5;
        // start bit
        repeat(OVERSAMPLING) begin
            assert(~full);
            assert(~uart_tx);
            @(posedge clk); #5;
        end
        // data bits
        repeat (DATA_BITS) begin
            repeat(OVERSAMPLING) begin
                assert(~full);
                assert(uart_tx);
                @(posedge clk); #5;
            end
        end
        // stop bits
        repeat (STOP_BITS) begin
            repeat(OVERSAMPLING) begin
                assert(~full);
                assert(uart_tx);
                @(posedge clk); #5;
            end
        end

        $display(" -- Testing FIFO size -- ");
        write = 1;
        for (int j = 0; j < FIFO_SIZE+1; j++) begin
            data = '1;
            assert(~full);
            @(posedge clk); #5;
        end
        write = 0;
        assert(full);
        @(negedge full);

        $finish;
    end  // initial

endmodule  // uart_tx_fifo_tb

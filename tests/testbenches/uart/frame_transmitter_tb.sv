/**
 * @file frame_transmitter_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the frame_transmitter module
 */

module frame_transmitter_tb #(
    parameter int CLOCK_PERIOD=100,
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int STOP_BITS=1,

    localparam int OVERSAMPLING=6
) ();
    // inputs
    logic clk;
    logic rst;
    logic send;
    logic [DATA_BITS-1:0] data;
    
    // outputs
    logic ready;
    logic uart_tx;

    frame_transmitter #(
        .CLOCK_SPEED(BAUD_RATE*OVERSAMPLING),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS)
    ) dut (
        .clk,
        .rst,
        .send,
        .data,

        .ready,
        .uart_tx
    );
    
    int cycle = 0;
    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
            if (clk) cycle = cycle + 1;
        end  // forever
    end  // initial

    bit [DATA_BITS-1:0] random_bits;
    initial begin
        $urandom('hCAFEBABE);
        $dumpfile("waveforms/frame_transmitter_tb.vcd");
        $dumpvars;
        rst = 1;
        send = 0;
        data = '0;
        @(posedge clk); #5;
        rst = 0;

        $display(" -- Testing idle state -- ");
        repeat(100) begin
            assert(ready);
            assert(uart_tx);
            @(posedge clk); #5;
        end

        $display(" -- Transmitting '0 Frame -- ");
        send = 1;
        data = '0;
        @(posedge clk); #5;
        send = 0;
        // start bit
        repeat(OVERSAMPLING) begin
            assert(~ready);
            assert(~uart_tx);
            @(posedge clk); #5;
        end
        // data bits
        repeat(DATA_BITS) begin
            repeat(OVERSAMPLING) begin
                assert(~ready);
                assert(~uart_tx);
                @(posedge clk); #5;
            end
        end
        // stop bits
        repeat(STOP_BITS) begin
            repeat(OVERSAMPLING) begin
                assert(~ready);
                assert(uart_tx);
                @(posedge clk); #5;
            end
        end

        $display(" -- Transmitting '1 Frame -- ");
        send = 1;
        data = '1;
        @(posedge clk); #5;
        send = 0;
        // start bit
        repeat(OVERSAMPLING) begin
            assert(~ready);
            assert(~uart_tx);
            @(posedge clk); #5;
        end
        // data bits
        repeat(DATA_BITS) begin
            repeat(OVERSAMPLING) begin
                assert(~ready);
                assert(uart_tx);
                @(posedge clk); #5;
            end
        end
        // stop bits
        repeat(STOP_BITS) begin
            repeat(OVERSAMPLING) begin
                assert(~ready);
                assert(uart_tx);
                @(posedge clk); #5;
            end
        end

        $display(" -- Transmitting 10 Random Frames -- ");
        repeat(10) begin
            random_bits = (DATA_BITS)'($urandom());
            data = random_bits;
            $display("Sending: %b", data);
            send = 1;
            @(posedge clk); #5;
            send = 0;

            // start bit
            repeat(OVERSAMPLING) begin
                assert(~ready);
                assert(~uart_tx);
                @(posedge clk); #5;
            end
            // data bits
            for (int i = 0; i < DATA_BITS; i++) begin
                repeat(OVERSAMPLING) begin
                    assert(~ready);
                    assert(random_bits[i] == uart_tx);
                    @(posedge clk); #5;
                end
            end
            // stop bits
            repeat(STOP_BITS) begin
                repeat(OVERSAMPLING) begin
                    assert(~ready);
                    assert(uart_tx);
                    @(posedge clk); #5;
                end
            end
            assert(ready);
        end
        
        $display(" -- Testing idle state -- ");
        repeat(100) begin
            assert(ready);
            assert(uart_tx);
            @(posedge clk); #5;
        end
        $finish;
    end  // initial

endmodule  // frame_transmitter_tb

/**
 * @file frame_detector_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the frame_detector module
 */

module frame_detector_tb #(
    parameter int CLOCK_PERIOD=100,
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,

    localparam int OVERSAMPLING=6
) ();
    // inputs
    logic clk;
    logic rst;
    logic uart_rx;
    
    // outputs
    logic valid;
    logic [DATA_BITS-1:0] data;

    frame_detector #(
        .CLOCK_SPEED(BAUD_RATE*OVERSAMPLING),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS)
    ) dut (
        .clk,
        .rst,
        .uart_rx,

        .valid,
        .data
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
        $dumpfile("waveforms/frame_detector_tb.vcd");
        $dumpvars;
        rst = 1;
        uart_rx = 1;
        @(posedge clk); #5;
        rst = 0;

        $display(" -- Testing idle state -- ");
        repeat(100) begin
            assert(~valid);
            @(posedge clk); #5;
        end

        $display(" -- Testing Pre-defined '0 Frame -- ");
        uart_rx = 0;  // start bit
        repeat(OVERSAMPLING) begin
            @(posedge clk); #5;
        end
        uart_rx = 0;  // data bits
        repeat(DATA_BITS) begin
            repeat(OVERSAMPLING) begin
                @(posedge clk); #5;
            end
        end
        uart_rx = 1;  // stop bit
        @(posedge valid);
        assert(data == '0);
        @(posedge clk); #5;
        repeat(100) begin
            assert(~valid);
            @(posedge clk); #5;
        end

        $display(" -- Testing Pre-defined '1 Frame -- ");
        uart_rx = 0;  // start bit
        repeat(OVERSAMPLING) begin
            @(posedge clk); #5;
        end
        uart_rx = 1;  // data bits
        repeat(DATA_BITS) begin
            repeat(OVERSAMPLING) begin
                @(posedge clk); #5;
            end
        end
        uart_rx = 1;  // stop bit
        @(posedge valid); #5;
        assert(data == '1);
        @(posedge clk); #5;
        repeat(100) begin
            assert(~valid);
            @(posedge clk); #5;
        end

        $display(" -- Testing Pre-defined Random Frames -- ");
        repeat(10) begin
            uart_rx = 0;  // start bit
            repeat(OVERSAMPLING) begin
                @(posedge clk); #5;
            end
            // generate random bit and send
            for (int i = 0; i < DATA_BITS; i++) begin
                random_bits[i] = 1'($urandom()); 
                uart_rx = random_bits[i];  // data bits
                repeat(OVERSAMPLING) begin
                    @(posedge clk); #5;
                end
            end
            uart_rx = 1;  // stop bit
            @(posedge valid); #5;
            $display("TX: %b, RX: %b", data, random_bits);
            assert(data == random_bits);
        end
        $finish;
    end  // initial

endmodule  // frame_detector_tb

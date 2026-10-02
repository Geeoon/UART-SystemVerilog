/**
 * @file bit_detector_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the bit_detector module
 */
module bit_detector_tb #(
    parameter int CLOCK_PERIOD=100,
    parameter int BAUD_RATE=115200
) ();
    // inputs
    logic clk;
    logic rst;
    logic val;
    
    // outputs
    logic out;

    bit_detector #(
        .CLOCK_SPEED(BAUD_RATE*6),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk,
        .rst,

        .out
    );
    
    int cycle = 0;
    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
            if (clk) cycle = cycle + 1;
        end  // forever
    end  // initial

    initial begin
        $dumpfile("waveforms/bit_detector_tb.vcd");
        $dumpvars;

        rst = 1;
        @(posedge clk); #5;

        rst = 0;
        repeat(5) begin
            assert(~out);
            @(posedge clk); #5;
        end

        repeat(10) begin
            assert(out);
            @(posedge clk); #5;
            repeat(5) begin
                assert(~out);
                @(posedge clk); #5;
            end
        end

        
        $finish;
    end  // initial

endmodule  // bit_detector_tb

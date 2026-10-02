/**
 * @file start_detector_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the toggle_register module
 */
module start_detector_tb #(
    parameter int CLOCK_PERIOD=100,
    parameter int OVERSAMPLING_RATE=16,
    parameter int BAUD_RATE=115200
) ();
    // inputs
    logic clk;
    logic val;

    // outputs
    logic start;

    start_detector #(
        .CLOCK_SPEED(230400*3),
        .OVERSAMPLING_RATE(OVERSAMPLING_RATE),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk,
        .val,

        .start
    );

    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    initial begin
        $dumpfile("waveforms/start_detector_tb.vcd");
        $dumpvars;

        $display(" -- Starting start_detector test -- ");

        val = 1;
        repeat(100) begin
            @(posedge clk); #5;
            assert(~start);
        end

        val = 0;
        @(posedge clk); #5;
        
        repeat(2) begin
            assert(~start);
            @(posedge clk) #5;
        end
        assert(start);
        @(posedge clk);
        
        val = 1;
        @(posedge clk); #5;
        assert(~start);
        @(posedge clk); #5;

        val = 0;
        repeat(2) begin
            assert(~start);
            @(posedge clk); #5;
        end
        val = 1;
        @(posedge clk); #5;
        assert(~start);
        @(posedge clk);

        $display(" -- Finished Tests -- ");
        $finish;
    end  // initial

endmodule  // start_detector_tb

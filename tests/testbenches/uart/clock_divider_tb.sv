/**
 * @file clock_divider_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the toggle_register module
 */
module clock_divider_tb #(
    parameter int CLOCK_PERIOD=900,
    parameter int TARGET_CLOCK_SPEED=300
) ();
    // inputs
    logic clk;
    logic rst;

    // outputs
    logic out;

    clock_divider #(
        .MAIN_CLOCK_SPEED(CLOCK_PERIOD),
        .TARGET_CLOCK_SPEED(TARGET_CLOCK_SPEED)
    ) dut (
        .clk,
        .rst,

        .out
    );

    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    initial begin
        $dumpfile("waveforms/clock_divider_tb.vcd");
        $dumpvars;

        $display(" -- Starting clock_divider test -- ");
        // reset
        rst = 1;
        @(posedge clk); #5;
        rst = 0;

        repeat(10) begin
            repeat(CLOCK_PERIOD/TARGET_CLOCK_SPEED - 1) begin
                assert(~out);
                @(posedge clk); #5;
            end
            assert(out);
            @(posedge clk); #5;
        end

        $display(" -- Finished Tests -- ");
        $finish;
    end  // initial

endmodule  // clock_divider_tb

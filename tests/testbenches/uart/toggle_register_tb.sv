/**
 * @file toggle_register_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the toggle_register module
 */
module toggle_register_tb #(
    parameter int CLOCK_PERIOD=100
) ();
    // inputs
    logic clk;
    logic rst;
    logic t;
    
    // outputs
    logic q;
    logic not_q;

    toggle_register dut (
        .clk,
        .rst,
        .t,

        .q,
        .not_q
    );

    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    initial begin
        $dumpfile("waveforms/toggle_register_tb.vcd");
        $dumpvars;

        $display(" -- Starting toggle_register test -- ");
        // reset
        rst = 1;
        t = 0;
        @(posedge clk);
        rst = 0;

        $display(" -- Not Toggling Q = 0 -- ");
        repeat(10) begin
            assert(~q);
            assert(not_q);
            @(posedge clk);
        end

        $display(" -- Toggle Once, Q = 1 -- ");
        t = 1;
        @(posedge clk);
        t = 0;
        repeat(10) begin
            assert(q);
            assert(~not_q);
            @(posedge clk);
        end

        $display(" -- Toggle Again, Q = 0 -- ");
        t = 1;
        @(posedge clk);
        t = 0;
        repeat(10) begin
            assert(~q);
            assert(not_q);
            @(posedge clk);
        end

        $display(" -- Finished Tests -- ");

        $finish;
    end  // initial

endmodule  // toggle_register_tb

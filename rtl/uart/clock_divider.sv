/**
 * @file clock_divider.sv
 * @author Geeoon Chung
 * @brief a clock divider that outputs a clock enable signal
 * @param MAIN_CLOCK_SPEED      the speed of the main clock, frequency
 * @param TARGET_CLOCK_SPEED    the target clock speed, frequency (must be same units as \p MAIN_CLOCK_SPEED)
 * @param[in] clk               the main clock signal
 * @param[out] out              the clock enable signal.  High for only 1 main clock cycle
 */
module clock_divider #(
    parameter int MAIN_CLOCK_SPEED,
    parameter int TARGET_CLOCK_SPEED,

    localparam DIVISOR=MAIN_CLOCK_SPEED/TARGET_CLOCK_SPEED
)(
    input logic clk,
    input logic rst,

    output logic out
);
    if (MAIN_CLOCK_SPEED < TARGET_CLOCK_SPEED) begin
        $error("The clock divider cannot create a faster clock.");
    end else if ((MAIN_CLOCK_SPEED % TARGET_CLOCK_SPEED) != 0) begin
        $error("The clock divider can only target a clock speed if it is a divisor of the main clock speed.");
    end else if (MAIN_CLOCK_SPEED == TARGET_CLOCK_SPEED) begin
        $error("The clock divider is useless.  MAIN_CLOCK_SPEED == TARGET_CLOCK_SPEED.");
    end

    // SUBMODULES
    if (DIVISOR == 2) begin  // just use a flip flop
        always_ff @(posedge clk) begin
            if (rst) begin
                out <= 0;
            end else begin
                out <= ~out;
            end
        end  // always_ff
    end else begin  // use a timer to get a single cycle clock enable
        lfsr_timer #(
            .COUNT(DIVISOR - 1)
        ) timer_m (
            .clk,
            .rst(rst | out),
            .done(out)
        );
    end
endmodule  // clock_divider

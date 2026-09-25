/**
 * @file clock_divider.sv
 * @author Geeoon Chung
 * @brief a clock divider
 * @param MAIN_CLOCK_SPEED      the speed of the main clock
 * @param TARGET_CLOCK_SPEED    the target clock speed
 * @param[in] clk               the main clock signal
 * @param[in] prev_not_out      the previous divider's not out signal. set to 1 if this is the top level
 * @param[out] out              the output clock signal
 * @param[out] not_out          the inverted output clock signal
 */
module clock_divider #(
    parameter int MAIN_CLOCK_SPEED,
    parameter int TARGET_CLOCK_SPEED,

    localparam DIVISOR=MAIN_CLOCK_SPEED/TARGET_CLOCK_SPEED
)(
    input logic clk,
    input logic prev_not_out,
    
    output logic out,
    output logic not_out
);
    if (MAIN_CLOCK_SPEED < TARGET_CLOCK_SPEED) begin
        $error("The clock divider cannot create a faster clock.");
    end else if ((MAIN_CLOCK_SPEED % TARGET_CLOCK_SPEED) != 0) begin
        $error("The clock divider can only target a clock speed if it is a divisor of the main clock speed.");
    end else if (MAIN_CLOCK_SPEED == TARGET_CLOCK_SPEED) begin
        $error("The clock divider is useless.  MAIN_CLOCK_SPEED == TARGET_CLOCK_SPEED.");
    end

    if (DIVISOR == 2)
        begin : DIVISOR_eq_2

        end  // DIVISOR_eq_2
    else
        begin : DIVISOR_gt_2
            clock_divider #(
                .MAIN_CLOCK_SPEED(MAIN_CLOCK_SPEED / 2),
                .TARGET_CLOCK_SPEED(TARGET_CLOCK_SPEED)
            ) clock_divider_stage (
                .clk,
                .prev_not_out(),

                .out,
                .not_out
            );
        end  // DIVISOR_gt_2
endmodule
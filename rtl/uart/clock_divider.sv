/**
 * @file clock_divider.sv
 * @author Geeoon Chung
 * @brief a clock divider
 * @param MAIN_CLOCK_SPEED      the speed of the main clock
 * @param TARGET_CLOCK_SPEED    the target clock speed
 * @param[in] clk               the main clock signal
 * @param[out] out              the output clock signal. only high for one main clock cycle
 */
module clock_divider #(
    parameter int MAIN_CLOCK_SPEED,
    parameter int TARGET_CLOCK_SPEED,

    localparam DIVISOR=MAIN_CLOCK_SPEED/TARGET_CLOCK_SPEED
)(
    input logic clk,
    
    output logic out
);
    if (MAIN_CLOCK_SPEED < TARGET_CLOCK_SPEED) begin
        $error("The clock divider cannot create a faster clock.");
    end else if ((MAIN_CLOCK_SPEED % TARGET_CLOCK_SPEED) != 0) begin
        $error("The clock divider can only target a clock speed if it is a divisor of the main clock speed.");
    end

    logic [DIVISOR-1:0] clocks;

    always_ff @(posedge clk) begin
        
    end  // always_ff
endmodule
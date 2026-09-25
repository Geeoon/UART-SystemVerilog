/**
 * @file toggle_register.sv
 * @author Geeoon Chung
 * @brief used for a synchronous clock divider
 * @see https://people.engr.tamu.edu/spalermo/ecen620/lecture12_ee620_dividers.pdf
 * @param[in] clk       the clock driving the sequential logic
 * @param[in] rst       active high reset
 * @param[in] t         active high toggle
 * @param[out] q        output
 * @param[out] not_q    not output
 */
module toggle_register (
    input logic clk,
    input logic rst,
    input logic t,
    
    output logic q,
    output logic not_q
);
    logic d_ff;

    always_ff @(posedge clk) begin
        if (rst) begin
            d_ff <= 0;
        end else begin
            d_ff <= t ^ q;
        end
    end  // always_ff

    assign q = d_ff;
    assign not_q = ~d_ff;
endmodule  // toggle_register

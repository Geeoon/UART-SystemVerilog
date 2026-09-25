/**
 * @file bit_detector.sv
 * @author Geeoon Chung
 * @brief detects the start of a UART frame
 * @param CLOCK_SPEED       the speed of the clk signal in Hz
 * @param OVERSAMPLING_RATE the number of samples per symbol
 * @param BAUD_RATE         the UART baud rate
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           reset signal
 * @param[in] val           the current UART RX line value
 * @param[out] out          the bit that was last detected
 */
module bit_detector #(
    parameter int CLOCK_SPEED,  // in Hz
    parameter int OVERSAMPLING_RATE=16,
    parameter int BAUD_RATE=115200,
    
    localparam int CLOCKS_PER_SAMPLE=CLOCK_SPEED/(BAUD_RATE * OVERSAMPLING_RATE),
    localparam int HISTORY_SIZE=$clog2(OVERSAMPLING_RATE+1),
    localparam int THRESHOLD=OVERSAMPLING_RATE/2
)(
    input logic clk,
    input logic rst,
    input logic val,

    output logic out
);
    logic [OVERSAMPLING_RATE-1:0] history;
    logic [HISTORY_SIZE-1:0] sum;

    enum logic { c_add, c_sub } ctrl;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            sum <= '0;
            history <= '0;
        end else begin
            history <= { val, history[OVERSAMPLING_RATE-1:1] };
            case (ctrl)
                c_add : sum <= sum + 1;
                c_sub : sum <= sum - 1;
            endcase  // ctrl
        end
    end  // always_ff

    always_comb begin
        if (history[0] == 1) begin
            ctrl = c_sub;
        end else begin
            ctrl = c_add;
        end
    end  // always_comb

    assign out = (sum > {HISTORY_SIZE}'(THRESHOLD) );
endmodule  // bit_detector

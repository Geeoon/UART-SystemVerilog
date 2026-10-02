/**
 * @file uart_rx_fifo.sv
 * @author Geeoon Chung
 * @brief a FIFO that fills up as new UART bytes are received
 * @param CLOCK_SPEED       the speed of the clk signal in Hz
 * @param BAUD_RATE         the UART baud rate
 * @param DATA_BITS         the defined number of data bits per UART frame
 * @param FIFO_SIZE         the size of the FIFO in words, must be a power of 2
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           reset signal
 * @param[in] uart_rx       the UART receive line
 * @param[in] read          active high signal to read a new element from the FIFO
 * @param[out] empty        whether the FIFO is empty
 * @param[out] out          the value at the front of the FIFO
 */
module uart_rx_fifo #(
    parameter int CLOCK_SPEED,  // in Hz
    parameter int BAUD_RATE=115200,
    parameter int DATA_BITS=8,
    parameter int FIFO_SIZE=8,  // does not need to be large for RX
    
    localparam int CLOCKS_PER_SAMPLE=CLOCK_SPEED/BAUD_RATE
)(
    input logic clk,
    input logic rst,
    input logic uart_rx,
    input logic read,
    
    output logic empty,
    output logic [DATA_BITS-1:0] out
);
    logic [$clog(DATA_BITS)-1:0] rd_ptr, wr_ptr;
    always_ff @(posedge clk) begin
        if (rst) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
        end
    end  // always_ff

    // intermediate signals
    logic detector_valid;
    logic [DATA_BITS-1:0] detector_data;
    // SUBMODULES
    frame_detector #(
        .CLOCK_SPEED(CLOCK_SPEED),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(DATA_BITS)
    ) detector_m (
        .clk,
        .rst,
        .uart_rx,

        .valid(detector_valid),
        .data(detector_data)
    );
endmodule  // uart_rx_fifo

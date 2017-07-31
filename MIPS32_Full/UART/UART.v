`timescale 1ns / 1ps


module UART (
    input        clock,
    input        reset,
    input        rx,
    output       tx,

    input        write,
    input [7:0]  data_write,
    input        read,
    output [7:0] data_read,
    output       data_ready, //Comment

    output       uart_clock,
    output       uart_clock_16,

    output [7:0] debug_data
);

    wire         uart_tick;     //Every CLock pulse
    wire         uart_tick_16;  //16x sample to syncronize
    wire         tx_ready;
    wire         rx_ready;

    reg          tx_start = 0;
    reg          tx_fifo_read = 0;

    wire         tx_fifo_full;
    wire         tx_fifo_empty;
    wire [7:0]   tx_fifo_data;

    wire [7:0]   rx_data;
    wire         rx_fifo_full;
    wire         rx_fifo_empty;


    UART_Clock_Generator UART_Clock (
        .clock          (clock),
        .uart_tick      (uart_tick),
        .uart_tick_16   (uart_tick_16)
    );

    assign uart_clock    = (uart_tick);
    assign uart_clock_16 = (uart_tick_16);
    assign data_ready    = ~rx_fifo_empty;

    always @ (posedge clock) begin
        if (reset) begin
            tx_start     <= 0;
            tx_fifo_read <= 0;
        end
        else begin
            if (tx_ready & uart_tick & ~tx_fifo_empty) begin
                tx_start     <= 1;
                tx_fifo_read <= 1;
            end
            else begin
                tx_start     <= 0;
                tx_fifo_read <= 0;
            end
        end
    end

    RX RX_O_Rato (
        .clock          (clock),
        .reset          (reset),
        .uart_tick_16   (uart_tick_16),
        .rx_signal      (rx),
        .ready          (rx_ready),
        .rx_data        (rx_data)
    );

    FIFO_Structure RX_Buffer (
        .clock          (clock),
        .reset          (reset),
        .read           (read),
        .write          (rx_ready),
        .in_data        (rx_data),
        .full           (rx_fifo_full),
        .empty          (rx_fifo_empty),
        .out_data       (data_read)
    );

    FIFO_Structure_Ahead TX_Buffer (
        .clock          (clock),
        .reset          (reset),
        .read           (tx_fifo_read),
        .write          (write),
        .in_data        (data_write),
        .full           (tx_fifo_full),
        .empty          (tx_fifo_empty),
        .out_data       (tx_fifo_data)
    );

    TX TX_O_Rato (
        .clock          (clock),
        .reset          (reset),
        .uart_tick      (uart_tick),
        .tx_signal      (tx),
        .tx_start       (tx_start),
        .tx_data        (tx_fifo_data),
        .ready          (tx_ready)
    );


endmodule // UART

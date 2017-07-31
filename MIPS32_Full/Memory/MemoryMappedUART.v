`timescale 1ns / 1ps

module MemoryMappedUART (
    input               clock,
    input               reset,
    input               selected,

    input               rx_signal,
    output              tx_signal,

    input [7:0]         address,

    input               write,
    input [7:0]         in_data,
    input               read,
    output [31:0]       out_data,

    output              uart_clock,
    output              uart_clock_16,

    output [7:0]        debug_data
);

    wire        read_uart   = ((address == 8'd0) & read);
    wire        read_aval   = ((address == 8'd4) & read);
    wire        write_uart  = ((address == 8'd8) & write);

    wire [7:0]  uart_read_data;
    wire        uart_data_avaliable;

    wire        clock_def;

    assign clock_def = (selected) ? clock : 1'b0;

    UART UART_Instance (
        .clock          (clock_def),
        .reset          (reset),

        .rx             (rx_signal),
        .tx             (tx_signal),

        .write          (write_uart),
        .read           (read_uart),

        .data_write     (in_data),
        .data_read      (uart_read_data),
        .data_ready     (uart_data_avaliable),

        .uart_clock     (uart_clock),
        .uart_clock_16  (uart_clock_16),

        .debug_data     (debug_data)
    );

    assign out_data = (read_uart) ? {24'd0, uart_read_data} : ( (read_aval) ? {31'd0, uart_data_avaliable} : 32'd0 );



endmodule // MemoryMappedUART

`timescale 1ns / 1ps

module UART_Clock_Generator (
    input   clock,
    output  uart_tick,
    output  uart_tick_16 //
);

    reg [12:0] accumulator = 13'd0;
    always @ (posedge clock) begin
        //accumulator[12] <= ~accumulator[12];
        accumulator <= accumulator[11:0] + 12'd151;
    end

    assign uart_tick_16 = (accumulator[12]);
    //assign uart_tick_16 = clock;

    reg [3:0] counter = 4'd0;
    always @ (posedge clock) begin
        counter <= (uart_tick_16) ? counter + 1'b1 : counter;
    end
    assign uart_tick = (uart_tick_16 == 4'd1 && counter == 4'd15);


endmodule // UART_Clock_Generator

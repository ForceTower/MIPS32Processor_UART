`timescale 1ns / 1ps

module TX (
    input           clock,
    input           reset,
    input           uart_tick,
    input           tx_start,
    input [7:0]     tx_data,
    output          ready,

    output reg      tx_signal,
    output [7:0]    debug_data
);

    localparam [3:0] IDLE    = 0;
    localparam [3:0] STRT    = 1;
    localparam [3:0] BIT0    = 2;
    localparam [3:0] BIT1    = 3;
    localparam [3:0] BIT2    = 4;
    localparam [3:0] BIT3    = 5;
    localparam [3:0] BIT4    = 6;
    localparam [3:0] BIT5    = 7;
    localparam [3:0] BIT6    = 8;
    localparam [3:0] BIT7    = 9;
    localparam [3:0] STOP    = 10;

    reg [7:0] write_data = 8'd2;
    reg [3:0] state      = IDLE;

    assign ready = (state == IDLE) || (state == STOP);

    always @ (posedge clock) begin
        if (ready & tx_start)
            write_data <= tx_data;
        //write_data <= (ready & tx_start) ? tx_data : write_data;
    end

    assign debug_data = tx_data;

    always @ (posedge clock) begin
        if (reset)
            state <= IDLE;
        else begin
            case (state)
                IDLE : state <= (tx_start)  ? STRT : IDLE;
                STRT : state <= (uart_tick) ? BIT0 : STRT;
                BIT0 : state <= (uart_tick) ? BIT1 : BIT0;
                BIT1 : state <= (uart_tick) ? BIT2 : BIT1;
                BIT2 : state <= (uart_tick) ? BIT3 : BIT2;
                BIT3 : state <= (uart_tick) ? BIT4 : BIT3;
                BIT4 : state <= (uart_tick) ? BIT5 : BIT4;
                BIT5 : state <= (uart_tick) ? BIT6 : BIT5;
                BIT6 : state <= (uart_tick) ? BIT7 : BIT6;
                BIT7 : state <= (uart_tick) ? STOP : BIT7;
                /*IDLE : if (tx_start)     state <= STRT;
                STRT : if (uart_tick)    state <= BIT0;
                BIT0 : if (uart_tick)    state <= BIT1;
                BIT1 : if (uart_tick)    state <= BIT2;
                BIT2 : if (uart_tick)    state <= BIT3;
                BIT3 : if (uart_tick)    state <= BIT4;
                BIT4 : if (uart_tick)    state <= BIT5;
                BIT5 : if (uart_tick)    state <= BIT6;
                BIT6 : if (uart_tick)    state <= BIT7;
                BIT7 : if (uart_tick)    state <= STOP;*/
                STOP : if (uart_tick)    state <= (tx_start) ? STRT : IDLE;
                default: state <= 4'bxxxx;
            endcase
        end
    end

    always @ (state, write_data) begin
        case (state)
            IDLE: tx_signal <= 1;
            STRT: tx_signal <= 0;
            BIT0: tx_signal <= write_data[0];
            BIT1: tx_signal <= write_data[1];
            BIT2: tx_signal <= write_data[2];
            BIT3: tx_signal <= write_data[3];
            BIT4: tx_signal <= write_data[4];
            BIT5: tx_signal <= write_data[5];
            BIT6: tx_signal <= write_data[6];
            BIT7: tx_signal <= write_data[7];
            STOP: tx_signal <= 1;
            default: tx_signal <= 1'bx;
        endcase
    end

endmodule // TX

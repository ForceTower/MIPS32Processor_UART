`timescale 1ns / 1ps

module RX (
    input           clock,
    input           reset,
    input           uart_tick_16,
    input           rx_signal,

    output           ready,
    output reg [7:0] rx_data = 0
);
    localparam [3:0] IDLE    = 0;
    localparam [3:0] BIT0    = 1;
    localparam [3:0] BIT1    = 2;
    localparam [3:0] BIT2    = 3;
    localparam [3:0] BIT3    = 4;
    localparam [3:0] BIT4    = 5;
    localparam [3:0] BIT5    = 6;
    localparam [3:0] BIT6    = 7;
    localparam [3:0] BIT7    = 8;
    localparam [3:0] STOP    = 9;

    reg [1:0]   rx_sync = 3;
    reg [1:0]   rx_count = 0;
    reg         rx_bit = 1;

    reg [3:0]   state = IDLE;
    reg         clock_lock = 0;
    reg [3:0]   rx_bit_spacing = 4'b1110;

    always @ (posedge clock) begin
        if (uart_tick_16)
            rx_sync <= {rx_sync[0], rx_signal};
        else
            rx_sync <= rx_sync;
    end

    always @ (posedge clock) begin
        if (uart_tick_16) begin
            case (rx_sync[1])
                0: rx_count <= (rx_count == 2'b11) ? rx_count : rx_count + 1'b1;
                1: rx_count <= (rx_count == 2'b00) ? rx_count : rx_count - 1'b1;
            endcase

            rx_bit <= (rx_count == 2'b11) ? 1'b0 : ( (rx_count == 2'b00) ? 1'b1 : rx_bit );
        end
        else begin
            rx_count <= rx_count;
            rx_bit   <= rx_bit;
        end
    end

    always @ (posedge clock) begin
        if (uart_tick_16) begin
            if (~clock_lock)
                clock_lock <= ~rx_bit;
            else
                clock_lock <= ((state == IDLE) && rx_bit) ? 1'b0 : clock_lock;

            rx_bit_spacing <= (clock_lock) ? rx_bit_spacing + 1'b1 : 4'b1110;
        end

        else begin
            clock_lock      <= clock_lock;
            rx_bit_spacing  <= rx_bit_spacing;
        end
    end

    wire rx_rc_bit = (rx_bit_spacing == 4'b1111);

    always @ (posedge clock) begin
        if (reset) state <= IDLE;

        else if (uart_tick_16) begin
            case (state)
                IDLE: state <= (rx_rc_bit & (rx_bit == 0)) ? BIT0 : IDLE;
                BIT0: state <= (rx_rc_bit) ? BIT1 : BIT0;
                BIT1: state <= (rx_rc_bit) ? BIT2 : BIT1;
                BIT2: state <= (rx_rc_bit) ? BIT3 : BIT2;
                BIT3: state <= (rx_rc_bit) ? BIT4 : BIT3;
                BIT4: state <= (rx_rc_bit) ? BIT5 : BIT4;
                BIT5: state <= (rx_rc_bit) ? BIT6 : BIT5;
                BIT6: state <= (rx_rc_bit) ? BIT7 : BIT6;
                BIT7: state <= (rx_rc_bit) ? STOP : BIT7;
                STOP: state <= (rx_rc_bit) ? IDLE : STOP;
                default: state <= 4'bxxxx;
            endcase
        end

        else state <= state;
    end

    wire read_value = (uart_tick_16 & rx_rc_bit & (state != IDLE) & (state != STOP));

    always @ (posedge clock) begin
        rx_data <= (read_value) ? {rx_bit, rx_data[7:1]} : rx_data[7:0];
    end

    assign ready = (uart_tick_16 & rx_rc_bit & (state == STOP));

endmodule // RX

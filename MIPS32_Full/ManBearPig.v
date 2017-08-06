`timescale 1ns / 1ps

module ManBearPig (
    input   clock,
    input   reset,

    input   rx_source_0,
    output  tx_source_0,

    input   rx_source_1,
    output  tx_source_1, //This line is great again

    output  d_test_valid,

    output  d_uart0_read,
    output  d_uart1_read,
    output  d_uart0_write,
    output  d_uart1_write,
    output  d_mem_read,
    output  d_mem_write,

    output [1:0] d_mem_map,

    output [31:0] d_datamemory_address
);

    //Processor Instructions Interface
    /*
    wire        instruction_read;
    wire [31:0] instruction_address;
    wire [31:0] instruction;
    */

    //Processor Memory Interface
    wire        datamemory_write;
    wire        datamemory_read;
    wire [31:0] datamemory_read_data;
    wire [31:0] datamemory_write_data;
    wire [31:0] datamemory_address;

    //Memory
    reg         memory_read;
    reg         memory_write;
    wire [31:0] memory_data;

    //UART0 Signals
    reg         uart0_read;
    reg         uart0_write;
    wire [31:0] uart0_data;
    wire        uart0_tx;

    //UART1 Signals
    reg         uart1_read;
    reg         uart1_write;
    wire [31:0] uart1_data;
    wire        uart1_tx;

    //Memory Map
    reg [1:0] memory_map;

    assign d_uart0_read  = (uart0_read);
    assign d_uart1_read  = (uart1_read);
    assign d_uart0_write = (uart0_write);
    assign d_uart1_write = (uart1_write);

    assign d_mem_read = (datamemory_read);
    assign d_mem_write = (datamemory_write);

    assign d_mem_map = (memory_map);
    assign d_datamemory_address = datamemory_address;

    Processor MIPS_Processor (
        .clock                      (clock),
        .reset                      (reset),

        .me_memory_address_out      (datamemory_address),

        .me_memory_read_out         (datamemory_read),
        .me_memory_data_read_in     (datamemory_read_data),

        .me_memory_write_out        (datamemory_write),
        .me_memory_data_write_out   (datamemory_write_data),

        .d_test_valid               (d_test_valid)
    );

    MemoryMappedUART UART0 (
        .clock              (clock),
        .reset              (reset),
        .selected           (1'b1),

        .rx_signal          (rx_source_0),
        .tx_signal          (uart0_tx),

        .address            (datamemory_address[7:0]),
        .in_data            (datamemory_write_data[7:0]),
        .out_data           (uart0_data),

        .write              (uart0_write),
        .read               (uart0_read)
    );

    MemoryMappedUART UART1 (
        .clock              (clock),
        .reset              (reset),
        .selected           (1'b1),

        .rx_signal          (rx_source_1),
        .tx_signal          (uart1_tx),

        .address            (datamemory_address[7:0]),
        .in_data            (datamemory_write_data[7:0]),
        .out_data           (uart1_data),

        .write              (uart1_write),
        .read               (uart1_read)
    );

    DataMemoryInterface DataMemory (
        .clock              (clock),
        .reset              (reset),
        .address            (datamemory_address),

        .mem_write          (memory_write),
        .data_write         (datamemory_write_data),

        .mem_read           (memory_read),
        .read_data          (memory_data)
    );

    always @ ( * ) begin
        case (datamemory_address[8])
            0 : begin
                    memory_map      <= 2'd0; //Data memory
                    memory_read     <= datamemory_read;
                    memory_write    <= datamemory_write;
                    uart0_read      <= 1'b0;
                    uart0_write     <= 1'b0;
                    uart1_read      <= 1'b0;
                    uart1_write     <= 1'b0;
                end
            1 : begin
                    case (datamemory_address[9]) //UART's
                        0 : begin //UART 0
                                memory_map  <= 2'd1;
                                memory_read     <= 1'b0;
                                memory_write    <= 1'b0;
                                uart0_read      <= datamemory_read;
                                uart0_write     <= datamemory_write;
                                uart1_read      <= 1'b0;
                                uart1_write     <= 1'b0;
                            end
                        1 : begin //UART 1
                                memory_map <= 2'd2;
                                memory_read     <= 1'b0;
                                memory_write    <= 1'b0;
                                uart0_read      <= 1'b0;
                                uart0_write     <= 1'b0;
                                uart1_read      <= datamemory_read;
                                uart1_write     <= datamemory_write;
                            end
                    endcase
                end
        endcase
    end

    Multiplex4 #(.WIDTH (32)) MemoryReadSelection (
        .sel    (memory_map),
        .in0    (memory_data),
        .in1    (uart0_data),
        .in2    (uart1_data),
        .in3    (32'hxxxxxxxx),
        .out    (datamemory_read_data)
    );

    assign tx_source_0 = uart0_tx;
    assign tx_source_1 = uart1_tx;

endmodule // ManBearPig

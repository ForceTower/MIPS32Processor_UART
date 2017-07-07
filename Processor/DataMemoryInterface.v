`timescale 1ns / 1ps

module DataMemoryInterface (
    input           clock,
    input           reset,
    input [31:0]    address,
    input           mem_write,
    input [31:0]    data_write,
    input           mem_read,
    output [31:0]   read_data
);

    reg [31:0] memory [0:127];

    integer i;
    initial begin
        for (i = 0; i < 128; i = i + 1) begin
            memory[i] = 0;
        end
    end

    always @ (posedge clock) begin
        if (reset) begin
            for (i = 0; i < 128; i = i + 1) begin
                memory[i] = 0;
            end
        end
        else begin
            if (mem_write) begin
                memory[address[6:0]] <= data_write; // If write, write on clock
            end
        end
    end

    //Read data from memory if needed
    assign read_data = (mem_read) ? memory[address[6:0]] : 32'hxxxxxxxx;

endmodule // DataMemoryInterface

`timescale 1ns / 1ps

module TB_DataMemoryInterface ();
    reg           clock;
    reg           reset;
    reg [31:0]    address;
    reg           mem_write;
    reg [31:0]    data_write;
    reg           mem_read;
    wire [31:0]   read_data;

    DataMemoryInterface DataMemory(
        .clock          (clock),
        .reset          (reset),
        .address        (address),
        .mem_write      (mem_write),
        .data_write     (data_write),
        .mem_read       (mem_read),
        .read_data      (read_data)
    );


    initial begin
        reset = 0;
        clock = 1;

        #10
        address = 32'd0;
        mem_write = 1;
        data_write = 32'd500;

        #20
        mem_write = 0;
        mem_read = 1;

        #10
        if (read_data == 32'd500)
            $display ("Read and Write 1 - OK");
        else
            $display ("Read and Write 1 - FAIL");

        #20
        address = 32'd0;
        mem_write = 1;
        data_write = 32'd400;

        #20
        mem_write = 0;
        mem_read = 1;

        #10
        if (read_data == 32'd400)
            $display ("Read and Write Override - OK");
        else
            $display ("Read and Write Override - FAIL");

    end

    always #10 clock = ~clock;

endmodule // TB_DataMemoryInterface

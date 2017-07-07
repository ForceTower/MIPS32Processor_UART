`timescale 1ns / 1ps

module RegisterFile (
    input           clock,
    input           reset,

    //Registers to Read
    input [4:0]     read_reg1,
    input [4:0]     read_reg2,
    //Data read
    output [31:0]   id_reg1_data,
    output [31:0]   id_reg2_data,
    //Write data
    input           wb_reg_write,
    input [4:0]     wb_rt_rd,
    input [31:0]    wb_write_data
);
    //Register 0 is not necessary since it's hardwired to 0
    reg [31:0] registers [1:31];

    integer i;
    initial begin
        for (i = 1; i < 32; i = i + 1) begin
            registers[i] <= 0;
        end
    end

    always @ (posedge clock) begin
        if (reset) begin
            for (i = 1; i < 32; i = i + 1) begin
                registers[i] <= 0;
            end
        end

        //Write to a register
        else begin
            if (wb_rt_rd != 0 & wb_reg_write) begin
                registers[wb_rt_rd] <= wb_write_data;
            end
        end
    end

    //Read register
    assign id_reg1_data = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];
    assign id_reg2_data = (read_reg2 == 0) ? 32'b0 : registers[read_reg2];
endmodule // RegisterFile

`timescale 1ns / 1ps

//Basically its something to delay the PC between instructions
module PC_Latch (
    input clock,
    input reset,
    input enable,
    input [31:0] data,
    output reg [31:0] value
);

    initial begin
        value = 32'd0;
    end

    //Transfers the data from the input to the output for at least 1 clock cycle
    always @ (posedge clock) begin
        value <= (reset) ? 32'd0 : ((enable) ? data : value);
    end

endmodule // PC_Latch

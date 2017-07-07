`timescale 1ns / 1ps

module Multiplex4 #(parameter WIDTH = 32) (
    input       [1:0]           sel, //Selector
    input       [(WIDTH-1):0]   in0, //Output 00
    input       [(WIDTH-1):0]   in1, //Output 01
    input       [(WIDTH-1):0]   in2, //Output 10
    input       [(WIDTH-1):0]   in3, //Output 11
    output reg  [(WIDTH-1):0]   out  //Mux Result
);
    always @ ( * ) begin
        case (sel)
            2'b00: out <= in0;
            2'b01: out <= in1;
            2'b10: out <= in2;
            2'b11: out <= in3;
        endcase
    end

endmodule // Multiplex4

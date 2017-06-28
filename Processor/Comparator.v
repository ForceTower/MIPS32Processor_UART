`timescale 1ns / 1ps

module Comparator (
    input [31:0] A,
    input [31:0] B,

    output Equals //Are input equals?
);

    //This module was done so we can implement more instructions for the branch type
    assign Equals = (A == B);

endmodule // Comparator

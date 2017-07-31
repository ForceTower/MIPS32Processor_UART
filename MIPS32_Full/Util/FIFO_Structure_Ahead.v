`timescale 1ns / 1ps

module FIFO_Structure_Ahead (
    input               clock,
    input               write,
    input               read,
    input [7:0]         in_data,
    input               reset,

    output              full,
    output              empty,
    output [7:0]        out_data
);


    dcfifo #(
        .intended_device_family ("Cyclone IV"),
        .lpm_type               ("dcfifo"),
        .lpm_width              (8),
        .lpm_numwords           (16),
        .lpm_showahead          ("ON"),
        .overflow_checking      ("ON"),
        .underflow_checking     ("ON"),
        .clocks_are_synchronized("TRUE")
    ) FIFO (
        .rdclk                  (clock),
        .wrclk                  (clock),
        .data                   (in_data),
        .wrreq                  (write),
        .rdreq                  (read),
        .q                      (out_data),
        .rdempty                (empty),
        .wrfull                 (full),
        .aclr                   (reset)
    );

endmodule // FIFO_Structure

`timescale 1ns / 1ps

module FIFO_Structure (
    input               clock,
    input               write,
    input               read,
    input [7:0]         in_data,
    input               reset,

    output              full,
    output              empty,
    output [7:0]        out_data
);


    scfifo #(
        .intended_device_family ("Cyclone IV"),
        .lpm_type               ("scfifo"),
        .lpm_width              (8),
        .lpm_numwords           (16),
        .lpm_showahead          ("OFF"),
        .overflow_checking      ("ON"),
        .underflow_checking     ("ON")
    ) FIFO (
        .clock                  (clock),
        .data                   (in_data),
        .wrreq                  (write),
        .rdreq                  (read),
        .q                      (out_data),
        .empty                  (empty),
        .full                   (full),
        .aclr                   (reset)
    );

endmodule // FIFO_Structure

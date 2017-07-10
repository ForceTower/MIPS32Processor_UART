`timescale 1ns / 1ps

module Instruction_Fetch_Decode_Pipeline (
    input           clock,
    input           reset,
    input           if_flush,
    input           if_stall,
    input           id_stall,
    input           if_bra_delay,
    input [31:0]    if_instruction,
    input [31:0]    if_pc_add_4,
    input [31:0]    if_pc_usable,

    //output reg          id_bra_delay,
    output reg [31:0]   id_instruction,
    output reg [31:0]   id_pc_add_4,
    output reg [31:0]   id_pc
);

    always @ (posedge clock) begin
        //id_instruction = if_instruction if, and only if, there are no stalls, flushes or reset
        id_instruction <= (reset) ? 32'b0 : ( (id_stall) ? id_instruction : ( (if_stall | if_flush | if_bra_delay) ? 32'b0 : if_instruction ) );
        //id_pc_add_4 = if_pc_add_4 if, and only if, there's no stall or we're not reseting
        id_pc_add_4    <= (reset) ? 32'b0 : ( (id_stall) ? id_pc_add_4 : if_pc_add_4);
        //id_bra_delay   <= (reset) ? 1'b0  : ( (id_stall) ? id_bra_delay : if_bra_delay);
        //id_pc = PC to save to the register in case of branch or stall
        id_pc          <= (reset) ? 32'b0 : ( (id_stall | if_bra_delay) ? id_pc : if_pc_usable);
    end

endmodule //Instruction_Fetch_Decode_Pipeline

`timescale 1ns / 1ps

module InstructionMemoryInterface #(parameter INSTRUCTION_FILE = "file.txt") (
    input           if_stall,
    input  [31:0]   if_pc_usable,
    output [31:0]   if_instruction
);

    reg [31:0] memory [0:63];

    initial begin
        $readmemb(INSTRUCTION_FILE, memory);
    end

    //Returns the instruction at PC position
    //The fact that PC is a multiple of 4 makes we need to ignore the last 2 bits from it (this way we basically dividing by 4)
    assign if_instruction = (if_stall) ? 32'b0 : memory[if_pc_usable[7:2]][31:0];

endmodule // InstructionMemoryInterface

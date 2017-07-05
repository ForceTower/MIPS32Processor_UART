`timescale 1ns / 1ps

module Memory_WriteBack_Pipeline (
    input           clock,
    input           reset,

    input           me_reg_write,
    input           me_mem_to_reg,
    input [31:0]    me_mem_read_data,
    input [31:0]    me_alu_result,
    input [4:0]     me_rt_rd,

    output reg          wb_reg_write,
    output reg          wb_mem_to_reg,
    output reg [31:0]   wb_data_memory,
    output reg [31:0]   wb_alu_result,
    output reg [4:0]    wb_rt_rd
);

    wire me_stall = 0;
    wire wb_stall = 0;

    always @ (posedge clock) begin
        wb_reg_write    <= (reset) ? 1'b0   : ( (wb_stall) ? wb_reg_write : ((me_stall) ? 1'b0 : me_reg_write));
        wb_mem_to_reg   <= (reset) ? 1'b0   : ( (wb_stall) ? wb_mem_to_reg : me_mem_to_reg);
        wb_data_memory  <= (reset) ? 32'b0  : ( (wb_stall) ? wb_data_memory : me_mem_read_data);
        wb_alu_result   <= (reset) ? 32'b0  : ( (wb_stall) ? wb_alu_result : me_alu_result);
        wb_rt_rd        <= (reset) ? 5'b0   : ( (wb_stall) ? wb_rt_rd : me_rt_rd);
    end

endmodule // Memory_WriteBack_Pipeline

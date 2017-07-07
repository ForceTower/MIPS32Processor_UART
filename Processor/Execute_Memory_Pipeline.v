`timescale 1ns / 1ps

module Execute_Memory_Pipeline (
    input           clock,
    input           reset,
    input           ex_stall,

    input           ex_mem_read,
    input           ex_mem_write,
    input           ex_mem_to_reg,
    input           ex_reg_write,
    input [31:0]    ex_alu_result,
    input [31:0]    ex_reg2_fwd,
    input [4:0]     ex_rt_rd,

    output reg          me_mem_read,
    output reg          me_mem_write,
    output reg          me_mem_to_reg,
    output reg          me_reg_write,
    output reg [31:0]   me_alu_result,
    output reg [31:0]   me_data2_reg,
    output reg [4:0]    me_rt_rd
);

    wire me_stall = 0;

    always @ (posedge clock) begin
        me_mem_read     <= (reset) ? 1'b0   : ( (me_stall) ? me_mem_read : ( (ex_stall) ? 1'b0 : ex_mem_read));
        me_mem_write    <= (reset) ? 1'b0   : ( (me_stall) ? me_mem_write : ( (ex_stall) ? 1'b0 : ex_mem_write));
        me_mem_to_reg   <= (reset) ? 1'b0   : ( (me_stall) ? me_mem_to_reg : ex_mem_to_reg);
        me_reg_write    <= (reset) ? 1'b0   : ( (me_stall) ? me_reg_write : ( (ex_stall) ? 1'b0 : ex_reg_write));
        me_alu_result   <= (reset) ? 32'b0  : ( (me_stall) ? me_alu_result : ex_alu_result);
        me_data2_reg    <= (reset) ? 32'b0  : ( (me_stall) ? me_data2_reg : ex_reg2_fwd);
        me_rt_rd        <= (reset) ? 5'b0   : ( (me_stall) ? me_rt_rd : ex_rt_rd);
    end

endmodule // Execute_Memory_Pipeline

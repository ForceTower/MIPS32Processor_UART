`timescale 1ns / 1ps

module Instruction_Decode_Execute_Pipeline (
    input           clock,
    input           reset,
    input           id_stall,
    input           ex_stall,
    // Control
    input           id_jump_link,
    input           id_reg_dst,
    input           id_alu_src,
    input [4:0]     id_alu_op,
    input           id_mem_read,
    input           id_mem_write,
    input           id_mem_to_reg,
    input           id_reg_write,
    //Hazard
    input [4:0]     id_rs,
    input [4:0]     id_rt,
    input           id_w_rs_ex,
    input           id_n_rs_ex,
    input           id_w_rt_ex,
    input           id_n_rt_ex,
    //Data
    input [31:0]    id_reg1_end,
    input [31:0]    id_reg2_end,
    input [31:0]    id_pc,
    input [16:0]    id_sign_extended_immediate,
    //Outputs

    output reg          ex_jump_link,
    output     [1:0]    ex_jump_link_reg_dst,
    output reg          ex_alu_src,
    output reg [4:0]    ex_alu_op,
    output reg          ex_mem_read,
    output reg          ex_mem_write,
    output reg          ex_mem_to_reg,
	output reg          ex_reg_write,
    output reg [4:0]    ex_rs,
    output reg [4:0]    ex_rt,
    output reg          ex_w_rs_ex,
    output reg          ex_n_rs_ex,
    output reg          ex_w_rt_ex,
    output reg          ex_n_rt_ex,
    output reg [31:0]   ex_reg1_data,
    output reg [31:0]   ex_reg2_data,
    output reg [31:0]   ex_pc,
    output     [31:0]   ex_sign_extended_immediate,
    output     [4:0]    ex_rd,
    output     [4:0]    ex_shamt
);

    reg [16:0] ex_sign_ex_imm_creator;
    reg ex_reg_dst;

    //Defines the destination register for the instruction if its a JAL : R = 31, if immediate : rt, if other rd
    assign ex_jump_link_reg_dst = (ex_jump_link) ? 2'b10 : ( (ex_reg_dst) ? 2'b01 : 2'b00 );
    //Extracts RD from immediate
    assign ex_rd = ex_sign_extended_immediate[15:11];
    //Extracts the Shamt from immediate
    assign ex_shamt = ex_sign_extended_immediate[10:6];
    //Creates de signal extended immediate (TODO This line can be better)
    assign ex_sign_extended_immediate = (ex_sign_ex_imm_creator[16]) ? {15'h7fff, ex_sign_ex_imm_creator[16:0]} : {15'h0000, ex_sign_ex_imm_creator[16:0]};

    always @ (posedge clock) begin
        ex_jump_link            <= (reset) ? 1'b0   : ( (ex_stall) ? ex_jump_link : id_jump_link );
        ex_reg_dst              <= (reset) ? 1'b0   : ( (ex_stall) ? ex_reg_dst : id_reg_dst);
        ex_alu_src              <= (reset) ? 1'b0   : ( (ex_stall) ? ex_alu_src : id_alu_src);
        ex_alu_op               <= (reset) ? 5'b0   : ( (ex_stall) ? ex_alu_op : ( (id_stall) ? 5'b0 : id_alu_op));
        ex_mem_read             <= (reset) ? 1'b0   : ( (ex_stall) ? ex_mem_read : ( (id_stall) ? 1'b0 : id_mem_read));
        ex_mem_write            <= (reset) ? 1'b0   : ( (ex_stall) ? ex_mem_write : ( (id_stall) ? 1'b0 : id_mem_write));
        ex_mem_to_reg           <= (reset) ? 1'b0   : ( (ex_stall) ? ex_mem_to_reg : id_mem_to_reg);
        ex_reg_write            <= (reset) ? 1'b0   : ( (ex_stall) ? ex_reg_write : ( (id_stall) ? 1'b0 : id_reg_write));
        ex_reg1_data            <= (reset) ? 32'b0  : ( (ex_stall) ? ex_reg1_data : id_reg1_end);
        ex_reg2_data            <= (reset) ? 32'b0  : ( (ex_stall) ? ex_reg2_data : id_reg2_end);
        ex_pc                   <= (reset) ? 32'b0  : ( (ex_stall) ? ex_pc : id_pc);
        ex_sign_ex_imm_creator  <= (reset) ? 17'b0  : ( (ex_stall) ? ex_sign_ex_imm_creator : id_sign_extended_immediate);
        ex_rs                   <= (reset) ? 5'b0   : ( (ex_stall) ? ex_rs : id_rs);
        ex_rt                   <= (reset) ? 5'b0   : ( (ex_stall) ? ex_rt : id_rt);
        ex_w_rs_ex              <= (reset) ? 1'b0   : ( (ex_stall) ? ex_w_rs_ex : ( (id_stall) ? 1'b0 : id_w_rs_ex));
        ex_n_rs_ex              <= (reset) ? 1'b0   : ( (ex_stall) ? ex_n_rs_ex : ( (id_stall) ? 1'b0 : id_n_rs_ex));
        ex_w_rt_ex              <= (reset) ? 1'b0   : ( (ex_stall) ? ex_w_rt_ex : ( (id_stall) ? 1'b0 : id_w_rt_ex));
        ex_n_rt_ex              <= (reset) ? 1'b0   : ( (ex_stall) ? ex_n_rt_ex : ( (id_stall) ? 1'b0 : id_n_rt_ex));
    end

endmodule // Instruction_Decode_Execute_Pipeline

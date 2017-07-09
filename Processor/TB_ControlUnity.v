`timescale 1ns / 1ps
`include "Constants.v"

module TB_ControlUnity ();
    reg         id_stall;
    reg [5:0]   id_opcode;
    reg [5:0]   id_funct;
    reg         id_cmp_eq;

    wire        if_flush;
    wire [7:0]  id_signal_forwarding;
    wire [1:0]  id_pc_source_sel;
    wire        id_sign_extend;
    wire        id_jump_link;
    wire        id_reg_dst;
    wire        id_alu_src;
    wire        id_branch_delay_slot;
    wire [4:0]  id_alu_op;
    wire        id_mem_write;
    wire        id_mem_read;
    wire        id_mem_to_reg;
    wire        id_reg_write;

    ControlUnity Unity (
        .id_stall               (id_stall),
        .id_opcode              (id_opcode),
        .id_funct               (id_funct),
        .id_cmp_eq              (id_cmp_eq),
        .if_flush               (if_flush), //TODO This is always 0 (remove)
        .id_signal_forwarding   (id_signal_forwarding),
        .id_pc_source_sel       (id_pc_source_sel),
        .id_sign_extend         (id_sign_extend),
        .id_jump_link           (id_jump_link),
        .id_reg_dst             (id_reg_dst),
        .id_alu_src             (id_alu_src),
        .id_alu_op              (id_alu_op),
        .id_mem_read            (id_mem_read),
        .id_mem_write           (id_mem_write),
        .id_mem_to_reg          (id_mem_to_reg),
        .id_reg_write           (id_reg_write),
        .id_branch_delay_slot   (id_branch_delay_slot)
    );

    wire [8:0]  signals;
    assign signals[8] = id_pc_source_sel[1];
    assign signals[7] = id_pc_source_sel[0];
    assign signals[6] = id_jump_link;
    assign signals[5] = id_alu_src;
    assign signals[4] = id_reg_dst;
    assign signals[3] = id_mem_read;
    assign signals[2] = id_mem_write;
    assign signals[1] = id_mem_to_reg;
    assign signals[0] = id_reg_write;

    initial begin
        id_stall = 1;
        id_cmp_eq = 0;

        #10
        if (signals == `SIG_NOP)
            $display("Stall Signals Passed");

        #10
        id_stall  = 0;
        id_opcode = `OPCODE_TYPE_R;
        id_funct  = `FUNCT_ADD;
        id_cmp_eq = 0;

        #10
        if (signals == `SIG_R_TYPE)
            $display("R-Type Signals are OK");
        else
            $display("R-Type Signals Fail");

        if (id_alu_op == `ALUOP_ADD)
            $display("R-Type Alu Operation is OK");
        else
            $display("R-Type Alu Operation Fail");

        if (id_signal_forwarding == `HAZ_EX_RS__EX_RT)
            $display("R-Type Hazard Detection Signals OK");
        else
            $display("R-Type Hazard Detection Signals Fail");

        if (id_branch_delay_slot)
            $display("It detected that this instruction will change PC Register");
        else
            $display("It detected that this instruction will not change PC Register");

        #10
        id_opcode = `OPCODE_SLTI;
        #10
        if (signals == `SIG_I_TYPE)
            $display("I-Type Signals are OK");
        else
            $display("I-Type Signals Fail");

        if (id_alu_op == `ALUOP_SLT)
            $display("I-Type Alu Operation is OK");
        else
            $display("I-Type Alu Operation Fail");

        if (id_signal_forwarding == `HAZ_EX_RS)
            $display("I-Type Hazard Detection Signals OK");
        else
            $display("I-Type Hazard Detection Signals Fail");

        if (id_sign_extend)
            $display("Instruction requires Sign Extension - SUCCESS");
        else
            $display("Instruction doesn't require Sign Extension - FAIL");

        #10
        id_opcode = `OPCODE_BEQ;
        id_cmp_eq = 1;

        #10
        if (signals == `SIG_BRANCH)
            $display("Branch Signals are OK");
        else
            $display("Branch Signals Fail");

        if (id_signal_forwarding == `HAZ_ID_RS__ID_RT)
            $display("Branch Hazard Detection Signals OK");
        else
            $display("Branch Hazard Detection Signals Fail");

        if (id_branch_delay_slot)
            $display("Instruction will branch to a defined Address - SUCCESS");
        else
            $display("Instruction won't branch to a defined Address - FAIL");

        #10
        id_opcode = `OPCODE_BNE;
        id_cmp_eq = 0;

        #10
        if (signals == `SIG_BNE)
            $display("Branch Signals are OK");
        else
            $display("Branch Signals Fail");

        if (id_signal_forwarding == `HAZ_ID_RS__ID_RT)
            $display("Branch Hazard Detection Signals OK");
        else
            $display("Branch Hazard Detection Signals Fail");

        if (id_branch_delay_slot)
            $display("Instruction will branch to a defined Address - SUCCESS");
        else
            $display("Instruction won't branch to a defined Address - FAIL");

        #10
        id_opcode = `OPCODE_BNE;
        id_cmp_eq = 1;

        #10
        if (signals == `SIG_NOP)
            $display("Branch Signals are OK");
        else
            $display("Branch Signals Fail");

        if (id_branch_delay_slot)
            $display("Instruction will branch to a defined Address - FAIL");
        else
            $display("Instruction won't branch to a defined Address - SUCCESS");

        #10
        id_opcode = `OPCODE_JAL;

        #10
        if (signals == `SIG_JUMP_LINK)
            $display("Jump Link Signals are OK");
        else
            $display("Jump Link Signals Fail");

        if (id_branch_delay_slot)
            $display("Instruction will jump to a defined Address - SUCCESS");
        else
            $display("Instruction won't jump to a defined Address - FAIL");

        #10
        id_opcode = `OPCODE_TYPE_R;
        id_funct  = `FUNCT_JR;

        #10
        if (signals == `SIG_JUMP_REG)
            $display("Jump Register Signals are OK");
        else
            $display("Jump Register Signals Fail");

        if (id_branch_delay_slot)
            $display("Instruction will jump to a defined Address - SUCCESS");
        else
            $display("Instruction won't jump to a defined Address - FAIL");

        #10
        id_opcode = `OPCODE_LW;
        #10
        if (signals == `SIG_LOAD_WORD)
            $display("Load Signals are OK");
        else
            $display("Load Signals Fail");

        if (id_alu_op == `ALUOP_ADDU)
            $display("Load Alu Operation is OK");
        else
            $display("Load Alu Operation Fail");

        if (id_signal_forwarding == `HAZ_EX_RS)
            $display("Load Hazard Detection Signals OK");
        else
            $display("Load Hazard Detection Signals Fail");

        #10
        id_opcode = `OPCODE_SW;
        #10
        if (signals == `SIG_STORE_WORD)
            $display("Store Signals are OK");
        else
            $display("Store Signals - Fail");

        if (id_alu_op == `ALUOP_ADDU)
            $display("Store Alu Operation is OK");
        else
            $display("Store Alu Operation Fail");

        if (id_signal_forwarding == `HAZ_EX_RS__WB_RT)
            $display("Store Hazard Detection Signals OK");
        else
            $display("Store Hazard Detection Signals Fail");



    end

endmodule // TB_ControlUnity

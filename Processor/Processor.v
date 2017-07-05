`timescale 1ns / 1ps

`include "Constants.v"

module Processor (
    input clock,
    input reset,

    output [31:0]   if_pc_fetch_address_out,
    input  [31:0]   if_instruction_in,

    output          me_memory_write_out,
    output          me_memory_read_out,
    output [31:0]   me_memory_data_write_out,
    input  [31:0]   me_memory_data_read_in
);

    parameter INSTRUCTIONS = "C:/Outros/MI-SD/TEC499-Sistemas-Digitais/inst_jump_branch.txt";

    /* IF Stage Signals */
    wire        if_stall;       //Should Stall IF?
    wire        if_flush;       //Should Flush IF?
    wire [31:0] if_pc;          //PC for JAL
    wire [31:0] if_pc_out;      //PC selected in mux
    wire [31:0] if_pc_usable;   //PC Delayed
    wire [31:0] if_pc_add_4;    //PC + 4
    wire [31:0] if_instruction; //Instruction Fetched
    wire        if_bra_delay;   //Is this instruction a Branch Delay?

    /* ID Stage Signals */
    //Control
    wire        id_stall;       //Should Stall ID?
    wire        id_reg_dst;     //What is the destination register? RD or RT?
    wire        id_alu_src;     //Should Use Immediate or Register Value?
    wire        id_mem_write;   //Will we write on the memory?
    wire        id_mem_read;    //Will we read the memory?
    wire        id_mem_to_reg;  //Is this a Load operation?
    wire        id_reg_write;   //Will we write the memory?
    wire        id_cmp_eq;      //Are R1 and R2 equals? (used for branch on equal/not equal)
    wire        id_sign_extend; //Should we sign extend the immediate value?
    wire        id_jump_link;   //Is this a JAL operation?
    wire [4:0]  id_alu_op;      //What is the operation that the ALU should execute?
    wire        id_branch_delay_slot; //Did ID recognized that we are branching?

    //Forwarding
    // Forwarding
    wire [1:0]  id_fwd_rs_sel;  //What value for RS should we select EX, ME, WB or the one we read?
    wire [1:0]  id_fwd_rt_sel;  //The same thing, but its RT
    wire        id_w_rs_ex;     //The value is wanted from ex, can it be fowarded?
    wire        id_n_rs_ex;     //The value is needed from ex, and it's not ready, INTERROMPA A CONTAGEM!
    wire        id_w_rt_ex;     //The same wanted stuff but with RT
    wire        id_n_rt_ex;     //Same but it is RT

    // PC Jump / Branch
    wire [1:0]  id_pc_source_sel;   //What PC should we use? PC+4, Jump Address, Branch Address, Register Address?

    // General
    wire [4:0]  id_rs = id_instruction[25:21];      //Extract the value of rs from instruction
    wire [4:0]  id_rt = id_instruction[20:16];      //Extract the value of rt from instruction
    wire [5:0]  id_opcode = id_instruction[31:26];  //Extract the opcode
    wire [5:0]  id_funct = id_instruction[5:0];     //Extract the funct
    wire [31:0] id_reg1_data;                       //Data read from register
    wire [31:0] id_reg1_end;                        //Data forwarded or not in this stage
    wire [31:0] id_reg2_data;                       //Data read from register
    wire [31:0] id_reg2_end;                        //Data forwarded or not in this stage
    wire [31:0] id_immediate = id_instruction[15:0]; //Extract the immediate from instruction
    wire [31:0] id_instruction;                     //The instruction
    wire [31:0] id_pc_add_4;                        //The PC+4 used for branch calculation
    wire [31:0] id_pc;                              //The PC used for JAL
    wire [31:0] id_jump_address = id_instruction[25:0]; //Extract the jump address from instruction
    wire [31:0] id_jump_address_usable = {id_pc_add_4[31:28], id_jump_address[25:0], 2'b00}; //Jump address that can be used in case of jump
    wire [31:0] id_sign_extended_immediate = (id_sign_extend & id_immediate[15]) ? {14'h3fff, id_immediate[15:0]} : {14'h0000, id_immediate[15:0]}; //Sign extended immediate TODO: Line can be better
    wire [31:0] id_immediate_left_shifted2 = {id_sign_extended_immediate[29:0], 2'b00}; //Relative branch address
    wire [31:0] id_branch_address;                  //The actual branch address

    /* EX Stage Signals */
    // Control
    wire        ex_stall;               //TODO Track (Unused? [Y : N])
    wire        ex_mem_read;            //Control Signals in EX stage
    wire        ex_mem_write;
    wire        ex_mem_to_reg;
    wire        ex_reg_write;
    wire        ex_alu_src;
    wire        ex_jump_link;
    wire [1:0]  ex_jump_link_reg_dst;
    wire [4:0]  ex_alu_op;

    // Forwarding
    wire [1:0]  ex_fwd_rs_sel;          //Forwarding in EX stage
    wire [1:0]  ex_fwd_rt_sel;
    wire        ex_w_rs_ex;
    wire        ex_n_rs_ex;
    wire        ex_w_rt_ex;
    wire        ex_n_rt_ex;

    // General
    wire [4:0]  ex_rs;          //Stuff from ID on EX Stage
    wire [4:0]  ex_rt;
    wire [4:0]  ex_rd;
    wire [4:0]  ex_rt_rd;       //The selected Write Register
    wire [4:0]  ex_shamt;       //Shift Ammount
    wire [31:0] ex_reg1_data;   //Data from Register 1
    wire [31:0] ex_reg1_fwd;    //Value from register forwarded
    wire [31:0] ex_reg2_data;   //Data from Register 2
    wire [31:0] ex_reg2_fwd;    //Value from register forwarded
    wire [31:0] ex_data2_imm;   //This is the value selected to go to the ALU
    wire [31:0] ex_sign_extended_immediate;
    wire [31:0] ex_alu_result;  //The ALU Result
    wire [31:0] ex_pc;          //PC for JAL
    wire        ex_alu_overflow;//Overflow occurred

    /* MEM Stage Signals */
    // Control
    wire        me_mem_read;    //Control signals in mem stage
    wire        me_mem_write;
    wire        me_mem_to_reg;
    wire        me_reg_write;

    // Forwarding
    wire        me_write_data_fwd_sel; //Select the data which is being written in register instead of the value we found previously? (forwarding)

    //General
    wire [4:0]  me_rt_rd;
    wire [31:0] me_alu_result;
    wire [31:0] me_data2_reg;
    wire [31:0] me_pc;
    wire [31:0] me_mem_read_data;
    wire [31:0] me_mem_write_data;

    /* WB Stage Signals */
    wire        wb_mem_to_reg; //Control Signals in WB Stage
    wire        wb_reg_write;
    wire [4:0]  wb_rt_rd;
    wire [31:0] wb_data_memory;
    wire [31:0] wb_alu_result;
    wire [31:0] wb_write_data;



endmodule // Processor

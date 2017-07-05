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

    /* Hazards and Forwarding*/
    wire [7:0]  id_signal_forwarding;
    wire [7:0]  final_signal_forwarding;

    // Forwarding receives the wants and needs from ID and EX
    assign final_signal_forwarding = {id_signal_forwarding[7:4], ex_w_rs_ex, ex_n_rs_ex, ex_w_rt_ex, ex_n_rt_ex};
    // In case of Branch ID sends a signal back to IF
    assign if_bra_delay = id_branch_delay_slot;


    //Processor Operation Starts...

    /*
     * Stage 1 - Instruction Fetch
     */

    //Selects one out of the 4 possible PC Sources
    Multiplex4 #(.WIDTH(32)) PC_Source_Selection_Mux (
        .sel (id_pc_source_sel),        // PC Selector that come from ControlUnity
        .in0 (if_pc_add_4),             // PC + 4 (The default)
        .in1 (id_jump_address_usable),  // PC = Jump Address (in case of jump [J, JAL])
        .in2 (id_branch_address),       // PC = Branch Addres (In case of branch [BEQ, BNE])
        .in3 (id_reg1_end),             // PC = Jump Address (In case of Jump Register [JR])
        .out (if_pc_out)
    );

    // Delays 1 cycle to change the usable PC
    PC_Latch #(.WIDTH(32), .DEFAULT(32'b0)) PC (
        .clock  (clock),
        .reset  (reset),
        .enable (~(if_stall | id_stall)), //In case of stall PC will not change in this cycle
        .D      (if_pc_out),
        .Q      (if_pc_usable)
    );

    //TODO Remove this Instruction Memory from here and place it outside the processor
    InstructionMemoryInterface #(.INSTRUCTION_FILE(INSTRUCTIONS)) instruction_memory (
        .if_stall(if_stall),
        .if_pc_usable(if_pc_usable),
        .if_instruction(if_instruction)
    );

    // PC + 4
    SimpleAdder PC_Increment (
        .A (if_pc_usable),
        .B (32'h00000004),
        .C (if_pc_add_4)
    );

    // The IF ID Pipeline Register
    Instruction_Fetch_Decode_Pipeline IF_ID (
        .clock          (clock),
        .reset          (reset),
        .if_flush       (if_flush),         //Should Flush IF?
        .if_stall       (if_stall),         //Should Stall IF?
        .id_stall       (id_stall),         //Should Stall ID?
        .if_bra_delay   (if_bra_delay),     //TODO TRACK
        .if_pc_add_4    (if_pc_add_4),      //PC + 4 in IF Stage
        .if_pc_usable   (if_pc_usable),     //PC without the + 4
        .if_instruction (if_instruction),   //Instruction in IF Stage
        .id_bra_delay   (id_bra_delay),     //TODO TRACK
        .id_pc_add_4    (id_pc_add_4),      //PC + 4 in ID Stage (out)
        .id_instruction (id_instruction),   //Instruction in ID Stage (out)
        .id_is_flushed  (id_is_flushed),    //Was if_stall activated? If yes, this is a NOP
        .id_pc          (id_pc)             //PC for JAL
    );

    //End of Stage 1

    /**
     * Start of Stage 2 - Instruction Decode
    */

    // Read Registers and Write when needed
    RegisterFile RegisterAccess (
        .clock          (clock),
        .reset          (reset),
        .read_reg1      (id_rs),            //Register Read Address 1
        .read_reg2      (id_rt),            //Register Read Address 2
        .wb_rt_rd       (wb_rt_rd),         //Register Write Address
        .wb_write_data  (wb_write_data),    //Register Write Data
        .wb_reg_write   (wb_reg_write),     //Should Write Data to Register?
        .id_reg1_data   (id_reg1_data),     //Data Read from Register 1
        .id_reg2_data   (id_reg2_data)      //Data Read from Register 2
    );

    //Selects the corrected value for the RS register based on forwarding
    Mux4 #(.WIDTH(32)) ID_RS_Forwarding_Mux (
        .sel (id_fwd_rs_sel),   //Data Selector that came from forwarding unit
        .in0 (id_reg1_data),    //Select the data from register?
        .in1 (me_alu_result),   //Select the data that is in the ME stage
        .in2 (wb_write_data),   //Select the data that is going to be written
        .in3 (32'hxxxxxxxx),    //This will never happen, so we dont care
        .out (id_reg1_end)      //The value forwarded
    );

    //Selects the corrected value for the Rt register based on forwarding (same as RS)
    Mux4 #(.WIDTH(32)) ID_RT_Forwarding_Mux (
        .sel (id_fwd_rt_sel),
        .in0 (id_reg2_data),
        .in1 (me_alu_result),
        .in2 (wb_write_data),
        .in3 (32'hxxxxxxxx),
        .out (id_reg2_end)
    );

    //Compares to see if it is equal, so if this is a branch, we will know if we should branch or not
    Comparator Branch_Antecipation (
        .A      (id_reg1_end), //value from register 1
        .B      (id_reg2_end), //value from register 2
        .Equals (id_cmp_eq)    //Are they equal?
    );

    //Calculates the Target Branch Address
    SimpleAdder Branch_Address_Calculation (
        .A (id_pc_add_4),
        .B (id_immediate_left_shifted2),
        .C (id_branch_address)
    );

    //Creates the Control Signals
    ControlUnity Control (
        .id_stall               (id_stall),
        .id_opcode              (id_opcode),
        .id_funct               (id_funct),
        .id_rs                  (id_rs),
        .id_rt                  (id_rt),
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

    //Forwarding And Hazard Unity
    Forwarding_Hazard_Unity ForwardingHazardControl (
        .sig_hazards    (final_signal_forwarding),
        .id_rs          (id_rs),
        .id_rt          (id_rt),
        .ex_rs          (ex_rs),
        .ex_rt          (ex_rt),
        .ex_rt_rd       (ex_rt_rd),
        .me_rt_rd       (me_rt_rd),
        .wb_rt_rd       (wb_rt_rd),
        .ex_jump_link   (ex_jump_link),
        .ex_reg_write   (ex_reg_write),
        .me_reg_write   (me_reg_write),
        .wb_reg_write   (wb_reg_write),
        .me_mem_read    (me_mem_read),
        .me_mem_write   (me_mem_write),
        .id_stall       (id_stall),
        .ex_stall       (ex_stall),
        .id_fwd_rs_sel  (id_fwd_rs_sel),
        .id_fwd_rt_sel  (id_fwd_rt_sel),
        .ex_fwd_rs_sel  (ex_fwd_rs_sel),
        .ex_fwd_rt_sel  (ex_fwd_rt_sel),
        .me_write_data_fwd_sel  (me_write_data_fwd_sel)
    );

    // The ID EX Pipeline Register
    Instruction_Decode_Execute_Pipeline ID_EX (
        .clock                      (clock),
        .reset                      (reset),
        .id_stall                   (id_stall),
        .ex_stall                   (ex_stall),

        .id_jump_link               (id_jump_link),
        .id_reg_dst                 (id_reg_dst),
        .id_alu_src                 (id_alu_src),
        .id_alu_op                  (id_alu_op),
        .id_mem_read                (id_mem_read),
        .id_mem_write               (id_mem_write),
        .id_mem_to_reg              (id_mem_to_reg),
        .id_reg_write               (id_reg_write),
        .id_rs                      (id_rs),
        .id_rt                      (id_rt),
        .id_w_rs_ex                 (id_signal_forwarding[3]),
        .id_n_rs_ex                 (id_signal_forwarding[2]),
        .id_w_rt_ex                 (id_signal_forwarding[1]),
        .id_n_rt_ex                 (id_signal_forwarding[0]),
        .id_reg1_end                (id_reg1_end),
        .id_reg2_end                (id_reg2_end),
        .id_sign_extended_immediate (id_sign_extended_immediate[16:0]),
        .id_pc                      (id_pc),

        .ex_jump_link               (ex_jump_link),
        .ex_jump_link_reg_dst       (ex_jump_link_reg_dst),
        .ex_alu_src                 (ex_alu_src),
        .ex_alu_op                  (ex_alu_op),
        .ex_mem_read                (ex_mem_read),
        .ex_mem_write               (ex_mem_write),
        .ex_mem_to_reg              (ex_mem_to_reg),
        .ex_reg_write               (ex_reg_write),
        .ex_rs                      (ex_rs),
        .ex_rt                      (ex_rt),
        .ex_w_rs_ex                 (ex_w_rs_ex),
        .ex_n_rs_ex                 (ex_n_rs_ex),
        .ex_w_rt_ex                 (ex_w_rt_ex),
        .ex_n_rt_ex                 (ex_n_rt_ex),
        .ex_reg1_data               (ex_reg1_data),
        .ex_reg2_data               (ex_reg2_data),
        .ex_sign_extended_immediate (ex_sign_extended_immediate),
        .ex_rd                      (ex_rd),
        .ex_shamt                   (ex_shamt),
        .ex_pc                      (ex_pc),
    );

    //Forwarding Unity [This also selects the JAL Register]
    Multiplex4 #(.WIDTH(32)) EX_RS_Forwarding_Mux (
        .sel (ex_fwd_rs_sel),   //Selector
        .in0 (ex_reg1_data),    //00 - Register Data
        .in1 (me_alu_result),   //01 - Data on ME
        .in2 (wb_write_data),   //10 - Data on WB
        .in3 (ex_pc),           //11 - JAL [PC]
        .out (ex_reg1_fwd)
    );

    //Forwarding Unity [This also selects the JAL Offset(PC + 4)]
    Multiplex4 #(.WIDTH(32)) EX_RT_Forwarding_Mux (
        .sel (ex_fwd_rt_sel),   //Selector
        .in0 (ex_reg2_data),    //00 - Register Data
        .in1 (me_alu_result),   //01 - Data on ME
        .in2 (wb_write_data),   //10 - Data on WB
        .in3 (32'h00000004),    //11 - JAL [4]
        .out (ex_reg2_fwd)
    );

    //Use the immediate or data from registers? (take decision based on Control Signal)
    assign ex_data2_imm = (ex_alu_src) ? ex_sign_extended_immediate : ex_reg2_fwd;

    //Select the destination Register
    Multiplex4 #(.WIDTH(5)) EX_Reg_Destination_Mux (
        .sel (ex_jump_link_reg_dst),    //Selector
        .in0 (ex_rt),                   //00 - Select RT
        .in1 (ex_rd),                   //01 - Select RD
        .in2 (5'b11111),                //10 - Select Register 31 (JAL)
        .in3 (5'bxxxxx),                //11 - Never happening
        .out (ex_rt_rd)
    );

    //Do the math
    ArithmeticLogicUnit ALU (
        .clock      (clock),
        .reset      (reset),
        .stall      (ex_stall),
        .A          (ex_reg1_fwd),
        .B          (ex_data2_imm),
        .operation  (ex_alu_op),
        .shamt      (ex_shamt),
        .result     (ex_alu_result),
        .overflow   (ex_alu_overflow),
    );





endmodule // Processor

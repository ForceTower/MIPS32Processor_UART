`timescale 1ns / 1ps

module Forwarding_Hazard_Unity (
    input [7:0]     sig_hazards,    //Hazards declared in Control Unity
    input [4:0]     id_rs,          //RS in ID
    input [4:0]     id_rt,          //RT in ID
    input [4:0]     ex_rs,          //RS in EX
    input [4:0]     ex_rt,          //RT in EX
    input [4:0]     ex_rt_rd,       //Destination Register in EX
    input [4:0]     me_rt_rd,       //Destination Register in ME
    input [4:0]     wb_rt_rd,       //Destination Register in WB
    input           ex_jump_link,   //Is a Jump and link in EX
    input           ex_reg_write,   //Will Write to a register whatever EX produces
    input           me_reg_write,   //Will Write to a register whatever ME produces
    input           wb_reg_write,   //Will Write to a register whatever WB produces
    input           me_mem_read,    //Are we reading memory?
    input           me_mem_write,   //Are we writing to memory?
    input           me_mem_to_reg,  //Is this a load instruction in ME?

    output          id_stall,       //Should we stall ID?
    output          ex_stall,       //Should we Stall EX?
    output [1:0]    id_fwd_rs_sel,  //What value should we select in ID for RS? 00 - The Register value // 01 - Data in ME // 10 - Data in WB
    output [1:0]    id_fwd_rt_sel,  //What value should we select in ID for RT? 00 - The Register value // 01 - Data in ME // 10 - Data in WB
    output [1:0]    ex_fwd_rs_sel,  //What value should we select in EX for RS? 00 - The Register value // 01 - Data in ME // 10 - Data in WB
    output [1:0]    ex_fwd_rt_sel,  //What value should we select in EX for RT? 00 - The Register value // 01 - Data in ME // 10 - Data in WB
    output          me_write_data_fwd_sel //What data should be forwarded in ME stage? The data we have made by EX or something that is bein written now?
);

    //Want and Need Dynamic
    //If we want a value it means we are going to use it in the future, and if it can be forwarded right now, it would be good;
    //If we need a value it means that if this value is not ready at this time, we need to stall the pipeline and wait for the data to be ready
    wire w_rs_id; //It wants the data from RS in ID stage (Any R types and some other)
    wire n_rs_id; //It NEEDS the data from RS in ID stage (branches for example needs the value to compare and branch)
    wire w_rt_id; //It wants the data from RT in ID stage (Any R types and some other)
    wire n_rt_id; //It NEEDS the data from RT in ID stage (branches for example needs the value to compare and branch)
    wire w_rs_ex; //It wants the data from RS in EX stage
    wire n_rs_ex; //It NEEDS the data from RS in EX stage (R types and other)
    wire w_rt_ex; //It wants the data from RT in EX stage
    wire n_rt_ex; //It NEEDS the data from RT in EX stage (R types and other)

    //This all comes from the input generated by control
    assign w_rs_id = sig_hazards[7];
    assign n_rs_id = sig_hazards[6];
    assign w_rt_id = sig_hazards[5];
    assign n_rt_id = sig_hazards[4];
    assign w_rs_ex = sig_hazards[3];
    assign n_rs_ex = sig_hazards[2];
    assign w_rt_ex = sig_hazards[1];
    assign n_rt_ex = sig_hazards[0];

    //On load we know for sure that the result will be stored in RT
    wire [4:0] mem_rt = me_rt_rd;

    wire ex_rt_rd_not_zero = (ex_rt_rd != 5'b00000);
    wire me_rt_rd_not_zero = (me_rt_rd != 5'b00000);
    wire wb_rt_rd_not_zero = (wb_rt_rd != 5'b00000);

    //This conditions are in Duarte's Slides and MIPS Book
    //RS in ID By EX? If RS in ID == Destination of EX and it's destination is not zero and we are writing in the register, do we need or want the value?
    //Same goes for the others
    wire rs_id_ex = (id_rs == ex_rt_rd) & ex_rt_rd_not_zero & (w_rs_id | n_rs_id) & ex_reg_write;
    wire rt_id_ex = (id_rt == ex_rt_rd) & ex_rt_rd_not_zero & (w_rt_id | n_rt_id) & ex_reg_write;
    wire rs_id_me = (id_rs == me_rt_rd) & me_rt_rd_not_zero & (w_rs_id | n_rs_id) & me_reg_write;
    wire rt_id_me = (id_rt == me_rt_rd) & me_rt_rd_not_zero & (w_rt_id | n_rt_id) & me_reg_write;
    wire rs_id_wb = (id_rs == wb_rt_rd) & wb_rt_rd_not_zero & (w_rs_id | n_rs_id) & wb_reg_write;
    wire rt_id_wb = (id_rt == wb_rt_rd) & wb_rt_rd_not_zero & (w_rt_id | n_rt_id) & wb_reg_write;

    wire rs_ex_me = (ex_rs == me_rt_rd) & me_rt_rd_not_zero & (w_rs_ex | n_rs_ex) & me_reg_write;
    wire rt_ex_me = (ex_rt == me_rt_rd) & me_rt_rd_not_zero & (w_rt_ex | n_rt_ex) & me_reg_write;
    wire rs_ex_wb = (ex_rs == wb_rt_rd) & wb_rt_rd_not_zero & (w_rs_ex | n_rs_ex) & wb_reg_write;
    wire rt_ex_wb = (ex_rt == wb_rt_rd) & wb_rt_rd_not_zero & (w_rt_ex | n_rt_ex) & wb_reg_write;

    wire rt_me_wb = (mem_rt == wb_rt_rd) & wb_rt_rd_not_zero & wb_reg_write;


    //Conditions to Stall ID:
    //Ok, we would like that data in EX to RS, but... Is it needed right now? (if yes, INTERROMPA A CONTAGEM!!!!)
    wire id_stall_1 = (rs_id_ex & n_rs_id);
    wire id_stall_2 = (rt_id_ex & n_rt_id);
    //Ok, we would like that data that is currently in ME... But is it needed right now??? And most important are we reading or writing the memory?
    // (if we reading the memory, the data will not be ready at all, we need to know the read data before Forwarding)
    // (if we writing the memory, the data is being used as an address we should not modify this address)
    wire id_stall_3 = (rs_id_me & (me_mem_read | me_mem_write) & n_rs_id);
    wire id_stall_4 = (rt_id_me & (me_mem_read | me_mem_write) & n_rt_id);

    // We want a data? Forward it!
    wire id_fwd_1 = (rs_id_me & ~(me_mem_read | me_mem_write));
    wire id_fwd_2 = (rt_id_me & ~(me_mem_read | me_mem_write));
    wire id_fwd_3 = (rs_id_wb);
    wire id_fwd_4 = (rt_id_wb);

    //Same as before but now its with EX
    wire ex_stall_1 = (rs_ex_me & (me_mem_read | me_mem_write) & n_rs_ex);
    wire ex_stall_2 = (rt_ex_me & (me_mem_read | me_mem_write) & n_rt_ex);

    wire ex_fwd_1 = (rs_ex_me & ~(me_mem_read | me_mem_write));
    wire ex_fwd_2 = (rt_ex_me & ~(me_mem_read | me_mem_write));
    wire ex_fwd_3 = (rs_ex_wb);
    wire ex_fwd_4 = (rt_ex_wb);

    //Same as before but now its ME
    wire me_fwd_1 = (rt_me_wb);

    //Stall if any these conditions matches
    assign ex_stall = (ex_stall_1 | ex_stall_2);
    assign id_stall = (id_stall_1 | id_stall_2 | id_stall_3 | id_stall_4) | ex_stall;

    //Assign the values for the selectors on ID Stage based on forwarding
    assign id_fwd_rs_sel = (id_fwd_1) ? 2'b01 : ( (id_fwd_3) ? 2'b10 : 2'b00 );
    assign id_fwd_rt_sel = (id_fwd_2) ? 2'b01 : ( (id_fwd_4) ? 2'b10 : 2'b00 );

    //Assign the values for the selectors on EX Stage based on forwarding
    assign ex_fwd_rs_sel = (ex_jump_link) ? 2'b11 : ( (ex_fwd_1) ? 2'b01 : ( (ex_fwd_3) ? 2'b10 : 2'b00) );
    assign ex_fwd_rt_sel = (ex_jump_link) ? 2'b11 : ( (ex_fwd_2) ? 2'b01 : ( (ex_fwd_4) ? 2'b10 : 2'b00) );

    //Assign the values for the selectors on ME Stage based on forwarding
    assign me_write_data_fwd_sel = (me_fwd_1);

endmodule // Forwarding_Hazard_Unity

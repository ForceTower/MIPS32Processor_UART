`timescale 1ns / 1ps
`include "Constants.v"

module TB_Forwarding_Hazard_Unity ();
    reg [7:0]     sig_hazards;    //Hazards declared in Control Unity
    reg [4:0]     id_rs;          //RS in ID
    reg [4:0]     id_rt;          //RT in ID
    reg [4:0]     ex_rs;          //RS in EX
    reg [4:0]     ex_rt;          //RT in EX
    reg [4:0]     ex_rt_rd;       //Destination Register in EX
    reg [4:0]     me_rt_rd;       //Destination Register in ME
    reg [4:0]     wb_rt_rd;       //Destination Register in WB
    reg           ex_jump_link;   //Is a Jump and link in EX
    reg           ex_reg_write;   //Will Write to a register whatever EX produces
    reg           me_reg_write;   //Will Write to a register whatever ME produces
    reg           wb_reg_write;   //Will Write to a register whatever WB produces
    reg           me_mem_read;    //Are we reading memory?
    reg           me_mem_write;   //Are we writing to memory?
    reg           me_mem_to_reg;  //Is this a load instruction in ME?


    wire          id_stall;       //Should we stall ID?
    wire          ex_stall;       //Should we Stall EX?
    wire [1:0]    id_fwd_rs_sel;  //What value should we select in ID for RS? 00 - The Register value // 01 - Data in ME // 10 - Data in WB
    wire [1:0]    id_fwd_rt_sel;  //What value should we select in ID for RT? 00 - The Register value // 01 - Data in ME // 10 - Data in WB
    wire [1:0]    ex_fwd_rs_sel;  //What value should we select in EX for RS? 00 - The Register value // 01 - Data in ME // 10 - Data in WB
    wire [1:0]    ex_fwd_rt_sel;  //What value should we select in EX for RT? 00 - The Register value // 01 - Data in ME // 10 - Data in WB
    wire          me_write_data_fwd_sel; //What data should be forwarded in ME stage? The data we have made by EX or something that is bein written now?


    Forwarding_Hazard_Unity ForwardingHazardControl (
        .sig_hazards    (sig_hazards),
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
        .me_mem_to_reg  (me_mem_to_reg),
        .id_stall       (id_stall),
        .ex_stall       (ex_stall),
        .id_fwd_rs_sel  (id_fwd_rs_sel),
        .id_fwd_rt_sel  (id_fwd_rt_sel),
        .ex_fwd_rs_sel  (ex_fwd_rs_sel),
        .ex_fwd_rt_sel  (ex_fwd_rt_sel),
        .me_write_data_fwd_sel  (me_write_data_fwd_sel)
    );


    initial begin
        #10
        sig_hazards <= `HAZ_ID_RS__ID_RT;
        id_rs = 5'd1;
        id_rt = 5'd2;

        ex_rs = 5'd3;
        ex_rt = 5'd4;

        ex_rt_rd = 5'd1;
        me_rt_rd = 5'd2;
        wb_rt_rd = 5'd3;

        ex_reg_write = 1;
        me_reg_write = 1;
        wb_reg_write = 1;

        me_mem_read  = 0;
        me_mem_write = 0;

        #10
        if (id_stall == 1)
            $display ("Stall when need value Branch - OK");

        #10
        id_rs = 5'd1;
        id_rt = 5'd2;

        ex_rs = 5'd3;
        ex_rt = 5'd4;

        ex_rt_rd = 5'd3;
        me_rt_rd = 5'd1;
        wb_rt_rd = 5'd2;

        #10
        if (id_fwd_rs_sel == 2'b01)
            $display ("Forwarding ME/ID RS - OK");
        else
            $display ("Forwarding ME/ID RS - FAIL");
        if (id_fwd_rt_sel == 2'b10)
            $display ("Forwarding WB/ID RT - OK");
        else
            $display ("Forwarding WB/ID RS - FAIL");

        #10
        me_rt_rd = 5'd2;
        wb_rt_rd = 5'd1;

        #10
        if (id_fwd_rs_sel == 2'b10)
            $display ("Forwarding WB/ID RS - OK");
        else
            $display ("Forwarding WB/ID RS - FAIL");
        if (id_fwd_rt_sel == 2'b01)
            $display ("Forwarding ME/ID RT - OK");
        else
            $display ("Forwarding ME/ID RT - FAIL");

        #10
        sig_hazards <= `HAZ_EX_RS__EX_RT;
        ex_rs = 5'd1;
        ex_rt = 5'd2;

        ex_rt_rd = 5'd6;
        me_rt_rd = 5'd1;
        wb_rt_rd = 5'd2;

        ex_reg_write = 1;
        me_reg_write = 1;
        wb_reg_write = 1;

        me_mem_read  = 0;
        me_mem_write = 0;
        ex_jump_link = 0;

        #10
        if (ex_fwd_rs_sel == 2'b01)
            $display ("Forwarding ME/EX RS - OK");
        else
            $display ("Forwarding ME/EX RS - FAIL");
        if (ex_fwd_rt_sel == 2'b10)
            $display ("Forwarding WB/EX RT - OK");
        else
            $display ("Forwarding WB/EX RT - FAIL");

        #10
        me_rt_rd = 5'd2;
        wb_rt_rd = 5'd1;

        #10
        if (ex_fwd_rs_sel == 2'b10)
            $display ("Forwarding WB/EX RS - OK");
        else
            $display ("Forwarding WB/EX RS - FAIL");
        if (ex_fwd_rt_sel == 2'b01)
            $display ("Forwarding ME/EX RT - OK");
        else
            $display ("Forwarding ME/EX RT - FAIL");

        #10
        sig_hazards <= `HAZ_EX_RS__WB_RT;
        me_rt_rd = 5'd1;
        wb_rt_rd = 5'd1;
        me_reg_write = 0;

        #10
        if (me_write_data_fwd_sel == 1)
            $display ("Forwarding WB/ME RT - OK");
        else
            $display ("Forwarding WB/ME RT - FAIL");

        #10
        sig_hazards <= `HAZ_EX_RS__EX_RT;
        ex_rs = 5'd1;
        ex_rt = 5'd2;

        me_rt_rd = 5'd1;
        me_mem_read  = 1;
        me_reg_write = 1;

        ex_jump_link = 0;

        #10
        if (ex_stall == 1)
            $display ("Stall EX when need value Load Value - OK");
        else
            $display ("Stall EX when need value Load Value - FAIL");

        #10
        me_mem_read  = 0;
        me_mem_write = 1;
        me_reg_write = 0;

        #10
        if (ex_stall == 0)
            $display ("Stall EX when need value Only on Load Value - OK");
        else
            $display ("Stall EX when need value Only on Load Value - FAIL");

        #10
        ex_jump_link = 1;

        #10
        if (ex_fwd_rs_sel == 2'b11)
            $display ("Jump Link RS - OK");
        else
            $display ("Jump Link RS - FAIL");
        if (ex_fwd_rt_sel == 2'b11)
            $display ("Jump Link RT - OK");
        else
            $display ("Jump Link RT - FAIL");

    end

endmodule // TB_Forwarding_Hazard_Unity

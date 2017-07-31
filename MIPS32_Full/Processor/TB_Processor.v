`timescale 1ns / 1ps

module TB_Processor ();
    reg clock;
    reg reset;

    wire [31:0] dif_instruction;
    wire [31:0] dif_pc_usable;
    wire [31:0] did_instruction;
    wire [31:0] did_pc_usable;
    wire [31:0] did_rt_data;
    wire [31:0] did_rs_data;
    wire [31:0] did_se_immediate;
    wire [4:0]  did_rt;
    wire [4:0]  did_rs;
    wire [31:0] dwb_write_data;
    wire [31:0] dex_alu_result;
    wire [31:0] dex_alu_a;
    wire [31:0] dex_alu_b;
    wire [4:0]  dex_alu_op;
    wire [4:0]  dme_rt_rd;
    wire [31:0] dme_data_mem;
    wire [31:0] dme_data_write_mem;
    wire [4:0]  dwb_rt_rd;
    wire        dif_flush;
    wire        did_flush;
    wire        dex_alu_src;
    wire [1:0]  dex_fwd_rt_sel;
    wire [1:0]  dex_fwd_rs_sel;
    wire        dif_stall;
    wire        did_stall;
    wire        dwb_write_reg;
    wire        dme_write_mem;
    wire        dme_read_mem;
    wire        did_branch_delay_slot;

    Processor #(.INSTRUCTIONS("C:/Outros/MI-SD/TEC499-Sistemas-Digitais/inst_exponential.txt")) MIPS32 (
        .clock                  (clock),
        .reset                  (reset),

        .dif_instruction        (dif_instruction),
        .dif_pc_usable          (dif_pc_usable),
        .did_rt_data            (did_rt_data),
        .did_rs_data            (did_rs_data),
        .did_se_immediate       (did_se_immediate),
        .did_rt                 (did_rt),
        .did_rs                 (did_rs),
        .dex_alu_a              (dex_alu_a),
        .dex_alu_b              (dex_alu_b),
        .dex_alu_result         (dex_alu_result),
        .dme_data_write_mem     (dme_data_write_mem),
        .dme_data_mem           (dme_data_mem),
        .dwb_write_reg          (dwb_write_reg),
        .dwb_write_data         (dwb_write_data),
        .dwb_rt_rd              (dwb_rt_rd)
    );

    integer i = 0;

    initial begin
        clock = 0;
    end

    always begin
        #10
        clock = ~clock;

        $display ("Cycle...........: %d", i);
        $display ("PC..............: %b", dif_pc_usable);
        $display ("Instruction.....: %b", dif_instruction);
        $display ("---------------------");
    end

    always begin
        #20
        i = i + 1;
    end

    initial begin
        reset = 0;
    end
endmodule // TB_Processor

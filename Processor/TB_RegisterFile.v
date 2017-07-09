`timescale 1ns / 1ps

module TB_RegisterFile ();
    reg         clock;
    reg [2:0]   result;

    //Module Inputs
    reg         reset;
    reg [4:0]   read_reg1;
    reg [4:0]   read_reg2;
    reg [4:0]   wb_rt_rd;
    reg         wb_reg_write;
    reg [31:0]  wb_write_data;

    //Module Outputs
    wire [31:0] id_reg1_data;
    wire [31:0] id_reg2_data;

    RegisterFile RegisterAccess (
        .clock          (clock),
        .reset          (reset),

        .read_reg1      (read_reg1),
        .read_reg2      (read_reg2),

        .wb_reg_write   (wb_reg_write),
        .wb_rt_rd       (wb_rt_rd),
        .wb_write_data  (wb_write_data),

        .id_reg1_data   (id_reg1_data),
        .id_reg2_data   (id_reg2_data)
    );

    initial begin
        clock = 1;
    end

    always #10 clock = ~clock;

    initial begin
        reset <= 0;
        result <= 3'd0;

        //Write 500 to Register 3
        read_reg1       <= 5'd3;
        read_reg2       <= 5'd0;

        wb_reg_write    <= 1'd1;
        wb_rt_rd        <= 5'd3;
        wb_write_data   <= 32'd500;

        #20
        //Checks if 500 were saved
        read_reg1       <= 5'd3;
        read_reg2       <= 5'd0;
        //Signal of write is down, it should not save 500
        wb_reg_write    <= 1'd0;
        wb_rt_rd        <= 5'd4;
        wb_write_data   <= 32'd500;

        #10
        if (id_reg1_data == 32'd500)
            result[0] <= 1;

        #10
        //Read Reg 4, it shouldn't have store 500
        read_reg1       <= 5'd4;
        read_reg2       <= 5'd0;
        //Attempt to write in Reg 0
        wb_reg_write    <= 1'd1;
        wb_rt_rd        <= 5'd0;
        wb_write_data   <= 32'd500;
        
        #10
        if (id_reg1_data == 32'd0)
            result[1] <= 1;

        #10
        //Checks if reg 0 were changed, read 2 registers at once
        read_reg1       <= 5'd3;
        read_reg2       <= 5'd0;

        wb_reg_write    <= 1'd0;
        wb_rt_rd        <= 5'd3;
        wb_write_data   <= 32'd500;

        #10
        if (id_reg1_data == 32'd500 & id_reg2_data == 32'd0)
            result[2] <= 1;

        #20

        if (result == 3'd7)
            $display("All Tests Passed");
        else
            $display("Some tests didn't pass");

    end

endmodule // TB_RegisterFile

`timescale 1ns / 1ps
`include "Constants.v"

module TB_ArithmeticLogicUnit ();
    reg [31:0] A;
    reg [31:0] B;
    reg [4:0]  operation;
    reg [4:0]  shamt;

    wire [31:0] result;
    wire        overflow;

    ArithmeticLogicUnit ALU (
        .A          (A),
        .B          (B),
        .operation  (operation),
        .shamt      (shamt),
        .result     (result),
        .overflow   (overflow)
    );

    initial begin
        shamt = 0;
        A = 20;
        B = 10;

        #10
        operation = `ALUOP_ADD;
        #10
        if (result == 32'd30)
            $display("Add Passed");

        #10
        operation = `ALUOP_SUB;
        #10
        if (result == 32'd10)
            $display("Sub Passed");

        #10
        operation = `ALUOP_MUL;
        #10
        if (result == 32'd200)
            $display("Mul Passed");

        #10
        operation = `ALUOP_SLT;
        #10
        if (result == 32'd0)
            $display("Slower Than Passed");

        #10
        A = 5'b01010;
        B = 5'b10010;

        #10
        operation = `ALUOP_OR;
        #10
        if (result == 5'b11010)
            $display("Or Passed");

        #10
        operation = `ALUOP_AND;
        #10
        if (result == 5'b00010)
            $display("And Passed");

        #10
        operation = `ALUOP_NOR;
        #10
        if (result == 32'b11111111111111111111111111100101)
            $display("Nor Passed");

        #10
        A = 32'b10000000000000000000000000000001;
        B = 32'b10000000000000000000000000000001;

        #10
        operation = `ALUOP_ADD;
        #10
        if (overflow == 1'b1)
            $display("Overflow Add Passed");


        #10
        A = 32'b01111111111111111111111111111111;
        B = 32'b10000000000000000000000000000001;
        shamt = 2;

        #10
        operation = `ALUOP_SUB;
        #10
        if (overflow == 1'b1)
            $display("Overflow Sub Passed");


        #10
        A = 32'b11111111111111111111111111111111;
        B = 32'b01111111111111111111111111111111;
        shamt = 2;

        #10
        operation = `ALUOP_SLL;
        #10
        if (result == 32'b11111111111111111111111111111100)
            $display("Sll Passed");

        #10
        operation = `ALUOP_SRL;
        #10
        if (result == 32'b00011111111111111111111111111111)
            $display("Srl Passed");

    end


endmodule // TB_ArithmeticLogicUnit

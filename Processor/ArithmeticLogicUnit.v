`timescale 1ns / 1ps
`include "Constants.v"

module ArithmeticLogicUnit (
    input [31:0]        A,
    input [31:0]        B,
    input [4:0]         operation,
    input signed [4:0]  shamt,

    output reg signed [31:0]    result,
    output reg                  overflow
);

    wire               AddSub;
    wire signed [31:0] A_signed;
    wire signed [31:0] B_signed;
    wire signed [31:0] AddSub_Result;
    wire signed [31:0] Mult_Result;

    assign A_signed = A;
    assign B_signed = B;

    //Wire to Define if its an ADD or a SUB
    assign AddSub = ( (operation == `ALUOP_ADD) | (operation == `ALUOP_ADDU));
    //If it should add, add else subtract
    assign AddSub_Result = (AddSub) ? (A + B) : (A - B);

    //Get the Result of the multiplication as well
    assign Mult_Result = A_signed * B_signed;

    //Assign values to the results [ Do the math ]
    always @ ( * ) begin
        case (operation)
            `ALUOP_ADD  : result <= AddSub_Result;
            `ALUOP_ADDU : result <= AddSub_Result;
            `ALUOP_AND  : result <= (A & B);
            `ALUOP_MUL  : result <= Mult_Result[31:0];
            `ALUOP_NOR  : result <= ~(A | B);
            `ALUOP_OR   : result <= (A | B);
            `ALUOP_SLL  : result <= B << shamt;
            `ALUOP_SLT  : result <= (A_signed < B_signed) ? 32'h00000001 : 32'h00000000;
            `ALUOP_SLTU : result <= (A < B)               ? 32'h00000001 : 32'h00000000;
            `ALUOP_SRL  : result <= B >> shamt;
            `ALUOP_SUB  : result <= AddSub_Result;
            `ALUOP_SUBU : result <= AddSub_Result;
            `ALUOP_XOR  : result <= A ^ B;
            default     : result <= 32'hxxxxxxxx;
        endcase
    end

    //Checks for overflow
    always @ ( * ) begin
        case (operation)
            `ALUOP_ADD : overflow <= ((A[31] ~^ B[31]) & (A[31] ^ AddSub_Result[31]));
            `ALUOP_SUB : overflow <= ((A[31]  ^ B[31]) & (A[31] ^ AddSub_Result[31]));
            default    : overflow <= 0;
        endcase
    end


endmodule // ArithmeticLogicUnit

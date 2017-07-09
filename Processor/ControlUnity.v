`timescale 1ns / 1ps
`include "Constants.v"

module ControlUnity (
    input       id_stall,
    input [5:0] id_opcode,
    input [5:0] id_funct,
    input       id_cmp_eq,

    output              if_flush,
    output reg [7:0]    id_signal_forwarding,
    output     [1:0]    id_pc_source_sel,
    output              id_sign_extend,
    output              id_jump_link,
    output              id_reg_dst,
    output              id_alu_src,
    output              id_branch_delay_slot,
    output reg [4:0]    id_alu_op,
    output              id_mem_write,
    output              id_mem_read,
    output              id_mem_to_reg,
    output              id_reg_write //Comment this line
);

    wire branch, branch_eq, branch_ne;

    reg [8:0] signals;
    assign id_pc_source_sel[0]  = signals[7];
    assign id_jump_link         = signals[6];
    assign id_alu_src           = signals[5];
    assign id_reg_dst           = signals[4];
    assign id_mem_read          = signals[3];
    assign id_mem_write         = signals[2];
    assign id_mem_to_reg        = signals[1];
    assign id_reg_write         = signals[0];

    always @ ( * ) begin
        if (id_stall) begin
            signals <= `SIG_NOP;
        end

        else begin
            case (id_opcode)
                `OPCODE_TYPE_R: begin
                    case (id_funct)
                        `FUNCT_ADD  : begin
                            signals <= `SIG_ADD;
                        end
                        `FUNCT_ADDU : begin
                            signals <= `SIG_ADDU;
                        end
                        `FUNCT_AND  : begin
                            signals <= `SIG_AND;
                        end
                        `FUNCT_JR   : begin
                            signals <= `SIG_JR;
                        end
                        `FUNCT_NOR  : begin
                            signals <= `SIG_NOR;
                        end
                        `FUNCT_OR   : begin
                            signals <= `SIG_OR;
                        end
                        `FUNCT_SLL  : begin
                            signals <= `SIG_SLL;
                        end
                        `FUNCT_SLT  : begin
                            signals <= `SIG_SLT;
                        end
                        `FUNCT_SRL  : begin
                            signals <= `SIG_SRL;
                        end
                        `FUNCT_SUB  : begin
                            signals <= `SIG_SUB;
                        end
                        `FUNCT_SUBU : begin
                            signals <= `SIG_SUBU;
                        end
                        `FUNCT_XOR  : begin
                            signals <= `SIG_XOR;
                        end
                        default     : begin
                            signals <= `SIG_NOP;
                        end
                    endcase
                end

                `OPCODE_TYPE_R_EX: begin
                    case (id_funct)
                        `FUNCT_MUL  : begin
                            signals <= `SIG_MUL;
                        end
                        default     : begin
                            signals <= `SIG_NOP;
                        end
                    endcase
                end

                `OPCODE_ADDI        : begin
                    signals <= `SIG_ADDI;
                end

                `OPCODE_ADDIU       : begin
                    signals <= `SIG_ADDIU;
                end

                `OPCODE_SLTI        : begin
                    signals <= `SIG_SLTI;
                end
                `OPCODE_J           : begin
                    signals <= `SIG_J;
                end
                `OPCODE_JAL         : begin
                    signals <= `SIG_JAL;
                end
                `OPCODE_BEQ         : begin
                    signals <= `SIG_BEQ;
                end
                `OPCODE_BNE         : begin
                    signals <= `SIG_BNE;
                end
                `OPCODE_LW          : begin
                    signals <= `SIG_LW;
                end
                `OPCODE_SW          : begin
                    signals <= `SIG_SW;
                end
                default             : begin
                    signals <= `SIG_NOP;
                end
            endcase
        end
    end

    always @ ( * ) begin
        case (id_opcode)
            `OPCODE_TYPE_R : begin
                case (id_funct)
                    `FUNCT_ADD  : id_signal_forwarding <= `HAZ_ADD;
                    `FUNCT_ADDU : id_signal_forwarding <= `HAZ_ADDU;
                    `FUNCT_AND  : id_signal_forwarding <= `HAZ_AND;
                    `FUNCT_JR   : id_signal_forwarding <= `HAZ_JR;
                    `FUNCT_NOR  : id_signal_forwarding <= `HAZ_NOR;
                    `FUNCT_OR   : id_signal_forwarding <= `HAZ_OR;
                    `FUNCT_SLL  : id_signal_forwarding <= `HAZ_SLL;
                    `FUNCT_SLT  : id_signal_forwarding <= `HAZ_SLT;
                    `FUNCT_SLTU : id_signal_forwarding <= `HAZ_SLTU;
                    `FUNCT_SRL  : id_signal_forwarding <= `HAZ_SRL;
                    `FUNCT_SUB  : id_signal_forwarding <= `HAZ_SUB;
                    `FUNCT_SUBU : id_signal_forwarding <= `HAZ_SUBU;
                    `FUNCT_XOR  : id_signal_forwarding <= `HAZ_XOR;
                    default     : id_signal_forwarding <= 8'hxx;
                endcase
            end
            `OPCODE_TYPE_R_EX : begin
                case (id_funct)
                    `FUNCT_MUL  : id_signal_forwarding <= `HAZ_MUL;
				    default     : id_signal_forwarding <= 8'hxx;
                endcase
            end
            `OPCODE_ADDI        : id_signal_forwarding <=  `HAZ_ADDI;
            `OPCODE_ADDIU       : id_signal_forwarding <=  `HAZ_ADDIU;
            `OPCODE_SLTI        : id_signal_forwarding <=  `HAZ_SLTI;
            `OPCODE_SLTIU       : id_signal_forwarding <=  `HAZ_SLTIU;
            `OPCODE_J           : id_signal_forwarding <=  `HAZ_J;
            `OPCODE_JAL         : id_signal_forwarding <=  `HAZ_JAL;
            `OPCODE_BEQ         : id_signal_forwarding <=  `HAZ_BEQ;
            `OPCODE_BNE         : id_signal_forwarding <=  `HAZ_BNE;
            `OPCODE_LW          : id_signal_forwarding <=  `HAZ_LW;
            `OPCODE_SW          : id_signal_forwarding <=  `HAZ_SW;
            default             : id_signal_forwarding <=  8'hxx;
        endcase
    end

    always @ ( * ) begin
        if (id_stall) begin
            id_alu_op <= `ALUOP_ADDU;
        end
        else begin
            case (id_opcode)
                `OPCODE_TYPE_R : begin
                    case (id_funct)
                        `FUNCT_ADD      : id_alu_op <= `ALUOP_ADD;
                        `FUNCT_ADDU     : id_alu_op <= `ALUOP_ADDU;
                        `FUNCT_AND      : id_alu_op <= `ALUOP_AND;
                        `FUNCT_NOR      : id_alu_op <= `ALUOP_NOR;
                        `FUNCT_OR       : id_alu_op <= `ALUOP_OR;
                        `FUNCT_SLL      : id_alu_op <= `ALUOP_SLL;
                        `FUNCT_SLT      : id_alu_op <= `ALUOP_SLT;
                        `FUNCT_SLTU     : id_alu_op <= `ALUOP_SLTU;
                        `FUNCT_SRL      : id_alu_op <= `ALUOP_SRL;
                        `FUNCT_SUB      : id_alu_op <= `ALUOP_SUB;
                        `FUNCT_SUBU     : id_alu_op <= `ALUOP_SUBU;
                        `FUNCT_XOR      : id_alu_op <= `ALUOP_XOR;
                        default         : id_alu_op <= `ALUOP_ADDU;
                    endcase
                end
                `OPCODE_TYPE_R_EX : begin
                    case (id_funct)
                        `FUNCT_MUL      : id_alu_op <= `ALUOP_MUL;
                        default         : id_alu_op <= `ALUOP_ADDU;
                    endcase
                end
                `OPCODE_ADDI        : id_alu_op <= `ALUOP_ADD;
                `OPCODE_ADDIU       : id_alu_op <= `ALUOP_ADDU;
                `OPCODE_JAL         : id_alu_op <= `ALUOP_ADDU;
                `OPCODE_LW          : id_alu_op <= `ALUOP_ADDU;
                `OPCODE_SLTI        : id_alu_op <= `ALUOP_SLT;
                `OPCODE_SLTIU       : id_alu_op <= `ALUOP_SLTU;
                `OPCODE_SW          : id_alu_op <= `ALUOP_ADDU;
                default             : id_alu_op <= `ALUOP_ADDU;
            endcase
        end
    end

    //BEQ => 000100
    assign branch_eq = id_opcode[2] & ~id_opcode[1] & ~id_opcode[0] &  id_cmp_eq;
    //BNE => 000101
    assign branch_ne = id_opcode[2] & ~id_opcode[1] &  id_opcode[0] & ~id_cmp_eq;

    //Did one of the branch conditions match?
    assign branch = (branch_eq | branch_ne);

    // 00 = PC + 4 // 01 = Jump // 10 = Branch // 11 = Jump Register
    assign id_pc_source_sel[1] = (signals[8] & ~signals[7]) ? branch : signals[8];

    assign if_flush = 0; //TODO Remove

    // if it is a BEQ and it is TAKEN!!!!!!!! Flush it OR if it is a jump also flush it
    assign id_branch_delay_slot = (branch & signals[8]) | (signals[7]);

    //Should we sign extend the immediate?
    assign id_sign_extend = (id_opcode[5:2] != 4'b0011);

endmodule // ControlUnity

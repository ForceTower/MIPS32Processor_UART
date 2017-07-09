//Definition of Opcodes
`define OPCODE_TYPE_R       6'b000000 //R type just like add
`define OPCODE_TYPE_R_EX    6'b011100 //R type like mul

`define OPCODE_ADD          `OPCODE_TYPE_R
`define OPCODE_ADDI         6'b001000
`define OPCODE_ADDIU        6'b001001
`define OPCODE_ADDU         `OPCODE_TYPE_R
`define OPCODE_AND          `OPCODE_TYPE_R
`define OPCODE_BEQ          6'b000100
`define OPCODE_BNE          6'b000101
`define OPCODE_J            6'b000010
`define OPCODE_JAL          6'b000011
`define OPCODE_JR           `OPCODE_TYPE_R
`define OPCODE_LW           6'b100011
`define OPCODE_MUL          `OPCODE_TYPE_R_EX
`define OPCODE_NOR          `OPCODE_TYPE_R
`define OPCODE_OR           `OPCODE_TYPE_R
`define OPCODE_SLL          `OPCODE_TYPE_R
`define OPCODE_SLT          `OPCODE_TYPE_R
`define OPCODE_SLTI         6'b001010
`define OPCODE_SLTIU        6'b001011
`define OPCODE_SLTU         `OPCODE_TYPE_R
`define OPCODE_SRL          `OPCODE_TYPE_R
`define OPCODE_SUB          `OPCODE_TYPE_R
`define OPCODE_SUBU         `OPCODE_TYPE_R
`define OPCODE_SW           6'b101011
`define OPCODE_XOR          `OPCODE_TYPE_R

//Definition of Functs
`define FUNCT_ADD           6'b100000
`define FUNCT_ADDU          6'b100001
`define FUNCT_AND           6'b100100
`define FUNCT_JR            6'b001000
`define FUNCT_MUL           6'b000010
`define FUNCT_NOR           6'b100111
`define FUNCT_OR            6'b100101
`define FUNCT_SLL           6'b000000
`define FUNCT_SLT           6'b101010
`define FUNCT_SLTU          6'b101011
`define FUNCT_SRL           6'b000010
`define FUNCT_SUB           6'b100010
`define FUNCT_SUBU          6'b100011
`define FUNCT_XOR           6'b100110

//Definition of ALU Operations
`define ALUOP_ADDU          5'd0
`define ALUOP_ADD           5'd1
`define ALUOP_AND           5'd2
`define ALUOP_MUL           5'd15
`define ALUOP_NOR           5'd18
`define ALUOP_OR            5'd19
`define ALUOP_SLL           5'd20
`define ALUOP_SLT           5'd23
`define ALUOP_SLTU          5'd24
`define ALUOP_SRL           5'd27
`define ALUOP_SUB           5'd29
`define ALUOP_SUBU          5'd30
`define ALUOP_XOR           5'd31

// Control Signals
// 8-7:
//      11 - JR
//      10 - Branch
//      01 - Jump Immediate
//      00 - Nothing
// 6: Jump And Link
// 5: ALU Src
// 4: RegDst
// 3: MemRead
// 2: MemWrite
// 1: MemToReg
// 0: RegWrite

`define SIG_NOP             9'b000000000    // Nop
`define SIG_R_TYPE          9'b000010001    // R Type
`define SIG_I_TYPE          9'b000100001    // I Type
`define SIG_BRANCH          9'b100000000    // Branch
`define SIG_JUMP            9'b010000000    // Jump
`define SIG_JUMP_LINK       9'b011000001    // Jump and Link
`define SIG_JUMP_REG        9'b110000000    // Jump Register
`define SIG_LOAD_WORD       9'b000101011    // Load Word
`define SIG_STORE_WORD      9'b000100100    // Store Word

//Place into every opcode
`define SIG_ADD             `SIG_R_TYPE
`define SIG_ADDI            `SIG_I_TYPE
`define SIG_ADDIU           `SIG_I_TYPE
`define SIG_ADDU            `SIG_R_TYPE
`define SIG_AND             `SIG_R_TYPE
`define SIG_BEQ             `SIG_BRANCH
`define SIG_BNE             `SIG_BRANCH
`define SIG_J               `SIG_JUMP
`define SIG_JAL             `SIG_JUMP_LINK
`define SIG_JR              `SIG_JUMP_REG
`define SIG_LW              `SIG_LOAD_WORD
`define SIG_MUL             `SIG_R_TYPE
`define SIG_NOR             `SIG_R_TYPE
`define SIG_OR              `SIG_R_TYPE
`define SIG_SLL             `SIG_R_TYPE
`define SIG_SLT             `SIG_R_TYPE
`define SIG_SLTI            `SIG_I_TYPE
`define SIG_SLTU            `SIG_R_TYPE
`define SIG_SRL             `SIG_R_TYPE
`define SIG_SUB             `SIG_R_TYPE
`define SIG_SUBU            `SIG_R_TYPE
`define SIG_SW              `SIG_STORE_WORD
`define SIG_XOR             `SIG_R_TYPE

/**
 * 7 - Wants RS in ID
 * 6 - Needs RS in ID
 * 5 - Wants RT in ID
 * 4 - Needs RT in ID
 * 3 - Wants RS in EX
 * 2 - Needs RS in EX
 * 1 - Wants RT in EX
 * 0 - Needs RT in EX
 */
`define HAZ_NONE            8'b00000000    // Jumps
`define HAZ_ID_RS__ID_RT    8'b11110000    // Beq, Bne
`define HAZ_ID_RS           8'b11000000    // Branch, JR
`define HAZ_EX_RS__EX_RT    8'b10101111    // R-Type
`define HAZ_EX_RS           8'b10001100    // Immediate Operations
`define HAZ_EX_RS__WB_RT    8'b10101110    // Stores
`define HAZ_EX_RT           8'b00100011    // Shifts that uses Shamt

`define HAZ_ADD            `HAZ_EX_RS__EX_RT
`define HAZ_ADDI           `HAZ_EX_RS
`define HAZ_ADDIU          `HAZ_EX_RS
`define HAZ_ADDU           `HAZ_EX_RS__EX_RT
`define HAZ_AND            `HAZ_EX_RS__EX_RT
`define HAZ_BEQ            `HAZ_ID_RS__ID_RT
`define HAZ_BNE            `HAZ_ID_RS__ID_RT
`define HAZ_J              `HAZ_NONE
`define HAZ_JAL            `HAZ_NONE
`define HAZ_JR             `HAZ_ID_RS
`define HAZ_LW             `HAZ_EX_RS
`define HAZ_MUL            `HAZ_EX_RS__EX_RT
`define HAZ_NOR            `HAZ_EX_RS__EX_RT
`define HAZ_OR             `HAZ_EX_RS__EX_RT
`define HAZ_SLL            `HAZ_EX_RT
`define HAZ_SLT            `HAZ_EX_RS__EX_RT
`define HAZ_SLTI           `HAZ_EX_RS
`define HAZ_SLTIU          `HAZ_EX_RS
`define HAZ_SLTU           `HAZ_EX_RS__EX_RT
`define HAZ_SRL            `HAZ_EX_RT
`define HAZ_SUB            `HAZ_EX_RS__EX_RT
`define HAZ_SUBU           `HAZ_EX_RS__EX_RT
`define HAZ_SW             `HAZ_EX_RS__WB_RT
`define HAZ_XOR            `HAZ_EX_RS__EX_RT

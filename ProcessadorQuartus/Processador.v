module Processador(input wire clock);

wire bolha_fase_1_2;

wire [31:0] instrucao;
wire [31:0] pc4;

InstructionFetch IF(.clock(clock), .bolha(bolha_fase_1_2), .instrucao(instrucao), .pc4(pc4));

endmodule 
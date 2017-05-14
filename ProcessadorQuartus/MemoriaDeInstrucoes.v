`ifndef _memoria_instrucoes
`define _memoria_instrucoes

module MemoriaDeInstrucoes(input wire clock, input wire[31:0] endereco, output wire[31:0] instrucao);
	
	//A memoria de instrucoes possui 64 instrucoes de 32 bits
	reg [31:0] instrucoes [0:63];
	
	initial begin //colocar para ler isso de um arquivo ou vir de algum lugar
		instrucoes[0] <= 32'b00100000000100010000000000110010;
		instrucoes[1] <= 32'b00000000000100011001100000100100;
		instrucoes[2] <= 32'b00100000000101000000000000110010;
		instrucoes[3] <= 32'b00000000000100110100100000100101;
		instrucoes[4] <= 32'b00000001001100110101000000100111;
		instrucoes[5] <= 32'b00100000000010110000000100101100;
		instrucoes[6] <= 32'b00010010100100010000000000001000;
		instrucoes[7] <= 32'b00100000000011000000000110010000;
		instrucoes[8] <= 32'b00100001100011010000000111110100;
		instrucoes[9] <= 32'b00000000000010010111000000100010;
		instrucoes[10] <= 32'b00100000000110000000001100100000;
		instrucoes[11] <= 32'b10101110001011110000000000110010;
		instrucoes[12] <= 32'b10001110001010010000000000110010;
		instrucoes[13] <= 32'b00000001001011011011100000100000;
		instrucoes[14] <= 32'b00000010111010011101000000100010;
	end
	
	wire posicao;
	assign posicao = endereco[7:2]; //Se PC é 8 então queremos a posicao 3; como o PC tem 32 bits e nos temos
											  //no maximo 64 instrucoes, então precisamos de apenas 6 bits (0-63)
	
	assign instrucao = instrucoes[posicao][31:0];
	
endmodule 

`endif
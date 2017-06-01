// Modelo de uso
// wire [15:0] a, b;
// wire [15:0] c, d;
// Os valores estarao em C e D no proxima borda ascendente
// RegPipeline #(.TAM(32)) registrador (.clock(clock), .parada(1'b0), .limpar(1'b0), .in({a, b}), .out({c, d});

module RegPipeline(
	input clock, parada, limpar,
	input wire [TAM-1:0] in,
	output reg [TAM-1:0] out
	);
			
	//Quantidade de bits a serem armazenados
	parameter TAM = 32; 
	
	always @ ( posedge clock ) begin // na borda ascendente
		//limpa os valores do registrador
		if (limpar)
			out <= {TAM{1'b0}};
		//mantem a saida
		else if (parada)
			out <= out;
		//atribui uma nova saida
		else
			out <= in;
	end
						 
endmodule 
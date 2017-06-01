module Memoria (
	input wire[31:0] pc,
	output wire[31:0] instrucao
	);
	
	reg [31:0] memoria [0:63];
	
	initial begin
		$readmemb("arquivo.txt", memoria);
	end
	
	assign instrucao = memoria[pc[7:2]][31:0];
endmodule 
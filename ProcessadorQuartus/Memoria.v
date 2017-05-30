module Memoria (input wire[31:0] pc, output wire[31:0] instrucao);
	reg [31:0] memoria [0:63];
	
	initial begin
		memoria[0] = 32'b00100000000010010000000000110010;
		memoria[1] = 32'b00000001001010010100100000100000;
		memoria[2] = 32'b00000001001010010100100000100000;
		memoria[3] = 32'b00000001001010010100100000100000;
		memoria[4] = 32'b00000001001010010100100000100000;
		memoria[5] = 32'b00000001001010010101000000100000;
	end
	
	assign instrucao = memoria[pc[7:2]][31:0];
endmodule 
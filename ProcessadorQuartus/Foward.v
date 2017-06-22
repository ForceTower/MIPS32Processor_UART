//TAKS Alberto Junior
// 1b	-> escrever registrador (fase 4)
// 1b	-> escrever registrador (fase 5)
// 5b	-> numero do registrador de escrita (fase 4)
// 5b	-> numero do registrador de escrita (fase 5)
// 5b	-> registrador RS (fase 3)
// 5b	-> registrador RT (fase 3)
// @Alberto Junior {
//	Sua saida eh simples, devo antecipar A? se sim, de qual estagio?
// Devo antecipar B? se sim, de qual estagio? }

//NAO ATENCIPAR: A = [00], B = [00]
//ESTAGIO 1: A = [10], B = [10]
//ESTAGIO 2: A = [01], B = [01]
module Foward (
	//flag da fase 4 e 5
	input reg_f4, reg_f5, clock,
	//registradores de escrita fase 4 e 5
	input [4:0] escrita_f4, escrita_f5,
	//registradores RS e RT no pipeline fase 3
	input [4:0] RS_f3, RT_f3,
	//sinalizadores de qual fazer fowarding
	output [1:0] fw_A, fw_B
	);

	reg [1:0] A, B;
	always @ ( * ) begin //Isso eh um circuito combinacional. nao depende do clock
		//FOWARD da fase 3 EX/MEM
		//quero escrever e não eh no XZR
		if(reg_f4 && escrita_f4 != 5'b0) begin
			//meu registrador de destino e igual ao RS da fase 3?
			if(escrita_f4 == RS_f3)
				A <= 2'b10; //A = 10
			//meu registrador de destino e igual ao RT da fase 3?
			if(escrita_f4 == RT_f3)
				B <= 2'b10; //B = 10
		end
		//FOWARD da fase 4 MEM/WB
		//quero escrever e não eh no XZR
		else if(reg_f5 && escrita_f5 != 5'b0) begin
			//meu registrador de destino eh igual ao RS da fase 3?
			if(escrita_f5 == RS_f3)
				A <= 2'b01; //A = 01
			//meu registrador de destino eh igual ao RT da fase 3?
			if(escrita_f5 == RT_f3)
				B <= 2'b01; //B = 01
		end
		//se nao antecipar os dados de algum estagio
		else begin
			A <= 2'b0; //A = 00
			B <= 2'b0; //B = 00
		end
	end

	assign fw_A = A;
	assign fw_B = B;

endmodule

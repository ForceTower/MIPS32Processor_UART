module controleALU(	input[5:0] funct, input[1:0] opALU, output[2:0] sinalOperacao);

/* opCode da Instrução | OpAlu | Operação    | Campo Funct | Ação da ALU | Entrada do Controle
	Tipo R 				  |   10  | and         |   100100	  |	  and	    |			000 -
	Tipo R 				  |   10  | or          |   100101	  |	  or	    |			001 -
	LW						  |   00  | load Word   |   xxxxxx 	  |     add     |       010 -
	SW 					  |   00  |	Store Word  |   xxxxxx	  |     add     |			010 -
	Tipo R 				  |   10  | add         |   100000	  |	  add	    |			010 -
	Tipo R 				  |   10  | mul         |   000010    |	  mul 	 |			011 -
	Tipo R 				  |   10  | div         |   011010    |	  div 	 |			100 -
	Tipo R 				  |   10  |             |        	  |	   	    |			101 -
	Branch equal		  |   01  |	Branch equal|   xxxxxx	  |     sub     |			110 -
	Tipo R 				  |   10  | sub         |   100010	  |	  sub	    |			110 -
	Tipo R 				  |   10  | slt         |   101010	  |	  slt	    |			111
 */



	reg [2:0] microSinal;
	always @ ( * ) begin
		if (funct == 6'b100100 && opALU == 2'b10)
			microSinal <= 3'b000;
		else if (funct == 6'b100101 && opALU == 2'b10)
			microSinal <=3'b001;
		else if ((opALU == 2'b00) || (funct == 6'b100000 && opALU == 2'b10))
			microSinal <=3'b010;
		else if (funct == 6'b000010 && opALU == 2'b10)
			microSinal <=3'b011;
		else if (funct == 6'b011010 && opALU == 2'b10)
			microSinal <=3'b100;
		else if ((opALU == 2'b01) || (funct == 6'b100010 && opALU == 2'b10))
			microSinal <=3'b110;
		else if (funct == 6'b101010 && opALU == 2'b10)
			microSinal <=3'b111;
	end

	assign sinalOperacao = microSinal;
endmodule

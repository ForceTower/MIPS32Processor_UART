module ALU(input[31:0] rs, rt, input[2:0] sinalOperacao,output[31:0] resultado, output zero, overflow);

/* Ação da ALU | Entrada do Controle
	  and	    |			000 -
	  or	    |			001 -
     add     |       010 -
 	  mul 	 |			011 -
	  div 	 |			100 -
	   	    |			101 -
	  sub     |			110 -
	  slt	    |			111
*/

// eq $s, $t, offset;  se s = t salta, zero = 1, s != t continua zero = 0; calculo é realizado quando zero = 1

reg [63:0] saida; // 32bits * 32bits = 64bits
reg over, tzero;
	always @ *
	case (sinalOperacao)
	3'b000: // and
		saida = rs & rt;
	3'b001: // or
		saida = rs | rt;
	3'b010: // add
		saida = rs + rt;
	3'b011: // mul
		saida = rs * rt;
	3'b100: // div
		saida = rs / rt;
	3'b110: // sub
		saida = rs - rt;
	3'b111: // slt
		saida = (rs < rt); //Slt rd, rs, rt # if rs <rt, rd = 1; Else rt = 0

	endcase

	always @ ( * ) begin

		if(saida[63:32] > 32'b0)
			over = 1'b1;
		else
			over = 1'b0;
		if(saida == 1'b0)
			tzero = 1'b1; // ativa a flag
		else
			tzero = 1'b0;// permanece com o PC

	end

assign resultado = saida[31:0];
assign overflow = over;
assign zero = tzero;

endmodule

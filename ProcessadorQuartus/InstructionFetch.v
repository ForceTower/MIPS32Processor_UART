`ifndef _instruction_fetch
`define _instruction_fetch

module InstructionFetch(input clock, input bolha, output wire[31:0] instrucao, output wire [31:0] pc4);

	reg [31:0] pc;
	
	initial begin
		pc <= 32'd0;
	end
	
	assign pc4 = pc + 4;
	
	always @(posedge clock) begin //faltam condicoes de branch e enderecos de branch que vao chegar aqui a partir de inputs da fase 4
		if (bolha)
			pc <= pc;
		else
			pc <= pc4;
	end
	
	MemoriaDeInstrucoes INSTRUCOES(.clock(clock), .endereco(pc), .instrucao(instrucao));
	
endmodule	

`endif
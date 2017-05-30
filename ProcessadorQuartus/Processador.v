module Processador(input clock, output wire[31:0] t_pc, t_inst);
	reg [31:0] pc;
	initial begin
		pc <= 32'd0;
	end
	
	reg [31:0] pc4;
	always @(posedge ~clock) begin
		pc <= pc + 4;
	end
	
	wire [31:0] instrucao;
	Memoria memoria (.pc(pc), .instrucao(instrucao));
	
	
	
	wire[31:0] pc_2, instrucao_2;
	RegPipeline #(.TAM(32)) if_id_pc (.clock(clock), .parada(1'b0), .limpar(1'b0), .in(pc), . out(pc_2));
	RegPipeline #(.TAM(32)) if_id_inst (.clock(clock), .parada(1'b0), .limpar(1'b0), .in(instrucao), . out(instrucao_2));
	
	assign t_pc = pc_2;
	assign t_inst = instrucao_2;
	
	wire[5:0] opcode;
	wire[4:0] rs, rt, rd;
	wire[4:0] shift;
	wire[5:0] funct;
	wire[15:0] imediato;
	
	/*
	 separacao da instrucao em suas respectivas partes de acordo com a literatura
	*/
	assign opcode = instrucao_2[31:26];
	assign rs = instrucao_2[25:21];
	assign rt = instrucao_2[20:16];
	assign rd = instrucao_2[15:11];
	assign shift = instrucao_2[11:6];
	assign funct = instrucao_2[5:0];
	assign imediato = instrucao_2[15:0];
	
	wire[31:0] se_imediato;
	
	assign se_imediato = {16{imediato[15]}, imediato};	// extensor de sinal imediato
	
	wire[31:0] out_rs, out_rt
	BancoDeRegistradores registradores(.rs(rs), rt(rt), .rd(rd), .out_rs(out_rs), .out_rt(out_rt));
	
	
	
endmodule 
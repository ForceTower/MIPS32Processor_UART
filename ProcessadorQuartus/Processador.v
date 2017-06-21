module Processador(input clock, output wire[31:0] t_pc, t_inst);
	//
	//				FASE 1 - Instruction Fetch
	//

	reg [31:0] pc; // registrador PC

	initial begin
		pc <= 32'd0; //PC inicia em 0
	end

	wire [31:0] pc4; //Cria o fio que vai guardar PC+4
	assign pc4 = pc + 4; //Coloca o valor PC + 4 no fio

	always @(negedge clock) begin //A cada borda de descida, atualiza o PC
		pc <= pc4; //Por padrao, PC = PC + 4
	end

	wire [31:0] instrucao; // cria o fio que irá guardar a instrucao
	Memoria memoria (.pc(pc), .instrucao(instrucao)); //Busca a instrucao na memoria

	wire[31:0] pc_2, instrucao_2; //Cria 2 fios para passar para proxima fase
	RegPipeline #(.TAM(32)) if_id_pc (.clock(clock), .parada(1'b0), .limpar(1'b0), .in(pc), .out(pc_2)); //Esse registrador deve ser parado em caso de bolha e limpo em caso de branch
	RegPipeline #(.TAM(32)) if_id_inst (.clock(clock), .parada(1'b0), .limpar(1'b0), .in(instrucao), .out(instrucao_2)); //Esse registrador deve ser parado em caso de bolha e limpo em caso de branch

	assign t_pc = pc_2;
	assign t_inst = instrucao_2;

	//
	//				FASE 2 - Instruction Decode
	//

	wire[5:0] opcode; // fio para o opcode
	wire[4:0] rs, rt, rd; // fio para cada registrador
	wire[4:0] shift; // guarda o valor da quantidade de shift
	wire[5:0] funct; // guarda o valor do funct
	wire[15:0] imediato; // o valor imediato que vem na instrucao

	/*
	 separacao da instrucao em suas respectivas partes de acordo com a literatura
	*/
	assign opcode = instrucao_2[31:26];
	assign rs = instrucao_2[25:21];
	assign rt = instrucao_2[20:16];
	assign rd = instrucao_2[15:11];
	assign shift = instrucao_2[10:6];
	assign funct = instrucao_2[5:0];
	assign imediato = instrucao_2[15:0];

	wire[31:0] se_imediato; //Fio para o valor extendido do imediato
	assign se_imediato = {{16{imediato[15]}}, imediato[15:0]};	// extensor de sinal imediato

	wire [31:0] jump_end;         //Endereco de salto que sera usado na fase 4
	assign jump_end = {pc[31:28], instr_2[25:0], 2'b00};

	wire [31:0] branch_end;
	assign branch_end = pc_2 + {se_imediato[29:0], 2'b00}; //Calculo do endereco de desvio

	wire [31:0] out_rs, out_rt; //Fios para guardar os valores dos registradores que estão em RS e RT

	BancoDeRegistradores registradores(.rs(rs), .rt(rt), .out_rs(out_rs), .out_rt(out_rt)); //Busca os valores nos registradores

	wire [31:0] dado_rs, dado_rt;
	RegPipeline #(.TAM(64)) id_ex_dados_reg (.clock(clock), .parada(parada), .limpar(limpar),
																					.in({out_rs, out_rt}),
																					.out({dado_rs, dado_rt}));

  wire [4:0] rt_3, rd_3;
	RegPipeline #(.TAM(10)) id_ex_registradores (.clock(clock), .parada(parada), .limpar(limpar),
																					.in({rt, rd}),
																					.out{rt_3, rd_3});

	wire [4:0] rs_3; //Envia RS para a proxima fase
	RegPipeline #(.TAM(5)) id_ex_registrador_rs(.clock(clock), .parada(parada), .limpar(1'b0), //Esse registrador nao e afetado pelo clear ja que o rs pode ser usado para antecipacao
	                      .in (rs),
	                      .out(rs_3));

	wire [31:0] pc_3;
	RegPipeline #(.TAM(32)) id_ex_pc (.clock(clock), .parada(parada), limpar(1'b0),
																		.in(pc_2), .out(pc_3));

	wire[31:0] branch_end_3, jump_end_3;
  RegPipeline #(.TAM(64)) id_ex_desvios (.clock(clock), .parada(1'b0), .limpar(limpar),
                          .in({branch_end, jump_end}),
                          .out({branch_end_3, jump_end_3}));



endmodule

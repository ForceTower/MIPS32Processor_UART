module Processador(input clock, output wire[31:0] t_pc, t_inst);
	// ---------------------------------------------
	//				FASE 1 - Instruction Fetch
	// ---------------------------------------------

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

	// ---------------------------------------------------
	//				FASE 2 - Instruction Decode
	// ---------------------------------------------------

	wire[5:0] opcode; // fio para o opcode
	wire[4:0] rs, rt, rd; // fio para cada registrador
	wire[4:0] shift; // guarda o valor da quantidade de shift
	wire[5:0] funct; // guarda o valor do funct
	wire[15:0] imediato; // o valor imediato que vem na instrucao

	//separacao da instrucao em suas respectivas partes de acordo com a literatura
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

  //Banco de Registradores, toma como entrada os registradores que serao lidos e o que e escrito na fase WB
	BancoDeRegistradores registradores(.rs(rs), .rt(rt), .out_rs(out_rs), .out_rt(out_rt), .sinal_escrita(c_escrever_reg_5), .reg_escrita(reg_escrita_5), .dado_escrita(dado_escrita_5)); //Busca os valores nos registradores

	wire [31:0] dado_rs_3, dado_rt_3, se_imediato_3;
	RegPipeline #(.TAM(96)) id_ex_dados_reg (.clock(clock), .parada(parada), .limpar(limpar),
																					.in({out_rs, out_rt, se_imediato}),
																					.out({dado_rs, dado_rt, se_imediato_3}));

  wire [5:0] funct_3;
  RegPipeline #(.TAM(6)) id_ex_funct (.clock(clock), .parada(parada), .limpar(limpar), .in(funct), .out(funct_3));

  wire [4:0] rt_3, rd_3;
	RegPipeline #(.TAM(10)) id_ex_registradores (.clock(clock), .parada(parada), .limpar(limpar),
																					.in({rt, rd}),
																					.out{rt_3, rd_3});

	wire [4:0] rs_3; //Envia RS para a proxima fase
	RegPipeline #(.TAM(5)) id_ex_registrador_rs(.clock(clock), .parada(parada), .limpar(1'b0), //Esse registrador nao e afetado pelo clear ja que o rs pode ser usado para antecipacao
	                      .in (rs),
	                      .out(rs_3));

	wire [31:0] pc_3;
	RegPipeline #(.TAM(32)) id_ex_pc (.clock(clock), .parada(parada), .limpar(1'b0),
																		.in(pc_2), .out(pc_3));

	wire[31:0] branch_end_3, jump_end_3;
  RegPipeline #(.TAM(64)) id_ex_desvios (.clock(clock), .parada(1'b0), .limpar(limpar),
                          .in({branch_end, jump_end}),
                          .out({branch_end_3, jump_end_3}));

  wire[1:0] c_ALUOp; //Controle da ULA
	wire[1:0] c_memoria; //Controle da memoria
	wire[2:0] c_desvio; //Controle de Desvios
	wire c_fonte_ula; //Fonte da Ula (imediato, registrador)
	wire c_memtoreg; //Load
	wire c_escrever_reg; //Sinal de escrita
	wire c_reg_destino; //Reg de destino rs ou rd

	//Gerar os microsinais baseados no opcode
	Controle controle  (.opcode(opcode), .c_ALUOp(c_ALUOp), .c_memoria(c_memoria), .c_desvio(c_desvio), .c_fonte_ula(c_fonte_ula), .c_memtoreg(c_memtoreg), .c_escrever_reg(c_escrever_reg), .c_reg_destino(c_reg_destino));

	wire[1:0] c_ALUOp_3; //Controle da ULA
	wire[1:0] c_memoria_3; //Controle da memoria
	wire[2:0] c_desvio_3; //Controle de Desvios
	wire c_fonte_ula_3; //Fonte da Ula (imediato, registrador)
	wire c_memtoreg_3; //Load
	wire c_escrever_reg_3; //Sinal de escrita
	wire c_reg_destino_3; //Reg de destino rs ou rd
	RegPipeline #(.TAM(8)) id_ex_micro_sinais(.clock(clock), .parada(1'b0), .limpar(parada), //Em caso de parada(stall), limpe tudo!
																					.in({c_ALUOp, c_memoria, c_fonte_ula, c_memtoreg, c_escrever_reg, c_reg_destino}),
																					.out({c_ALUOp_3, c_memoria_3, c_fonte_ula_3, c_memtoreg_3, c_escrever_reg_3, c_reg_destino_3}));

	RegPipeline #(.TAM(3)) id_ex_branch_sinais(.clock(clock), .parada(1'b0), .limpar(limpar),
																						.in({c_desvio}),
																						.out({c_desvio_3}));


	// -------------------------------------------------------------------------------------
	//                                 FASE 3 - Execucao
	// -------------------------------------------------------------------------------------

  wire[1:0] c_memoria_4;
	wire c_memtoreg_4;
	wire c_escrever_reg_4;
	RegPipeline #(.TAM(4)) ex_me_micro_sinais(.clock(clock), .parada(1'b0), .limpar(limpar), //Passa adiante os microsinais que nao serão usados nesta fase
																					.in({c_memoria_3, c_memtoreg_3, c_escrever_reg_3}),
																					.out({c_memoria_4, c_memtoreg_4, c_escrever_reg_4}));

	wire [31:0] segundo_operando;
	assign segundo_operando = (fonte_ula_3) ? se_imediato_3 : dado2_antecipado; //O Segundo operando da ULA pode ser proveniente de um registrador ou de um imediato

  wire [2:0] operacao;
	controleALU controle_alu (.funct(funct_3), .opALU(c_ALUOp_3), .sinalOperacao(operacao)); //Obtem o sinal da operacao da ALU baseado no funct + AluOP

	reg [31:0] dado1_antecipado; // Antecipacao de dados
	always @ ( * ) begin //Este always funciona como um mux
		case (antecipar_a)
			2'b01: dado1_antecipado <= resultado_ula_4; //se 1, antecipa o resultado da ULA
			2'b10: dado1_antecipado <= dado_escrita_5; //se 2, antecipa o dado da memoria que seria escrito
			default: dado1_antecipado <= dado_rs_3; //se 0 (ou 3 que nunca vai acontecer), nao antecipa
		endcase
	end

	wire [31:0] resultado_ula;
	wire zero, overflow;

	ALU alu (.sinalOperacao(operacao), .rs(dado1_antecipado), .rt(segundo_operando), .resultado(resultado_ula), .overflow(overflow), .zero(zero));

	wire zero_4;
	wire overflow_4;

	RegPipeline #(.TAM(2)) ex_me_flags_ula(.clock(clock), .parada(1'b0), .limpar(limpar),
																				.in({zero, overflow}),
																				.out({zero_4, overflow_4}));

	wire [31:0] resultado_ula_4;
	RegPipeline #(.TAM(32)) ex_me_ula_resultado(.clock(clock), .parada(1'b0), .limpar(limpar),
																				.in(resultado_ula),
																				.out(resultado_ula_4));



	reg [31:0] dado2_antecipado;
	always @ ( * ) begin
		case (antecipar_b)
			2'b01: dado2_antecipado <= resultado_ula_4;
			2'b10: dado2_antecipado <= dado_escrita_5;
			default: dado2_antecipado <= dado_rt_3;
		endcase
	end

	wire [31:0] dado_rt_4;
	RegPipeline #(.TAM(32)) ex_me_dado_registrador(.clock(clock), .parada(1'b0), .limpar(limpar),
																				.in(dado2_antecipado),
																				.out(dado_rt_4));

	wire [4:0] reg_escrita;
	assign reg_escrita = (c_reg_destino_3) ? rd_3 : rt_3;

	wire [4:0] reg_escrita_4;
	RegPipeline #(.TAM(5)) ex_me_reg_escrita(.clock(clock), .parada(1'b0), .limpar(limpar), .in(reg_escrita), .out(reg_escrita_4));

	wire [31:0] branch_end_4, jump_end_4;
	RegPipeline #(.TAM(64)) ex_me_end_branch(.clock(clock), .parada(1'b0), .limpar(limpar), .in({branch_end_3, jump_end_3}), .out({branch_end_4, jump_end_4}));

	wire[2:0] c_desvio_4;
	RegPipeline #(.TAM(3)) ex_me_sinal_desvio(.clock(clock), .parada(1'b0), .limpar(limpar), .in(c_desvio_3), .out(c_desvio_4));

	// -------------------------------------------------
	// 										Fase 4
	// -------------------------------------------------

endmodule

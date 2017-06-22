module Processador(input clock,
						 output wire[31:0] t_pc, t_inst, t_alu_a, t_alu_b, t_wb_data, t_mem_write_data, t_alu_rst,
						 output wire[4:0] t_wb_reg, t_rs, t_rt, t_rd,
						 output wire t_fonte_pc, t_limpar, t_parada,
						 output wire[2:0] t_antecipar_a, t_antecipar_b);
	// ---------------------------------------------
	//				FASE 1 - Instruction Fetch
	// ---------------------------------------------
	reg limpar;
	always @ ( * ) begin
		limpar <= 0;
		if (fonte_pc)
			limpar <= 1;
	end

	assign t_fonte_pc = fonte_pc;
	assign t_limpar = limpar;

	reg [31:0] pc; // registrador PC

	initial begin
		pc <= 32'd0; //PC inicia em 0
	end

	wire [31:0] pc4; //Cria o fio que vai guardar PC+4
	assign pc4 = pc + 4; //Coloca o valor PC + 4 no fio

	always @(negedge clock) begin //A cada borda de descida, atualiza o PC
		if (parada)
			pc <= pc;
		else if (fonte_pc)
			pc <= endereco_salto;
		else
			pc <= pc4; //Por padrao, PC = PC + 4
	end

	wire [31:0] instrucao; // cria o fio que irÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ guardar a instrucao
	Memoria memoria (.pc(pc), .instrucao(instrucao)); //Busca a instrucao na memoria

	wire[31:0] pc_2, instrucao_2; //Cria 2 fios para passar para proxima fase
	RegPipeline #(.TAM(32)) if_id_pc (.clock(clock), .parada(parada), .limpar(limpar), .in(pc), .out(pc_2)); //Esse registrador deve ser parado em caso de bolha e limpo em caso de branch
	RegPipeline #(.TAM(32)) if_id_inst (.clock(clock), .parada(parada), .limpar(limpar), .in(instrucao), .out(instrucao_2)); //Esse registrador deve ser parado em caso de bolha e limpo em caso de branch

	assign t_pc = pc;
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
	assign jump_end = {pc_2[31:28], instrucao_2[25:0], 2'b00};

	wire [31:0] branch_end;
	assign branch_end = pc_2 + {se_imediato[29:0], 2'b00}; //Calculo do endereco de desvio

	wire [31:0] out_rs, out_rt; //Fios para guardar os valores dos registradores que estÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o em RS e RT

	assign t_rs = (rs);
	assign t_rt = (rt);
	assign t_rd = (rd);



  //Banco de Registradores, toma como entrada os registradores que serao lidos e o que e escrito na fase WB
	BancoDeRegistradores registradores(.rs(rs), .rt(rt), .out_rs(out_rs), .out_rt(out_rt), .sinal_escrita(c_escrever_reg_5), .reg_escrita(reg_escrita_5), .dado_escrita(dado_escrita_5)); //Busca os valores nos registradores

	wire [31:0] dado_rs_3, dado_rt_3, se_imediato_3;
	RegPipeline #(.TAM(96)) id_ex_dados_reg (.clock(clock), .parada(parada), .limpar(limpar),
																					.in({out_rs, out_rt, se_imediato}),
																					.out({dado_rs_3, dado_rt_3, se_imediato_3}));

  wire [5:0] funct_3;
  RegPipeline #(.TAM(6)) id_ex_funct (.clock(clock), .parada(parada), .limpar(limpar), .in(funct), .out(funct_3));

  wire [4:0] rt_3, rd_3;
	RegPipeline #(.TAM(10)) id_ex_registradores (.clock(clock), .parada(parada), .limpar(limpar),
																					.in({rt, rd}),
																					.out({rt_3, rd_3}));

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
	RegPipeline #(.TAM(4)) ex_me_micro_sinais(.clock(clock), .parada(1'b0), .limpar(limpar), //Passa adiante os microsinais que nao serÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£o usados nesta fase
																					.in({c_memoria_3, c_memtoreg_3, c_escrever_reg_3}),
																					.out({c_memoria_4, c_memtoreg_4, c_escrever_reg_4}));

	wire [31:0] segundo_operando;
	assign segundo_operando = (c_fonte_ula_3) ? se_imediato_3 : dado2_antecipado; //O Segundo operando da ULA pode ser proveniente de um registrador ou de um imediato

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

	assign t_alu_a = dado1_antecipado;
	assign t_alu_b = segundo_operando;
	assign t_alu_rst = resultado_ula;

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
	wire c_memtoreg_5, c_escrever_reg_5;
	RegPipeline #(.TAM(2)) me_wb_microsinais(.clock(clock), .parada(1'b0), .limpar(1'b0), .in({c_memtoreg_4, c_escrever_reg_4}), .out({c_memtoreg_5, c_escrever_reg_5}) );
	wire[4:0] reg_escrita_5;
	RegPipeline #(.TAM(5)) me_wb_registrador(.clock(clock), .parada(1'b0), .limpar(1'b0), .in(reg_escrita_4), .out(reg_escrita_5));

	wire [31:0] dado_lido_memoria;
	MemoriaDeDados memoria_dados(.clock(clock), .sinal_ler(c_memoria_4[0]), .sinal_escrever(c_memoria_4[1]), .endereco(resultado_ula_4[8:2]), .dado_ler(dado_lido_memoria), .dado_escrever(dado_rt_4));
	assign t_mem_write_data = dado_rt_4;

	wire[31:0] resultado_ula_5, dado_memoria_5;
	RegPipeline #(.TAM(64)) me_wb_dados(.clock(clock), .parada(1'b0), .limpar(1'b0),
																			.in({resultado_ula_4, dado_lido_memoria}),
																			.out({resultado_ula_5, dado_memoria_5}));

	//TODO alterar o endereco_salto aqui
	wire[31:0] endereco_salto;
	assign endereco_salto = branch_end_4;

	reg fonte_pc;
	always @ ( * ) begin
    case (c_desvio_4)
      3'b001: fonte_pc <= zero_4; //caso seja desvio em iguais...
      3'b010: fonte_pc <= ~(zero_4); //caso seja desvio em diferentes...
			3'b011: fonte_pc <= 1'b1; //Jump incondicional
			3'b100: fonte_pc <= 1'b1; //Jump and link
			3'b101: fonte_pc <= 1'b1; //Jump resgister
      default: fonte_pc <= 1'b0;
    endcase
  end

	// -------------------------------------------------------
	//            Fase 5
	// -------------------------------------------------------

	wire[31:0] dado_escrita_5;
	assign dado_escrita_5 = (c_memtoreg_5) ? dado_memoria_5 : resultado_ula_5;

	assign t_wb_reg = reg_escrita_5;
	assign t_wb_data = dado_escrita_5;

	reg [1:0] antecipar_a, antecipar_b; //
	always @ ( * ) begin
		if (c_escrever_reg_4 && (reg_escrita_4 == rs_3))
			antecipar_a <= 2'b01; // fase 4
		else if (c_escrever_reg_5 && (reg_escrita_5 == rs_3))
			antecipar_a <= 2'b10; //fase 5
		else
			antecipar_a <= 2'b00; //nenhuma


		if (c_escrever_reg_4 && (reg_escrita_4 == rt_3))
			antecipar_b <= 2'b01;
		else if (c_escrever_reg_5 && (reg_escrita_5 == rt_3))
			antecipar_b <= 2'b10;
		else
			antecipar_b <= 2'b00;
	end

	assign t_antecipar_a = antecipar_a;
	assign t_antecipar_b = antecipar_b;

	//Foward unidade_antecipacao(.clock(clock), .reg_f4(c_escrever_reg_4), .reg_f5(c_escrever_reg_5), .escrita_f4(reg_escrita_4), .escrita_f5(reg_escrita_5), .RS_f3(rs_3), .RT_f3(rt_3), .fw_A(antecipar_a), .fw_B(antecipar_b));

	reg parada;
  always @ ( * ) begin
    if (c_memtoreg_3 && ((rt == rt_3) || (rs == rt_3)))
      parada <= 1'b1;
    else
      parada <= 1'b0;
  end

	assign t_parada = parada;


endmodule

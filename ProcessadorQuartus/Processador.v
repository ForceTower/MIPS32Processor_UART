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
	assign shift = instrucao_2[11:6];
	assign funct = instrucao_2[5:0];
	assign imediato = instrucao_2[15:0];
	
	wire[31:0] se_imediato; //Fio para o valor extendido do imediato
	assign se_imediato = {{16{imediato[15]}}, imediato[15:0]};	// extensor de sinal imediato
	
	wire[31:0] out_rs, out_rt; //Fios para guardar os valores dos registradores que estão em RS e RT
	BancoDeRegistradores registradores(.rs(rs), .rt(rt), .rd(rd), .out_rs(out_rs), .out_rt(out_rt)); //Busca os valores nos registradores
	
endmodule 
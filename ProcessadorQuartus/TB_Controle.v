//Controle_TestBench
module TB_Controle ();
    //Opcode para entrada do modulo
    reg[5:0] opcode;
    //Fios de saida do modulo
    wire [1:0] c_ALUOp;
    wire c_fonte_ula;
    wire [2:0] c_desvio;
    wire [1:0] c_memoria;
    wire c_memtoreg;
    wire c_escrever_reg;
    wire c_reg_destino;

    //Criacao do modulo de testes
    Controle teste_controle(
		.opcode(opcode),
		.c_ALUOp(c_ALUOp),
		.c_fonte_ula(c_fonte_ula),
		.c_desvio(c_desvio),
		.c_memoria(c_memoria),
		.c_memtoreg(c_memtoreg),
		.c_escrever_reg(c_escrever_reg),
		.c_reg_destino(c_reg_destino)
	);

	initial begin //Comeco dos testes
        opcode <= 6'b000000; //Tipo R
        #50
        opcode <= 6'b001000; //ADDI
        #50
        opcode <= 6'b000011; //JAL
        #50
        opcode <= 6'b000010; //J
        #50
        opcode <= 6'b000101; //BNE
        #50
        opcode <= 6'b000100; //BEQ
        #50
        opcode <= 6'b100011; //LW
        #50
        opcode <= 6'b101011; //SW
        #50
        opcode <= 6'b101011; //SW
    end
endmodule 
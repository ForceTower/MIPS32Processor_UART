module Controle(input wire [5:0] opcode,    //O Opcode
                input wire [5:0] funct,
                output reg [1:0] c_ALUOp,   //10 - Tipo R // 01 - Desvio // 00 - Imediato // Qual tipo de operacao a ALU deve fazer?
                output reg c_fonte_ula,     //1 - Usar imediato ou 0 - Registrador?
                output reg [2:0] c_desvio,  //000 - (sem desvio) / 001 - beq / 010 - bne / 011 - j / 100 - jal / 101 - jr (jr depende do funct [se funct == 001000 eh um jr])
                output reg [1:0] c_memoria, //00 - Nao ler nem escrever // 01 - Ler memoria // 10 - Escrever memoria
                output reg c_memtoreg,      //1 - Instrucao Load // 0 - Não é Instrucao Load
                output reg c_escrever_reg,  //1 - Instrucao ira escrever no registrador // 0 - Instrucao nao ira escrever no registrador
                output reg c_reg_destino,    //1 - escrever em rd // 0 - escrever em rt {Geralmente RT em casos de operacoes com imediatos}
                output reg c_jal
);


    always @ ( * ) begin
        c_jal <= 1'b0;
        case (opcode)
            6'b000000: begin            //Caso seja do tipo R     [Exemplo: add $t0, $t1, $t2]
                c_ALUOp <= 2'b10;       //Operacao tipo R
                c_fonte_ula <= 1'b0;    //Usar valor do registrador
                c_desvio <= 3'b000;     //Nao e uma instrucao de desvio
                c_memoria <= 2'b00;     //Nao ocorrera nenhum tipo de acesso a memoria
                c_memtoreg <= 1'b0;     //Nao e uma instrucao de load
                c_escrever_reg <= 1'b1; //Ira escrever no registrador
                c_reg_destino <= 1'b1;  //O registrador que sera escrito e o RD

                if (funct == 6'b001000) begin //Eh uma instrucao JR
                  c_ALUOp <= 2'b01;
                  c_desvio <= 3'b101;
                  c_escrever_reg <= 1'b0;
                end
            end

            6'b011100: begin //Mul
              c_ALUOp <= 2'b10;       //Operacao tipo R
              c_fonte_ula <= 1'b0;    //Usar valor do registrador
              c_desvio <= 3'b000;     //Nao e uma instrucao de desvio
              c_memoria <= 2'b00;     //Nao ocorrera nenhum tipo de acesso a memoria
              c_memtoreg <= 1'b0;     //Nao e uma instrucao de load
              c_escrever_reg <= 1'b1; //Ira escrever no registrador
              c_reg_destino <= 1'b1;  //O registrador que sera escrito e o RD
            end

            6'b101011: begin            //Caso seja uma operacao de Store (SW)     [Exemplo: sw $t1, 8($t2)]
                c_ALUOp <= 2'b00;       //Operacoes com a memoria calcula o endereco com um offset imediato
                c_fonte_ula <= 1'b1;    //Usar o valor imediato da instrucao
                c_desvio <= 3'b000;     //Nao e uma instrucao de desvio
                c_memoria <= 2'b10;     //Iremos escrever na memoria
                c_memtoreg <= 1'b0;     //Nao e uma instrucao de load
                c_escrever_reg <= 1'b0; //Nao vamos precisar escrever no registrador
                c_reg_destino <= 1'b0;  //Nao e usado nessa instrucao ja que o escrever_reg eh 0, pode deixar com valor qualquer
            end

            6'b100011: begin            //Caso seja uma operacao de Load (LW)     [Exemplo: lw $t1, 8($t2)]
                c_ALUOp <= 2'b00;       //E uma operacao com endereco de memoria e offset imediato
                c_fonte_ula <= 1'b1;    //Usar o valor imediato da instrucao
                c_desvio <= 3'b000;     //Nenhum desvio nessa instrucao
                c_memoria <= 2'b01;     //Vamos ler um dado da memoria
                c_memtoreg <= 1'b1;     //Vamos gravar o dado lido da memoria no registrador
                c_escrever_reg <= 1'b1; //Vamos escrever no registrador
                c_reg_destino <= 1'b0;  //O registrador de destino e RT
            end

            6'b001000: begin            //Caso seja um ADDI       [Exemplo addi $t1, $t2, 800] --- Tambem aplicavel ao SUBI ja que ele eh uma pseudo instrucao
                c_ALUOp <= 2'b00;       //Operacao com Imediato
                c_fonte_ula <= 1'b1;    //Usar o valor imediato da instrucao na ULA
                c_desvio <= 3'b000;     //Nenhum desvio sera tomado
                c_memoria <= 2'b00;     //Nao havera acesso a memoria
                c_memtoreg <= 1'b0;     //Nao e uma instrucao de load
                c_escrever_reg <= 1'b1; //Iremos escrever em um registrador
                c_reg_destino <= 1'b0;  //O registrador de destino e RT
            end

            6'b000100: begin            //Caso seja um BEQ        [Exemplo beq $t0, $zero, 40]
                c_ALUOp <= 2'b01;       //ULA vai executar uma operacao de branch (que sera no final das contas umas subtracao)
                c_fonte_ula <= 1'b0;    //Os dois valores para a subtracao estao em registradores
                c_desvio <= 3'b001;     //Instrucao de Desvio se Igual
                c_memoria <= 2'b00;     //Nao havera acesso a memoria
                c_memtoreg <= 1'b0;     //Nao eh um load
                c_escrever_reg <= 1'b0; //Nao vamos escrever em registradores
                c_reg_destino <= 1'b0;  //Nao aplicado a esta operacao ja que a flag de escrever no registrador esta desativada
            end

            6'b000101: begin            //Caso seja um BNE        [Exemplo bne $t0, $zero, 40]
                c_ALUOp <= 2'b01;       //ULA vai executar uma operacao de branch (que sera no final das contas umas subtracao)
                c_fonte_ula <= 1'b0;    //Os dois valores para a subtracao estao em registradores
                c_desvio <= 3'b010;     //Instrucao de Desvio se Diferente
                c_memoria <= 2'b00;     //Nao havera acesso a memoria
                c_memtoreg <= 1'b0;     //Nao eh um load
                c_escrever_reg <= 1'b0; //Nao vamos escrever em registradores
                c_reg_destino <= 1'b0;  //Nao aplicado a esta operacao ja que a flag de escrever no registrador esta desativada
            end

            6'b000010: begin            //Caso seja um J (Jump - Salto incondicional)          [Exemplo j 40]
                c_ALUOp <= 2'b01;       //Nao aplicado nesta operacao
                c_fonte_ula <= 1'b0;    //Nao aplicado a esta operacao
                c_desvio <= 3'b011;     //Instrucao de Desvio incondicional
                c_memoria <= 2'b00;     //Nao havera acesso a memoria
                c_memtoreg <= 1'b0;     //Nao eh um load
                c_escrever_reg <= 1'b0; //Nao vamos escrever em registradores
                c_reg_destino <= 1'b0;  //Nao aplicado a esta operacao ja que a flag de escrever no registrador esta desativada
            end

            6'b000011: begin            //Caso seja um JAL (Jump and Link - Salto incondicional e Salvar PC em registrador de retorno)          [Exemplo jal 40]
                c_ALUOp <= 2'b01;       //Nao aplicado nesta operacao
                c_fonte_ula <= 1'b0;    //Nao aplicado a esta operacao
                c_desvio <= 3'b100;     //Instrucao de Desvio incondicional
                c_memoria <= 2'b00;     //Nao havera acesso a memoria
                c_memtoreg <= 1'b0;     //Nao eh um load
                c_escrever_reg <= 1'b1; //Vamos escrever em registradores
                c_reg_destino <= 1'b0;  //Nao aplicado a esta operacao ja que a flag de escrever no registrador esta desativada
                c_jal <= 1'b1;
            end

        endcase
    end

endmodule

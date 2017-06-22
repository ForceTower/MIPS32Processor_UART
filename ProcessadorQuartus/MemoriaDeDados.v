module MemoriaDeDados (input clock, sinal_ler, sinal_escrever,
                       input wire [6:0] endereco,
					             input wire [31:0] dado_escrever,
                       output wire [31:0] dado_ler);

  reg [31:0] memoria [0:127];
  always @ (posedge clock) begin
    if (sinal_escrever)
      memoria[endereco] <= dado_escrever;
  end

  assign dado_ler = (sinal_ler) ? memoria[endereco][31:0] : dado_escrever;

endmodule // Memoria

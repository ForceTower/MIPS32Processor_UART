module BancoDeRegistradores(input sinal_escrita, clock,
														input[4:0] rs, rt, reg_escrita,
														input[31:0] dado_escrita,
														output[31:0] out_rs, out_rt);
	reg [31:0] registradores [0:31];

	reg [31:0] dado1, dado2;

	always @(*) begin
		if (rs == 5'b00000)
			dado1 <= 32'd0;
		else if ((rs == reg_escrita) && sinal_escrita)
      dado1 <= dado_escrita;
		else
			dado1 <= registradores[rs][31:0];

		if (rt == 5'b00000)
			dado2 <= 32'd0;
		else if ((rt == reg_escrita) && sinal_escrita)
      dado2 <= dado_escrita;
		else
			dado2 <= registradores[rt][31:0];
	end


	assign out_rs = dado1;
	assign out_rt = dado2;

	always @ (posedge clock) begin
		if (sinal_escrita && reg_escrita != 5'd0)
			registradores[reg_escrita] <= dado_escrita;
	end
endmodule

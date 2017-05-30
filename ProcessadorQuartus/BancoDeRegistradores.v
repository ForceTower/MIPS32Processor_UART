module BancoDeRegistradores(	input[4:0] rs, rt, rd, 
										output[31:0] out_rs, out_rt);
	reg [31:0] registradores [0:31];

	reg [31:0] dado1, dado2;
	
	if (rs == 5'b00000)
		dado1 <= 32'd0;
	else
		dado1 <= registradores[rs];
		
	if (rt == 5'b00000)
		dado2 <= 32'd0;
	else
		dado2 <= registradores[rt];
		
	
	assign out_rs = dado1;
	assign out_rt = dado2;		 
endmodule 
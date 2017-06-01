module TB_Foward ();
	wire clock;
	//sinalizadores da fase 4 e 5
	reg reg_f4, reg_f5;
	//registradores de escrita fase 4 e 5
	reg [4:0] escrita_f4, escrita_f5;
	//registradores RS e RT no pipeline fase 3
	reg [4:0] RS_f3, RT_f3;
	//sinalizadores de qual fazer fowarding
	wire [1:0] fw_A, fw_B;
		
	Foward teste_foward(
		.clock(clock), 
		.reg_f4(reg_f4), 
		.reg_f5(reg_f5), 
		.escrita_f4(escrita_f4), 
		.escrita_f5(escrita_f5), 
		.RS_f3(RS_f3), 
		.RT_f3(RT_f3), 
		.fw_A(fw_A), 
		.fw_B(fw_B)
	);
	
	initial begin
		//não tem fowarding
		reg_f4 <= 1'b0; reg_f5 <= 1'b0; escrita_f4 <= 5'b00100; escrita_f5 <= 5'b10000; RS_f3 <= 5'b00001;	RT_f3 <= 5'b00010; #100
		//não tem fowarding mas quer escrever f4
		reg_f4 <= 1'b1; reg_f5 <= 1'b0; escrita_f4 <= 5'b00100; escrita_f5 <= 5'b10000; RS_f3 <= 5'b00001;	RT_f3 <= 5'b00010; #100
		//não tem fowarding mas quer escrever f5
		reg_f4 <= 1'b0; reg_f5 <= 1'b1; escrita_f4 <= 5'b00100; escrita_f5 <= 5'b10000; RS_f3 <= 5'b00001;	RT_f3 <= 5'b00010; #100
		//tem fowarding rf4 == rsf3
	   reg_f4 <= 1'b1; reg_f5 <= 1'b0; escrita_f4 <= 5'b00100; escrita_f5 <= 5'b10000; RS_f3 <= 5'b00100;	RT_f3 <= 5'b00010; #100
	   //tem fowarding rf4 == rtf3
		reg_f4 <= 1'b1; reg_f5 <= 1'b0; escrita_f4 <= 5'b00100; escrita_f5 <= 5'b10000; RS_f3 <= 5'b00110;	RT_f3 <= 5'b00100; #100
		//tem fowarding rf5 == rsf3
	   reg_f4 <= 1'b0; reg_f5 <= 1'b1; escrita_f4 <= 5'b00100; escrita_f5 <= 5'b10000; RS_f3 <= 5'b10000;	RT_f3 <= 5'b00010; #100
	   //tem fowarding rf5 == rtf3
		reg_f4 <= 1'b0; reg_f5 <= 1'b1; escrita_f4 <= 5'b00100; escrita_f5 <= 5'b10000; RS_f3 <= 5'b00110;	RT_f3 <= 5'b10000; #100
		//tem fowarding rf4 == rsf3 == rtf3
	   reg_f4 <= 1'b1; reg_f5 <= 1'b0; escrita_f4 <= 5'b00100; escrita_f5 <= 5'b10000; RS_f3 <= 5'b00100;	RT_f3 <= 5'b00100; #100
		//tem fowarding rf5 == rsf3 == rtf3
	   reg_f4 <= 1'b0; reg_f5 <= 1'b1; escrita_f4 <= 5'b00100; escrita_f5 <= 5'b10000; RS_f3 <= 5'b10000;	RT_f3 <= 5'b10000; #100

		//F4 == 10
		//F5 == 01
		
	end
endmodule
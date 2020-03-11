module stage1(
	input wire clk, 
	input wire [31:0] inst
	);

	wire [3:0] cond, op, rn, rd, rm; 
	wire [11:0] operand;
	wire [7:0] out1, out2, out3, out4, out5;
	wire b, l, t, s, ldr, str, p, u, bit, w;
	wire [23:0] offset;
	
	decode decoder(inst, b, l, t, s, ldr, str, p, u, bit, w, offset, cond, op, rn, rd, rm, operand, branchimm);

	always @(*) begin
		tregaddrIn = 0; tregaddrOut1 = 0; tregaddrOut2 = 0; tregdataIn = 0;
		tregwr = 0; tregrd1 = 0; tregrd2 = 0; 
		tmemaddrIn = 0; tmemaddrOut = 0; tmemdataIn = 0; 
		tmemwr = 0; tmemrd = 0; 
		opcode = 0; alu1 = 0; alu2 = 0;
		tbf = 0;
		if (ldr || str) begin
			if (condition) begin
				// read register 
				if (ldr) begin
					tregaddrOut1 = rn;
					tregrd1 = 1'b1;
				end
				else begin
					tregaddrOut1 = rd;
					tregrd1 = 1'b1;
				end						
			end
		end
		else begin
			if (b) begin
				if (condition) begin
					tbf = 1'b1;
					if (l) begin
						//register file connection
						tregaddrIn = 4'b1110; //if there is BL, store to register 14
						tregdataIn = pc; //connect to pc
						tregwr = 1'b1;
					end
				end
			end
			else
				case (op)
				4'b0000: begin // AND
								
							end
							
				4'b0001: begin // EOR *
								tregaddrOut1 = rn; tregrd1 = 1;
								if (!t) begin
									tregaddrOut2 = rm; tregrd2 = 1;
								end
							end
							
				4'b0010: begin // SUB *
								tregaddrOut1 = rn; tregrd1 = 1;
								if (!t) begin
									tregaddrOut2 = rm; tregrd2 = 1;
								end
							end
							
				4'b0011: begin // RSB *
	
							end
							
				4'b0100: begin // ADD *
								tregaddrOut1 = rn; tregrd1 = 1;
								if (!t) begin
									tregaddrOut2 = rm; tregrd2 = 1;
								end
							end
							
				4'b0101: begin // ADC *
							
							end
							
				4'b0110: begin // SBC *
					
							end
							
				4'b0111: begin // RSC *
							
							end
							
				4'b1000: begin // TST
								tregaddrOut1 = rn; tregrd1 = 1;
								if (!t) begin
									tregaddrOut2 = rm; tregrd2 = 1;
								end
							end
							
				4'b1001: begin// TEQ
								tregaddrOut1 = rn; tregrd1 = 1;
								if (!t) begin
									tregaddrOut2 = rm; tregrd2 = 1;
								end
							end
							
				4'b1010: begin// CMP
								tregaddrOut1 = rn; tregrd1 = 1;
								if (!t) begin
									tregaddrOut2 = rm; tregrd2 = 1;
								end
							end
							
				4'b1011: begin// CMN

							end
							
				4'b1100: begin // ORR *
								tregaddrOut1 = rn; tregrd1 = 1;
								if (!t) begin
									tregaddrOut2 = rm; tregrd2 = 1;
								end
							end
							
				4'b1101: begin// MOV
								tregaddrOut1 = rm; tregrd1 = 1;	
							end
							
				4'b1110: begin // BIC *
								tregaddrOut1 = rm; tregrd1 = 1;
								tregaddrOut2 = rn; tregrd2 = 1;
							end
							
				4'b1111: begin // MVN
								tregaddrOut1 = rm; tregrd1 = 1;				
							end
				endcase
		end
	end
endmodule 
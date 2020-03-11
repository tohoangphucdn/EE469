module stage3(
	input wire clk, 
	input wire [31:0] inst
	);

				// 	stage3 four(clk, inst4, memwr, memrd, memaddrIn, memaddrOut, memdataIn);

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
							if (ldr) begin
								if (p) tmemaddrOut = regdata1 + operand;
								else tmemaddrOut = regdata1;
								tmemrd = 1'b1;
							end
//							else begin
//								tregaddrOut2 = rn;
//								tregrd2 = 1'b1;
//							end
						end
				2'b11: begin
				  // push and output
							if (ldr) begin
//								tregaddrIn = rd;
//								tregwr = 1'b1;
//								if (bit) tregdataIn = {24'b0, memdata[7:0]};
//								else tregdataIn = memdata;
							end
							else begin
								if (p) tmemaddrIn = regdata2 + operand;
								else tmemaddrIn = regdata2;
								tmemwr = 1'b1;
								
								if (bit) tmemdataIn = {4{regdata1[7:0]}};
								else tmemdataIn = regdata1;
								
								if (w) begin
//									tregaddrIn = rn;
//									if (u)										
//										tregdataIn = regdata2 + operand;
//									else tregdataIn = regdata2 - operand;
								end
							end
						end
				endcase
			end
		end
		else begin
			if (b) begin
				if (condition) begin
					tbf = 1'b1;
					if (l) begin
//						//register file connection
//						tregaddrIn = 4'b1110; //if there is BL, store to register 14
//						tregdataIn = pc; //connect to pc
//						tregwr = 1'b1;
					end
				end
			end
			else
				case (op)
				4'b0000: begin // AND
							
								2'b11: begin
								  // push and output
										end
							end
				4'b0001: begin // EOR *
								
								2'b11: begin
											
										end
							end
				4'b0010: begin // SUB *
								
								2'b11: begin
										end
								
							end
				4'b0011: begin // RSB *
								
								2'b11: begin
										end
							end
				4'b0100: begin // ADD *
								
								2'b11: begin
										end
							end
				4'b0101: begin // ADC *
								
										
								2'b11: begin
										end
							end
				4'b0110: begin // SBC *
								
								2'b11: begin
										end
								
							end
				4'b0111: begin // RSC *
								
								2'b11: begin
										end
							end
				4'b1000: begin // TST
								
								2'b11: begin
										end
							end
				4'b1001: begin// TEQ
								
								2'b11: begin
										end
							end
				4'b1010: begin// CMP
								
								2'b11: begin
										end
							end
				4'b1011: begin// CMN
								
								2'b11: begin
										end
								
							end
				4'b1100: begin // ORR *
								
								2'b11: begin
										end
							end
				4'b1101: begin// MOV
								
								2'b11: begin 
										end
							end
				4'b1110: begin // BIC *
								
								2'b11: begin
										end
							end
				4'b1111: begin // MVN
								
								2'b11: begin
										end
							end
				endcase
		end
	end
endmodule 
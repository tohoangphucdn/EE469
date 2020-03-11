module stage4(
	input wire clk, 
	input wire [31:0] inst,
	output wire regwr,
	output wire [3:0] regaddrIn
	);

	wire [3:0] cond, op, rn, rd, rm; 
	wire [11:0] operand;
	wire [7:0] out1, out2, out3, out4, out5;
	wire b, l, t, s, ldr, str, p, u, bit, w;
	wire [23:0] offset;
	
	
	// Temporary variables
	reg [3:0] tregaddrIn; 
	reg tregwr;
	
	assign regaddrIn 		= tregaddrIn;
	assign regwr 			= tregwr;


	decode decoder(inst, b, l, t, s, ldr, str, p, u, bit, w, offset, cond, op, rn, rd, rm, operand, branchimm);
					
	// Cycling through the states of the operations
	always @(*) begin
		tregaddrIn = 0; tregaddrOut1 = 0; tregaddrOut2 = 0; tregdataIn = 0;
		tregwr = 0; tregrd1 = 0; tregrd2 = 0; 
		tmemaddrIn = 0; tmemaddrOut = 0; tmemdataIn = 0; 
		tmemwr = 0; tmemrd = 0; 
		opcode = 0; alu1 = 0; alu2 = 0;
		tbf = 0;				
		case (op)
		4'b0000: begin // AND
					end
					
		4'b0001: begin // EOR *
						tregaddrIn = rd; tregwr = 1;
						//tregdataIn = ALUresult;
					end
					
		4'b0010: begin // SUB *
						tregaddrIn = rd; tregwr = 1;
						//tregdataIn = ALUresult;
					end
					
		4'b0011: begin // RSB *
					end
		4'b0100: begin // ADD *
						tregaddrIn = rd; tregwr = 1;
						//tregdataIn = ALUresult;
					end
					
		4'b0101: begin // ADC *
					end
		4'b0110: begin // SBC *
					end
		4'b0111: begin // RSC *
					end
					
		4'b1000: begin // TST
						tregaddrIn = rd; tregwr = 1;
						//tregdataIn = ALUresult;
					end
					
		4'b1001: begin// TEQ
					end
					
		4'b1010: begin// CMP
					end
					
		4'b1011: begin// CMN
					end
					
		4'b1100: begin // ORR *
						tregaddrIn = rd; tregwr = 1;
						//tregdataIn = ALUresult;
					end
					
		4'b1101: begin// MOV
						tregaddrIn = rd; tregwr = 1;
						//tregdataIn = ALUresult;
					end
					
		4'b1110: begin // BIC *										
						tregaddrIn = rd; tregwr = 1;
						//tregdataIn = ALUresult;
					end
					
		4'b1111: begin // MVN
						tregaddrIn = rd; tregwr = 1;
						//tregdataIn = ALUresult;
					end
		endcase
	end
endmodule 
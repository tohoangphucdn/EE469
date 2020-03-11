module stage2(
	input wire clk, 
	input wire [31:0] inst
	);

	wire [3:0] cond, op, rn, rd, rm; 
	wire [11:0] operand;
	wire [7:0] out1, out2, out3, out4, out5;
	wire b, l, t, s, ldr, str, p, u, bit, w;
	wire [23:0] offset;
	
	decode decoder(inst, b, l, t, s, ldr, str, p, u, bit, w, offset, cond, op, rn, rd, rm, operand, branchimm);
	ALU calculation(opcode, alu1, alu2, ALUresult, newcond[3], newcond[2], newcond[1], newcond[0]);
	
	// Altering CPSR
	initial cpsr = 0;
	always @(*) begin
		if (s) cpsr = {newcond,cpsr[27:0]};
	end
	
	always @(*) begin
		tregaddrIn = 0; tregaddrOut1 = 0; tregaddrOut2 = 0; tregdataIn = 0;
		tregwr = 0; tregrd1 = 0; tregrd2 = 0; 
		tmemaddrIn = 0; tmemaddrOut = 0; tmemdataIn = 0; 
		tmemwr = 0; tmemrd = 0; 
		opcode = 0; alu1 = 0; alu2 = 0;
		tbf = 0;
		
		case (op)
		4'b0000:	begin end
		
		4'b0001: begin //EOR *
						opcode = 4'b0001;
						alu1 = regdata1; // send to ALU
						if (t) alu2 = out_rotate; // send to ALU
						else alu2 = out_shift; // send to 
					end
		
		4'b0010: begin // SUB *
						opcode = 4'b0010;
						alu1 = regdata1; // send to ALU
						if (t) alu2 = out_rotate; // send to ALU
						else alu2 = out_shift; // send to ALU
					end
					
		4'b0011: begin // RSB *
					end
							
		4'b0100: begin // ADD *
						opcode = 4'b0100;
						alu1 = regdata1; // send to ALU
						if (t) alu2 = out_rotate; // send to ALU
						else alu2 = out_shift; // send to ALU
					end
					
		4'b0101: begin // ADC *
					end
					
		4'b0110: begin // SBC *
					end
					
		4'b0111: begin // RSC *
					end
					
		4'b1000: begin // TST
						opcode = 4'b1000;											
						alu1 = regdata1; // send to ALU
						if (t) alu2 = out_rotate; // send to ALU
						else alu2 = out_shift; // send to ALU
					end
					
		4'b1001: begin// TEQ
						opcode = 4'b1001;
						alu1 = regdata1; // send to ALU
						if (t) alu2 = out_rotate; // send to ALU
						else alu2 = out_shift; // send to ALU
					end
					
		4'b1010: begin// CMP
						opcode = 4'b1010;
						alu1 = regdata1; // send to ALU
						if (t) alu2 = out_rotate;
						else alu2 = out_shift; // send to ALU
					end
					
		4'b1011: begin// CMN
					end
					
		4'b1100: begin // ORR *
						opcode = 4'b1100;
						alu1 = regdata1; // send to ALU
						if (t) alu2 = out_rotate; // send to ALU
						else alu2 = out_shift; // send to ALU
					end
		4'b1101: begin// MOV
						//enable the ALU for the work
						opcode = 4'b1101;
						alu1 = rd; //MOV to the destination register
						alu2 = regdata1; //operand 2	
					end
					
		4'b1110: begin // BIC *
						opcode = 4'b1110;
						alu1 = regdata1;
						alu2 = regdata2;											
					end

		4'b1111: begin // MVN
						//enable the ALU for the work
						opcode = 4'b1111;
						alu1 = rd; //MVN to the destination register
						alu2 = regdata1; //operand 2	
					end
		endcase
endmodule 
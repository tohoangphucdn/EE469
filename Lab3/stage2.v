module stage2(
	input wire clk, 
	input wire [31:0] inst,
	input wire [31:0] regdata1, regdata2,
	
	output wire [31:0] memdataIn, regdataIn
	);

	
	wire [3:0] cond, op, rn, rd, rm; 
	wire [11:0] operand;
	wire [7:0] out1, out2, out3, out4, out5;
	wire b, l, t, s, ldr, str, p, u, bit, w;
	wire [23:0] offset;
	
	reg [31:0]  alu1, alu2,cpsr;
	wire [31:0] ALUresult, out_shift, out_rotate;
	reg [3:0] opcode;
	wire [3:0] newcond;
	reg [3:0]temp;
	reg condition, tbf;
	wire c_flag, c_flag2;
	
	// Temporary variables
	reg [3:0] tregaddrIn; 
	reg [3:0] tregaddrOut1, tregaddrOut2;
	reg [31:0] tregdataIn;
	reg tregwr, tregrd1, tregrd2;
	reg [31:0] tmemaddrIn, tmemaddrOut, tmemdataIn;
	reg tmemwr, tmemrd;
	
	assign regaddrIn 		= tregaddrIn;
	assign regaddrOut1 	= tregaddrOut1;
	assign regaddrOut2 	= tregaddrOut2;
	assign regdataIn 		= tregdataIn;
	assign regwr 			= tregwr;
	assign regrd1 			= tregrd1;
	assign regrd2 			= tregrd2;
	assign memaddrIn 		= tmemaddrIn;
	assign memaddrOut 	= tmemaddrOut;
	assign memdataIn 		= tmemdataIn;
	assign memwr 			= tmemwr;
	assign memrd 			= tmemrd;
	assign bf 				= tbf;

	//conditions
	localparam EQcc = 4'b0000;
	localparam NEcc = 4'b0001;
	localparam CScc = 4'b0010;
	localparam CCcc = 4'b0011;
	localparam MIcc = 4'b0100;
	localparam PLcc = 4'b0101;
	localparam VScc = 4'b0110;
	localparam VCcc = 4'b0111;
	localparam HIcc = 4'b1000;
	localparam LScc = 4'b1001;
	localparam GEcc = 4'b1010;
	localparam LTcc = 4'b1011;
	localparam GTcc = 4'b1100;
	localparam LEcc = 4'b1101;
	localparam ALcc = 4'b1110;

	// Set condition based on previous ALU result to determine whether to proceed with execution in the next step.
	always @(*) begin
		case (cond)
			EQcc: condition = cpsr[30];
			NEcc: condition = ~cpsr[30];
			CScc: condition = cpsr[29];
			CCcc: condition = ~cpsr[29];
			MIcc: condition = cpsr[31];
			PLcc: condition = ~cpsr[31];
			VScc: condition = cpsr[28];
			VCcc: condition = ~cpsr[28];
			HIcc: condition = cpsr[28] && ~cpsr[30];
			LScc: condition = ~cpsr[28] && cpsr[30];
			GEcc: condition = cpsr[31] == cpsr[28];
			LTcc: condition = cpsr[31] != cpsr[28];
			GTcc: condition = ~cpsr[30] && (cpsr[31] == cpsr[28]);
			LEcc: condition = cpsr[30] && (cpsr[31] != cpsr[28]);
			ALcc: condition = 1'b1;
			default: condition = 1'b1;
		endcase
	end
	
	decode decoder(inst, b, l, t, s, ldr, str, p, u, bit, w, offset, cond, op, rn, rd, rm, operand, branchimm);
	ALU calculation(opcode, alu1, alu2, ALUresult, newcond[3], newcond[2], newcond[1], newcond[0]);
	
	// Altering CPSR
	initial cpsr = 0;
	always @(*) begin
		if (s) cpsr = {newcond,cpsr[27:0]};
	end
	
	reg [31:0] tresult1, tresult2;
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
					
					if (bit) tregdataIn = {24'b0, memdata[7:0]};
					else tregdataIn = memdata;
				end
				else begin
					if (p) tmemaddrIn = regdata2 + operand;
					else tmemaddrIn = regdata2;
					tmemwr = 1'b1;
					
					if (bit) tmemdataIn = {4{regdata1[7:0]}};
					else tmemdataIn = regdata1;
					
					if (w) begin
						tregaddrIn = rn;
						if (u)										
							tregdataIn = regdata2 + operand;
						else tregdataIn = regdata2 - operand;
					end
				end
			end
		end
		else begin
			if (b) begin
				if (condition) begin
					tbf = 1'b1;
					if (l) begin
					end
				end
			end
			else 
				case (op)
				4'b0000:	begin end
				
				//memory result1, reg file result2
				
				4'b0001: begin //EOR *
								opcode = 4'b0001;
								alu1 = regdata1; // send to ALU
								if (t) alu2 = out_rotate; // send to ALU
								else alu2 = out_shift; // send to 
								
								tresult2 = ALUresult;
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
			end
		end
endmodule 
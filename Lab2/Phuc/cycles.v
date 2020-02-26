module cycles(
	input wire clk,
	input wire [31:0] pc,
	input wire [1:0] state,
	input wire [3:0] op,
	input wire b, l, t, s, ldr, str, p, u, bit, w,
	input wire [23:0] offset,
	input wire [3:0] cond, rn, rd, rm,
	input wire [11:0] operand,
	input wire [31:0] regdata1, regdata2, memdata,
	
	
	output wire [31:0] regaddrIn, regaddrOut1, regaddrOut2, regdataIn,
	output wire regwr, regrd1, regrd2,
	output wire [31:0] memaddrIn, memaddrOut, memdataIn,
	output wire memwr, memrd,
	output wire bf,
	output wire [31:0] branchimm 
	);
	
	// t = 0 => operand is register
	// t = 1 => operand is number
	// call ALU(op, value1, value2, results, cpsr)
	// not use ALU => op = 4'b0
	
	reg [31:0]  alu1, alu2,cpsr;
	wire [31:0] ALUresult;
	wire [31:0] result;
	reg [3:0] opcode;
	wire [3:0] newcond;
	reg [3:0]temp;
	reg condition, tbf;
	
	// Temporary variables
	reg [31:0] tregaddrIn, tregaddrOut1, tregaddrOut2, tregdataIn;
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
	
	
	// ALU calls
	ALU calculation(opcode, alu1, alu2, ALUresult, newcond[3], newcond[2], newcond[1], newcond[0]);
	
	// Altering CPSR
	initial cpsr = 0;
	always @(*) begin
		if (s) cpsr = {newcond,cpsr[27:0]};
	end
	
	// Cycling through the states of the operations
	always @(*) begin
		tregaddrIn = 0; tregaddrOut1 = 0; tregaddrOut2 = 0; tregdataIn = 0;
		tregwr = 0; tregrd1 = 0; tregrd2 = 0; 
		tmemaddrIn = 0; tmemaddrOut = 0; tmemdataIn = 0; 
		tmemwr = 0; tmemrd = 0; 
		opcode = 0; alu1 = 0; alu2 = 0;
		tbf = 0;
		if (ldr || str) begin
			if (condition) begin
				case (state)
				2'b00: begin
				  //  fetch in main
						end
				2'b01: begin
				  // read register file
							if (ldr) begin
								tregaddrOut1 = rn;
								tregrd1 = 1'b1;
							end
							else begin
								tregaddrOut1 = rd;
								tregrd1 = 1'b1;
							end
							
						end
				2'b10: begin
							if (ldr) begin
								if (p) tmemaddrOut = regdata1 + operand;
								else tmemaddrOut = regdata1;
								tmemrd = 1'b1;
							end
							else begin
								tregaddrOut2 = rn;
								tregrd2 = 1'b1;
							end
						end
				2'b11: begin
				  // push and output
							if (ldr) begin
								tregaddrIn = rd;
								tregwr = 1'b1;
								if (bit) tregdataIn = {24'b0, memdata[7:0]};
								else tregdataIn = memdata;
							end
							else begin
								if (p) tmemaddrIn = regdata1 + operand;
								else tmemaddrIn = regdata1;
								tmemwr = 1'b1;
								
								if (bit) tmemdataIn = {4{regdata2[7:0]}};
								else tmemdataIn = regdata2;
								
								if (w) begin
									tregaddrIn = rn;
									if (u)										
										tregdataIn = regdata1 + operand;
									else tregdataIn = regdata1 - operand;
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
						//register file connection
						tregaddrIn = 31'b1110; //if there is BL, store to register 14
						tregdataIn = pc; //connect to pc
					end
				end
			end
			else
				case (op)
				4'b0000: begin // AND
								case (state)
								2'b00: begin
								  //  fetch in main
										end
								2'b01: begin
								  // read register file
										end
								2'b10: begin
								  // shift
										end
								2'b11: begin
								  // push and output
										end
								endcase
							end
				4'b0001: begin // EOR *
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rn; tregrd1 = 1;
											alu1 = regdata1; // send to ALU
											if (t) begin
												alu2 = operand; // send to ALU
											end 
											else begin
												tregaddrOut2 = rm; tregrd2 = 1;
												alu2 = regdata2; // send to ALU
											end
										end
								2'b10: begin
										end
								2'b11: begin
											tregaddrIn = rd; tregwr = 1;
											tregdataIn = ALUresult;
										end
								endcase
							end
				4'b0010: begin // SUB *
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rn; tregrd1 = 1;
											alu1 = regdata1; // send to ALU
											if (t) begin
												alu2 = operand; // send to ALU
											end else begin
												tregaddrOut2 = rm; tregrd2 = 1;
												alu2 = regdata2; // send to ALU
											end
										end
								2'b10: begin
										end
								2'b11: begin
											tregaddrIn = rd; tregwr = 1;
											tregdataIn = ALUresult;
										end
								endcase
							end
				4'b0011: begin // RSB *
								case (state)
								2'b00: begin
										end
								2'b01: begin
										end
								2'b10: begin
										end
								2'b11: begin
										end
								endcase
							end
				4'b0100: begin // ADD *
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rn; tregrd1 = 1;
											alu1 = regdata1; // send to ALU
											if (t) begin
												alu2 = operand; // send to ALU
											end else begin
												tregaddrOut2 = rm; tregrd2 = 1;
												alu2 = regdata2; // send to ALU
											end
										end
								2'b10: begin
										end
								2'b11: begin
											tregaddrIn = rd; tregwr = 1;
											tregdataIn = result;
										end
								endcase
							end
				4'b0101: begin // ADC *
								case (state)
								2'b00: begin
										end
								2'b01: begin
										end
								2'b10: begin
										end
								2'b11: begin
										end
								endcase
							end
				4'b0110: begin // SBC *
								case (state)
								2'b00: begin
										end
								2'b01: begin
										end
								2'b10: begin
										end
								2'b11: begin
										end
								endcase
							end
				4'b0111: begin // RSC *
								case (state)
								2'b00: begin
										end
								2'b01: begin
										end
								2'b10: begin
										end
								2'b11: begin
										end
								endcase
							end
				4'b1000: begin // TST
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rn; tregrd1 = 1;
											alu1 = regdata1; // send to ALU
											if (t) begin
												alu2 = operand; // send to ALU
											end else begin
												tregaddrOut2 = rm; tregrd2 = 1;
												alu2 = regdata2; // send to ALU
											end
										end
								2'b10: begin
										end
								2'b11: begin
											tregaddrIn = rd; tregwr = 1;
											tregdataIn = ALUresult;
										end
								endcase
							end
				4'b1001: begin// TEQ
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rn; tregrd1 = 1;
											alu1 = regdata1; // send to ALU
											if (t) begin
												alu2 = operand; // send to ALU
											end else begin
												tregaddrOut2 = rm; tregrd2 = 1;
												alu2 = regdata2; // send to ALU
											end
										end
								2'b10: begin
										end
								2'b11: begin
										end
								endcase
							end
				4'b1010: begin// CMP
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rn; tregrd1 = 1;
											alu1 = regdata1; // send to ALU
											if (t) begin
												alu2 = operand; // send to ALU
											end else begin
												tregaddrOut2 = rm; tregrd2 = 1;
												alu2 = regdata2; // send to ALU
											end
										end
								2'b10: begin
										end
								2'b11: begin
										end
								endcase
							end
				4'b1011: begin// CMN
								case (state)
								2'b00: begin
										end
								2'b01: begin
										end
								2'b10: begin
										end
								2'b11: begin
										end
								endcase
							end
				4'b1100: begin // ORR *
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rn; tregrd1 = 1;
											alu1 = regdata1; // send to ALU
											if (t) begin
												alu2 = operand; // send to ALU
											end else begin
												tregaddrOut2 = rm; tregrd2 = 1;
												alu2 = regdata2; // send to ALU
											end
										end
								2'b10: begin
										end
								2'b11: begin
											tregaddrIn = rd; tregwr = 1;
											tregdataIn = ALUresult;
										end
								endcase
							end
				4'b1101: begin// MOV
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rm; tregrd1 = 1;
											
											//enable the ALU for the work
											opcode = 4'b1101;
											alu1 = rd; //MOV to the destination register
											alu2 = regdata1; //operand 2					
										end
								2'b10: begin
										end
								2'b11: begin 
											tregaddrIn = rd; tregwr = 1;
											tregdataIn = ALUresult;
										end
								endcase
							end
				4'b1110: begin // BIC *
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rm; tregrd1 = 1;
											tregaddrOut2 = rn; tregrd2 = 1;
											
											opcode = 4'b1110;
											alu1 = regdata1;
											alu2 = regdata2;
										end
								2'b10: begin
										end
								2'b11: begin
											tregaddrIn = rd; tregwr = 1;
											tregdataIn = ALUresult;
										end
								endcase
							end
				4'b1111: begin // MVN
								case (state)
								2'b00: begin
										end
								2'b01: begin
											tregaddrOut1 = rm; tregrd1 = 1;
											
											//enable the ALU for the work
											opcode = 4'b1111;
											alu1 = rd; //MVN to the destination register
											alu2 = regdata1; //operand 2					
										end
								2'b10: begin
										end
								2'b11: begin
											tregaddrIn = rd; tregwr = 1;
											tregdataIn = ALUresult;
										end
								endcase
							end
				endcase
		end
	end
endmodule

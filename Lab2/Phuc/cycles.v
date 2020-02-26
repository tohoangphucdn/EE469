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
	output wire b_flag,
	output wire [31:0] branchimm 
	);
	
	// t = 0 => operand is register
	// t = 1 => operand is number
	// call ALU(op, value1, value2, results, cpsr)
	// not use ALU => op = 4'b0
	
	reg [31:0] cpsr, alu1, alu2;
	wire [31:0] result;
	wire [3:0] newcond;
	reg condition;
	
//	assign regaddrIn 		= 0;
//	assign regaddrOut1 	= 0;
//	assign regaddrOut2 	= 0;
//	assign regdataIn 		= 0;
//	assign regwr 			= 0;
//	assign regrd1 			= 0;
//	assign regrd2 			= 0;
//	assign memaddrIn 		= 0;
//	assign memaddrOut 	= 0;
//	assign memdataIn 		= 0;
//	assign memwr 			= 0;
//	assign memrd 			= 0;
//	assign bf 				= 0;
//	assign branchimm 		= 0;
	
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
	ALU calculation(opcode, alu1, alu2, result, newcond);
	
	// Altering CPSR
	always @(*) 
		if (s) cpsr[31:28] = newcond;
	
	// Cycling through the states of the operations
	always @(*) begin
		regaddrIn = 0; regaddrOut1 = 0; regaddrOut2 = 0; regdataIn = 0;
		regwr = 0; regrd1 = 0; regrd2 = 0; 
		memaddrIn = 0; memaddrOut = 0; memdataIn = 0; 
		memwr = 0; memrd = 0; 
		if (ldr || str) begin
			case (state)
				2'b00: begin
				  //  fetch in main
						end
				2'b01: begin
				  // read rekkgister file
							if (ldr) begin
								memaddrOut = rm;
								memrd = 1'b1;
							end
							else begin
								regaddrOut1 = rm;
								regrd1 = 1'b1;
							end
						end
				2'b10: begin
				  // shift
						end
				2'b11: begin
				  // push and output
							if (ldr) begin
								regaddrIn = rd;
								regwr = 1'b1;
								regdataIn = memdata;
							end
							else begin
								memaddrIn = rd;
								memwr = 1'b1;
								memdataIn = regdata1;
							end
						end
				endcase
		end
		else begin
			if (b) begin
				if (l) begin
				//register file connection
				regaddrIn = 31'h0000000d; //if there is BL, store to register 14
				regdataIn = pc; //connect to pc
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
										regaddrOut1 = rm; regrd1 = 1;
										regaddrOut2 = rn; regrd2 = 1;
										
										opcode = 4'b0001;
										alu1 = rn;
										alu2 = rm;
										
										end
								2'b10: begin
										end
								2'b11: begin
										regaddrIn = rd; regwr = 1;
										regdataIn = result;
										end
								endcase
							end
				4'b0010: begin // SUB *
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
										end
								2'b10: begin
										end
								2'b11: begin
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
										end
								2'b10: begin
										end
								2'b11: begin
										end
								endcase
							end
				4'b1001: begin// TEQ
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
				4'b1010: begin// CMP
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
										end
								2'b10: begin
										end
								2'b11: begin
										end
								endcase
							end
				4'b1101: begin// MOV
								case (state)
								2'b00: begin
										end
								2'b01: begin
										regaddrOut1 = rm; regrd1 = 1;
										
										//enable the ALU for the work
										opcode = 4'b1101;
										alu1 = rd; //MVN to the destination register
										alu2 = rm; //operand 2					
										end
								2'b10: begin
										end
								2'b11: begin 
										regaddrIn = rd; regwr = 1;
										regdataIn = ALUresult;
										end
								endcase
							end
				4'b1110: begin // BIC *
								case (state)
								2'b00: begin
										end
								2'b01: begin
										regaddrOut1 = rm; regrd1 = 1;
										regaddrOut2 = rn; regrd2 = 1;
										
										opcode = 4'b1110;
										alu1 = rn;
										alu2 = rm;
										end
								2'b10: begin
										end
								2'b11: begin
										regaddrIn = rd; regwr = 1;
										regdataIn = result;
										end
								endcase
							end
				4'b1111: begin // MVN
								case (state)
								2'b00: begin
										end
								2'b01: begin
										regaddrOut1 = rm; regrd1 = 1;
										
										//shifted register
										if (t == 0) begin 
											shift = operand[11:4];
											rm = operand[3:0];
										end
										else begin
											rotate = operand[11:8];
											Imm = operand[7:0];
										end
						
										
										//enable the ALU for the work
										opcode = 4'b1111;
										alu1 = rd; //MVN to the destination register
										alu2 = rm; //operand 2					
										end
								2'b10: begin
										end
								2'b11: begin
										regaddrIn = rd; regwr = 1;
										regdataIn = result;
										end
								endcase
							end
				endcase
		end
	end
	reg wire [31:0] out_shift;
	shifter shifting(.shift(shift), .rm(rm), .out(out_shift), .c_flag(cpsr[31])); //carry bit of cpsr
	//rotate rotating(rotate, rm, out_rotate, cpsr[31]); //carry bit of cpsr
	
endmodule




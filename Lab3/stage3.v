module stage3(
	input wire clk, 
	input wire [31:0] inst
	output wire memwr, memrd,
	output wire [31:0] memaddrIn, memaddrOut, memdataIn
	);

				// 	stage3 four(clk, inst4, memwr, memrd, memaddrIn, memaddrOut, memdataIn);

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
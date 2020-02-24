module cycles(
	input wire clk,
	input wire [1:0] state,
	input wire [3:0] op,
	input wire b, l, t, s,
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
	
	reg [31:0] cpsr;
	assign regaddrIn 		= 0;
	assign regaddrOut1 	= 0;
	assign regaddrOut2 	= 0;
	assign regdataIn 		= 0;
	assign regwr 			= 0;
	assign regrd1 			= 0;
	assign regrd2 			= 0;
	assign memaddrIn 		= 0;
	assign memaddrOut 	= 0;
	assign memdataIn 		= 0;
	assign memwr 			= 0;
	assign memrd 			= 0;
	assign bf 				= 0;
	assign branchimm 		= 0;
	
	
	
	always @(posedge clk) begin
		if (b) begin
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
									end
							2'b10: begin
									end
							2'b11: begin
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
									end
							2'b10: begin
									end
							2'b11: begin
									end
							endcase
						end
			4'b1110: begin // BIC *
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
			4'b1111: begin // MVN
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
			endcase
	end
endmodule

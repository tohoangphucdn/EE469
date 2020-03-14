
module operation(
	input wire clk,
	input wire [31:0] inst0,
	input wire [31:0] pc,
	input wire [31:0] regdata1, regdata2, memdata,	
	
	output wire [3:0] regaddrIn, 
	output wire [3:0] regaddrOut1, regaddrOut2, 
	output wire [31:0] regdataIn,
	output wire regwr, regrd1, regrd2,
	output wire [31:0] memaddrIn, memaddrOut, memdataIn,
	output wire memwr, memrd,
	//output wire bf,
	//output wire [31:0] branchimm,
	output wire hf, hf2, hf3
	);
	
	reg [31:0] inst1, inst2, inst3, inst4;
	
	wire [31:0] result;
	reg [31:0] result3, result4;
	wire s, h_flag, h_flag_1, h_flag_2;
	reg h_flag2, h_flag3;
	wire [3:0] newcond;
	reg [31:0] pc1, pc2, pc3, pc4;
	reg [31:0] regdata1_3, regdata2_3;
	
	
	always @(posedge clk) begin
		if ((!h_flag) && (!h_flag2) && (!h_flag3)) begin
			inst1 <= inst0;
			inst2 <= inst1;
			pc1 <= pc;
			pc2 <= pc1;
		end
		else	inst2 <= 32'b0;
		inst3 <= inst2;
		inst4 <= inst3;
		pc3 <= pc2;
		pc4 <= pc3;
		result3 <= result;
		result4 <= result3;
		h_flag2 <= h_flag;
		h_flag3 <= h_flag2;
		regdata1_3 <= regdata1;
		regdata2_3 <= regdata2;
		//regdata1_3 <= regdata1_2;
		//regdata2_3 <= regdata2_2;
	end

	reg [31:0] cpsr;
	
	// Altering CPSR
	initial cpsr = 0;
	always @(*) begin
		if (s) cpsr = {newcond,cpsr[27:0]};
	end
	
	assign hf = h_flag;
	assign hf2 = h_flag2;
	assign hf3 = h_flag3;
	
	// Hazard detection
	hazard haz(inst1, inst2, h_flag_1);
	hazard haz2(inst0, inst2, h_flag_2);
	
	assign h_flag = (h_flag_1 || h_flag_2);
	
	
	stage1 one(clk, inst1, cpsr, regrd1, regrd2, regaddrOut1, regaddrOut2);
	
	stage2 two(clk, pc2, inst2, cpsr, regdata1, regdata2, memdataIn, result, s, newcond);
	
	stage3 three(clk, inst3, cpsr, regdata1_3, regdata2_3, memwr, memrd, memaddrIn, memaddrOut);//, memdataIn);
	
	stage4 four(clk, inst4, cpsr, result4, memdata, regwr, regaddrIn, regdataIn);
endmodule
		
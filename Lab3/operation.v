
module operation(
	input wire clk,
	input wire [31:0] inst0,
	input wire [31:0] regdata1, regdata2, memdata	
	
	output wire [3:0] regaddrIn, 
	output wire [3:0] regaddrOut1, regaddrOut2, 
	output wire [31:0] regdataIn,
	output wire regwr, regrd1, regrd2,
	output wire [31:0] memaddrIn, memaddrOut, memdataIn,
	output wire memwr, memrd,
	output wire bf
	);
	
	reg [31:0] inst1, inst2, inst3, inst4;
	always @(posedge clk) begin
		inst1 <= inst0;
		inst2 <= inst1;
		inst3 <= inst2;
		inst4 <= inst3;
	end
	
	
	stage1 one(clk, inst1, regrd1, regrd2, regaddrOut1, regaddrOut2);
	
	stage2 two(clk, inst2, regdata1, regdata2, memdataIn, regdataIn);
	
	stage3 three(clk, inst3, regdata2, memwr, memrd, memaddrIn, memaddrOut, memdataIn);
	
	stage4 four(clk, inst4, regwr, regaddrIn, regaddrOut2);
endmodule
		
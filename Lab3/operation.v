module operation(
	input wire clk,
	input wire [31:0] inst,
	input wire [31:0] regdata1, regdata2, memdata	
	
	output wire [3:0] regaddrIn, 
	output wire [3:0] regaddrOut1, regaddrOut2, 
	output wire [31:0] regdataIn,
	output wire regwr, regrd1, regrd2,
	output wire [31:0] memaddrIn, memaddrOut, memdataIn,
	output wire memwr, memrd,
	output wire bf
	);
	
	always @(posedge clk) begin
		inst1 <= inst;
		inst2 <= inst1;
		inst3 <= inst2;
		inst4 <= inst3;
		inst5 <= inst4;
	end
	
	stage2 two(clk, inst2, regrd1, regrd2, regaddrOut1, regaddrOut2);
	
	stage3 three(clk, inst3, result);
	
	stage4 four(clk, inst4, memwr, memrd, memaddrIn, memaddrOut, memdataIn);
	
	stage5 five(clk, inst5, regwr, regaddrIn, regaddrOut2);

endmodule
		
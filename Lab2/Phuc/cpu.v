module cpu(
	input wire clk,
	input wire nreset,
	output wire led,
	output wire [23:0] debug_port1,
	output wire [23:0] debug_port2,
	output wire [23:0] debug_port3,
	output wire [23:0] debug_port4,
	output wire [23:0] debug_port5,
	output wire [23:0] debug_port6,
	output wire [23:0] debug_port7
	);

	
	wire reset;
	wire [31:0] regdata1, regdata2, memdata;
	wire [31:0] inst;
	reg [31:0] inst_full [100:0];
	reg [31:0] pc;
	reg [1:0] state;
	wire [3:0] cond, op, rn, rd, rm; 
	wire [11:0] operand;
	wire [7:0] out1, out2, out3, out4, out5;
	wire b, l, t, s, ldr, str, p, u, bit, w;
	wire [23:0] offset;
	
	// Reg files and memory controller
	wire [3:0] regaddrIn, regaddrOut1, regaddrOut2;
	wire regwr, regrd1, regrd2, memwr, memrd;
	wire [31:0] regdataIn, memaddrIn, memaddrOut, memdataIn; 
	wire bf;
	wire [31:0] branchimm; 
	
	// Controls the LED on the board.
	assign led = 1'b1;
	assign reset = ~nreset;
	
	// Read in the instruction file
	initial begin
		$readmemb("inst.txt", inst_full);
	end
	
	assign inst = inst_full[pc];
	
	decode decoder(inst, b, l, t, s, ldr, str, p, u, bit, w, offset, cond, op, rn, rd, rm, operand, branchimm);

	cycles operation(clk, pc, state, op, b, l, t, s, ldr, str, p, u, bit, w, offset, cond, rn, rd, rm, operand, regdata1, regdata2, memdata,
						 regaddrIn, regaddrOut1, regaddrOut2, regdataIn, regwr, regrd1, regrd2, 
						 memaddrIn, memaddrOut, memdataIn, memwr, memrd, bf); 
	

	registers RAM(clk, regaddrIn, regaddrOut1, regaddrOut2, regdataIn, regwr, regrd1, regrd2, regdata1, regdata2);
	
	memory MEM(clk, memaddrIn, memaddrOut, memdataIn, memwr, memrd, memdata);
	
	
	
	interpreter inter(b, l, t, offset, op, rn, rd, rm, operand, out1, out2, out3, out4, out5);
	
	always @(posedge clk) begin
		if (reset) begin
			state <= 2'b00;
			pc <= 32'b0;
		end
		else begin
			if (state == 2'b11) begin
				if (!bf) pc <= pc + 1;
				else pc <= pc + ((branchimm + 4'b1000) >> 2);
				state <= 2'b00;
			end
			else state <= state + 1'b1;
		end
	end
	
	
	// These are how you communicate back to the serial port debugger.
	assign debug_port1 = pc << 2;
	assign debug_port2 = cond;
	
	
	// Logic for register fields
	assign debug_port3 = out1;
	assign debug_port4 = out2;
	assign debug_port5 = out3;
	assign debug_port6 = out4;	
	assign debug_port7 = out5;
	

endmodule

module cpu_testbench();
	reg clk, nreset;
	wire led;
	wire [7:0] debug_port1,debug_port2, debug_port3, debug_port4, 
				  debug_port5, debug_port6, debug_port7;

	cpu dut(clk, nreset, led, debug_port1, debug_port2, debug_port3, 
					 debug_port4, debug_port5, debug_port6, debug_port7);

	// Set up the clock.
	always begin
		clk = 1; #5; clk = 0; #5;
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	integer i;
	initial begin
						#10;
		nreset <= 0;	#10;
		nreset <= 1; #700;
  end
endmodule
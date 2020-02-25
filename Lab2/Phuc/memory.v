/*
  Manipulate the registers

  Input:
    clk		: clock signal
    addrIn  : 32-bit input address
    addrOut : 32-bit output address
    dataIn  : 32-bit input data
    wr      : write signal
    rd1		: read signals

  Output:
    dataOut: data at the requested address
*/
module memory(
	input wire clk,
	input wire [31:0] addrIn,
	input wire [31:0] addrOut,
	input wire [31:0] dataIn,
	input wire wr, rd,
	output wire [31:0] dataOut) ;
	
	reg [7:0] mem [31:0];
	reg [31:0] out;
	
	integer i;		

	assign dataOut = out;
	
	// Initial Block
	initial begin
		for (i=0; i < 2**31; i = i + 1) 
			mem[i] = 32'b0;
	end
	
	always @(posedge clk) begin
		if (wr) begin
			mem[addrIn] <= dataIn[7:0];
			
			if (addrIn < (~32'b0)) mem[addrIn + 32'b1] <= dataIn[15:8];
			else mem[addrIn - (~32'b0) + 32'b1] <= dataIn[15:8];
			
			if (addrIn + 32'b1 < (~32'b0)) mem[addrIn + 32'b10] <= dataIn[23:16];
			else mem[addrIn - (~32'b0) + 32'b10] <= dataIn[23:16]; 
			
			if (addrIn + 32'b10 < (~32'b0)) mem[addrIn + 32'b11] <= dataIn[31:24];
			else mem[addrIn - (~32'b0) + 32'b11] <= dataIn[31:24];
		end
		if (rd) begin
			out[7:0] <= mem[addrOut];
			
			if (addrOut < (~32'b0)) out[15:8] <= mem[addrOut + 32'b1];
			else out[15:8] <= mem[addrOut - (~32'b0) + 32'b1];
			
			if (addrOut + 32'b1 < (~32'b0)) out[15:8] <= mem[addrOut + 32'b1];
			else out[23:16] <= mem[addrOut - (~32'b0) + 32'b10];
			
			if (addrOut + 32'b10 < (~32'b0)) out[15:8] <= mem[addrOut + 32'b1];
			else out[31:24] <= mem[addrOut - (~32'b0) + 32'b11];
		end
	end
endmodule
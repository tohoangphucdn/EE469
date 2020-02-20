/*
  Manipulate the registers

  Input:
    clk		: clock signal
    addrIn  : 4-bit input address
    addrOut1: 4-bit output address
	 addrOut2: 4-bit output address
    dataIn  : 32-bit input data
    wr      : write signal
    rd1, rd2: read signals

  Output:
    dataOut1: data at the requested address #1
	 dataOut2: data at the requested address #2
*/
module memory(
	input wire clk,
	input wire [31:0] addrIn,
	input wire [31:0] addrOut,
	input wire [31:0] dataIn,
	input wire wr, rd,
	output wire [31:0] dataOut) ;
	
	reg [31:0] mem [31:0];
	reg [31:0] out;
	
	integer i;		

	assign dataOut = out;
	
	// Initial Block
	initial begin
		for (i=0; i < 2**31; i = i + 1) 
			mem[i] = 32'b0;
	end
	
	always @(posedge clk) begin
		if (wr)
			mem[addrIn] <= dataIn;
		if (rd)
			out <= mem[addrOut];
	end
endmodule
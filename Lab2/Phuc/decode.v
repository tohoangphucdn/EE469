/* Break instructions to parts

	Input:
		inst: 32-bit instruction
	
	Output:
		bout, lout	: B and BL indicator
		otout			: operand type. 1 if number and 0 otherwise
		offset		: offset for branch
		cond			: condition code
		op				: opcode
		rn, rd, rm	: rn, rd and rm from instruction
		operand		: full operand code
*/
module decode(
	input wire [31:0] inst,
	output wire bout,lout, otout, sout
	output wire [23:0] offset,
	output wire [3:0] cond, op, rn, rd, rm,
	output wire [11:0] operand
	);
	
	reg [3:0] rn_temp, rd_temp, rm_temp, r1_temp, r2_temp, type;
	reg optype;
	reg b, l;

	assign cond = inst[31:28];
	assign op = inst[24:21];
	assign operand = inst[11:0];
	assign otout  = inst[25];
	assign sout = inst[20];
	assign offset = inst[23:0];
	
  
	assign rn = rn_temp;
	assign rd = rd_temp;
	assign rm = rm_temp;
	assign bout = b;
	assign lout = l;
	
	always @ ( * ) begin
		type = inst[27:24];
		rn_temp = 4'b0; rd_temp = 4'b0; rm_temp = 4'b0;
		case (type)
			4'b1010: begin 
							b = 1'b1; 
							l = 1'b0; 						
						end
			4'b1011: begin 
							b = 1'b1; 
							l = 1'b1; 
						end
			default: begin		
							b = 1'b0;
							l = 1'b0;
							rn_temp = inst[19:16];
							rd_temp = inst[15:12];
							rm_temp = inst[3:0];
						end
		endcase		
	end
endmodule


//   case(condcode)
    // 4'b0000: cond = 0; // EQ
    // 4'b0001: cond = 1; // NE
    // 4'b0010: cond = 2; // CS/HS
    // 4'b0011: cond = 3; // CC/LO
    // 4'b0100: cond = 4; // MI
    // 4'b0101: cond = 5; // PL
    // 4'b0110: cond = 6; // VS
    // 4'b0111: cond = 7; // VC
    // 4'b1000: cond = 8; // HI
    // 4'b1001: cond = 9; // LS
    // 4'b1010: cond = 10; // GE
    // 4'b1011: cond = 11; // LT
    // 4'b1100: cond = 12; // GT
    // 4'b1101: cond = 13; // LE
    // 4'b1110: cond = 14; // AL
    // 4'b1111: cond = 15; // --
  // endcase
  //

  // assign condition = ["EQ","NE","CS/HS","CC/LO","MI","PL","VS","VC","HI","LS","GE","LT","GT","LE","AL","-"];
  // assign operation = ["AND","EOR","SUB","RSB","ADD","ADC","SBC","RSC","TST","TEQ","CMP","CMN","ORR","MOV","BIC","MVN"];

module decode_testbench();
	reg clk;	
	reg [31:0] inst;
	wire bout, lout, otout;
	wire [31:0] offset;
	wire [3:0] cond, op, rn, rd, rm;
	wire [11:0] operand;

	decode dut(inst, bout, lout, otout, offset, cond, op, rn, rd, rm, operand);

	// Set up the clock.
	always begin
		clk = 1; #5; clk = 0; #5;
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	integer i;
	initial begin
																		#10;
		inst <= 32'b11100011101000000111000000000000;	#10;
																		#10;
  end
endmodule

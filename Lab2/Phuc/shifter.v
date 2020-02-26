module shifter(shift, rm, out, c_flag); //shifted register
	input wire [7:0] shift;
	input wire [3:0] rm;
	output reg [3:0] out;
	output reg c_flag;
	
	reg [4:0] shift_amount; 
	reg [1:0] shift_type;
	wire do_shift_amount, do_shift_register;
	
	assign do_shift_amount = (!shift[0]) ? 1'b1 : 1'b0;
	
	
	always @(*) begin
		shift_amount = shift[7:3];
		shift_type = shift[2:1];
	end
	
	/*integer i = shift[7]*(2**4) + shift[6]*(2**3) + shift[5]*(2**2) + shift[4]*2 + shift[3];
	
	rotout = {rm[3-i:0],r[3:3-i+1]};*/
	
	always @(*) begin
		//if (do_shift_amount) begin
			case(shift_type)
			
			//logical shift left
			2'b00: begin
						c_flag = rm[3-shift_amount];
						out = rm << shift_amount;
					 end
					
			
			//logical shift right
			2'b01: begin
						c_flag = rm[shift_amount - 1];
						out = rm >> shift_amount;
					end 	
			
			//arithmetic shift right
			2'b10: begin
						c_flag = rm[shift_amount - 1];
						out = rm >>> shift_amount;
					 end
					 
			//arithmetic shift left
			2'b11: begin
						c_flag = rm[4-shift_amount];
						out = rm <<< shift_amount;
					 end
			default: begin c_flag = 0; out = 0; end
			endcase
					 
	end
		
	
			
endmodule


module shifter_testbench();
	reg [7:0] shift;
	reg [3:0] rm;
	wire [3:0] out;
	wire c_flag;
	
	reg [4:0] shift_amount; 
	reg  [1:0] shift_type;
	wire do_shift_amount, do_shift_register;

	shifter dut(shift, rm, out, c_flag);

	// Set up the inputs to the design. Each line is a clock cycle.
	integer i;
	initial begin
																				
			shift <= 8'b00001000; rm <= 32'h4A75DF23;             #10;
			shift <= 8'b00010010; rm <= 32'h4A75DF23;					#10;
																					#10;
																					#10;
																					#10;
  end
  
endmodule


		
		
				
module shifter(shift, data, out, c_flag); //shifted register
	input wire [7:0] shift;
	input wire [31:0] data;
	output reg [31:0] out;
	output reg c_flag;
	
	wire [4:0] shift_amount; 
	wire [1:0] shift_type;
	wire do_shift_amount, do_shift_register;
	
	assign do_shift_amount = (!shift[0]) ? 1'b1 : 1'b0;
	
	assign shift_amount = shift[7:3];
	assign shift_type = shift[2:1];
	
	
	always @(*) begin
		//if (do_shift_amount) begin
			case(shift_type)
			
			//logical shift left
			2'b00: begin
						c_flag = data[31-shift_amount];
						out = data << shift_amount;
					 end
					
			
			//logical shift right
			2'b01: begin
						c_flag = data[shift_amount - 1];
						out = data >> shift_amount;
					end 	
			
			//arithmetic shift right
			2'b10: begin
						c_flag = data[shift_amount - 1];
						out = data >>> shift_amount;
					 end
					 
			//rotating right
			2'b11: begin
						c_flag = 0;
						if (shift_amount == 0) begin
							out = data;
						end
						else out = (data << (32-shift_amount)) + (data >> shift_amount);
					 end
			endcase					 
	end
		
	
			
endmodule


module shifter_testbench();
	reg [7:0] shift;
	reg [31:0] data;
	wire [31:0] out;
	wire c_flag;

	shifter dut(shift, data, out, c_flag);

	// Set up the inputs to the design. Each line is a clock cycle.
	integer i;
	initial begin
																				
			shift <= 8'b00001000; data <= 32'h4A75DF23;             #10;
			shift <= 8'b00010010; data <= 32'h4A75DF23;					#10;
																					#10;
																					#10;
																					#10;
  end
  
endmodule
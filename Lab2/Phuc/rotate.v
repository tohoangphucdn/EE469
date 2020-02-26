module rotate ( 
	input wire [3:0] rotate_amount, 
	input wire [7:0] value,
	output wire [31:0] out_rotate,
	output wire c_flag
	);
	
	reg [7:0] out;
	wire [31:0] temp_value;
	wire [4:0] true_rot;
	
	assign out_rotate = out;
	assign true_rot = {rotate_amount,1'b0};
	assign temp_value = {24'b0,value};
	assign c_flag = 0;
	
	always @(*) begin	
		if (true_rot == 0) out = temp_value;
		else out = (temp_value >> true_rot) + (temp_value << (32 - true_rot));
	end
			
endmodule

module rotate_testbench();
	reg [3:0] rotate_amount;
	reg [7:0] value;
	wire[31:0] out_rotate;
	wire c_flag;	

	rotate dut(rotate_amount, value, out_rotate);


	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
																					#10;
		// rotate by 4  																			
		rotate_amount <= 4'b0100; value <= 8'b01000100;				#10;
																					#10;
		// rotate by 2  																			
		rotate_amount <= 4'b0010; value <= 8'b01000100;				#10;
																					#10;
		// rotate by 15  																			
		rotate_amount <= 4'b1111; value <= 8'b01000100;				#10;
																					#10;
		// rotate by 0  																			
		rotate_amount <= 4'b0000; value <= 8'b01000100;				#10;
																					#10;
																					#10;
  end
endmodule

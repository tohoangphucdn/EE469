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
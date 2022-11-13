module cpu_top (
	input [7:0] io_in,
	output [7:0] io_out
);
	
	cpu cpu(.INSTRUCTION(io_in[6:1]), .CLK(io_in[0]), .RESET(io_in[7]), 
		.PC(io_out[7:4]), .DATA(io_out[3:0])
  );
	
endmodule

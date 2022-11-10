module top (
	input [21:0] io_in,
	output [16:0] io_out
);
	
	cpu cpu(.INSTRUCTION(io_in[8:0]), .write_en(io_in[9]), .CLK(io_in[10]), 
		.RESET(io_in[11]), .RD(io_in[12]), .CS(io_in[13]), .INALU(io_in[21:14]),
					.PC(io_out[8:0]), .ALURESULT(io_out[16:9])
				 );
	
endmodule

module top (
	input [22:0] io_in,
	output [17:0] io_out
);
	
	input [8:0] INSTRUCTION,
  input       write_en,
  input       CLK, RESET, RD, CS,
  input [7:0] INALU,
  output [8:0] PC,
  output [7:0] ALURESULT
	
	cpu cpu(.INSTRUCTION(io_in[8:0]), .write_en(io_in[9]), .CLK(io_in[10]), 
					.RESET(io_in[11]), .RD(io_in[12]), .CS(io_in[13]), .INALU(io_in[22:14]),
					.PC(io_out[8:0]), .ALURESULT(io_out[17:9])
				 );
	
endmodule

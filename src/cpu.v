`default_nettype none

module cpu(
    input [8:0] INSTRUCTION,
    input       write_en,
    input       CLK, RESET,
    output      PC
);

reg PC;
wire PCRESULT;
reg [8:0] accumulator;
reg [8:0] input_reg;

wire [9:0] sum;

reg isAdd;
reg isImediate;
reg [7:0] immediateVal;
wire [7:0] mux1out;
wire [7:0] mux2out;
wire [7:0] minusVal;
reg [7:0] IN;
wire [7:0] OUT2;

assign sum = input_reg + accumulator;
assign PC = sum[9];

// adder to update pc from 4
adder myadder(PC, PCRESULT);
always @(posedge CLK) begin
   PC = PCRESULT;
end

always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        input_reg <= 9'h00 ;
        accumulator <= 9'h00;
    end else begin
        accumulator <= sum[8:0];
	      if (write_en) begin
          input_reg <= INSTRUCTION;
        end
    end
end

//multiplexer to choose between minus value and plus value
mux2_1 mymux1(OUT2, minusVal, isAdd, mux1out);

//multiplexer to chose between immediate value and mux1 output
mux2_1 mymux2(immediateVal, mux1out, isImediate, mux2out);

endmodule

module adder(
  input [31:0] PCINPUT,
  output [31:0] RESULT
);

  reg RESULT;

  always @(PCINPUT) begin
    RESULT = PCINPUT + 4;
  end
endmodule

module mux2_1(
  input [7:0] in0,
  input [7:0] in1,
  input se1,
  output [7:0] out
);

  reg out;

  always @(in0, in1, se1) begin
    if(se1 == 1'b1) begin
          out = in0;
    end
    else begin
          out = in1;
    end
  end
endmodule

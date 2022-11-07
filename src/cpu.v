`default_nettype none

module cpu(
  input [8:0] INSTRUCTION,
  input       write_en,
  input       CLK, RESET,
  output [8:0] PC
);

  wire [8:0] PCRESULT;
  reg [8:0] accumulator;
  reg [8:0] input_reg;

  wire [9:0] sum;

  reg isAdd;
  reg isImediate;
  reg [2:0] aluOp;
  reg [7:0] immediateVal;
  wire [7:0] mux1out;
  wire [7:0] mux2out;
  wire [7:0] ALURESULT;
  wire [7:0] minusVal;

  reg [7:0] IN;
  wire [7:0] OUT1;
  wire [7:0] OUT2;

  reg [7:0] OPCODE;
  reg [2:0] DESTINATION;
  reg [2:0] SOURCE1;
  reg [2:0] SOURCE2;

  assign sum = input_reg + accumulator;
  assign PC = sum[9];

  // adder to update pc from 4
  adder myadder(PC, PCRESULT);
  // DOESN'T COMPILE
  // always @(posedge CLK) begin
  //    PC = PCRESULT;
  // end

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

  always @(INSTRUCTION) begin
    OPCODE = INSTRUCTION[4:1];
    case (OPCODE)
      8'b00000000: begin
        aluOp = 3'b000;
        isAdd = 1'b1;
        isImediate = 1'b1;
      end
      8'b00000001: begin
        aluOp = 3'b000;
        isAdd = 1'b1;
        isImediate = 1'b0;
      end
      8'b00000010: begin
        aluOp = 3'b001;
        isAdd = 1'b1;
        isImediate = 1'b0;
      end
      8'b00000011: begin
        aluOp = 3'b001;
        isAdd = 1'b0;
        isImediate = 1'b0;
      end
      8'b00000100: begin
        aluOp = 3'b010;
        isAdd = 1'b1;
        isImediate = 1'b0;
      end
      8'b00000101: begin
        aluOp = 3'b011;
        isAdd = 1'b1;
        isImediate = 1'b0;
      end
    endcase
  end

  // including the registers
  reg_file myReg(IN, OUT1, OUT2, DESTINATION, SOURCE1, SOURCE2, write_en, CLK, RESET);
  always @(INSTRUCTION) begin
    DESTINATION  = INSTRUCTION[6:5];
    SOURCE1   = INSTRUCTION[8:7];
    SOURCE2 = INSTRUCTION[1:0];
    immediateVal = INSTRUCTION[7:0];
  end

  // compliments two units for subtraction
  twosCompliment mytwo(OUT2, minusVal);

  //multiplexer to choose between minus value and plus value
  mux2_1 mymux1(OUT2, minusVal, isAdd, mux1out);

  //multiplexer to chose between immediate value and mux1 output
  mux2_1 mymux2(immediateVal, mux1out, isImediate, mux2out);

  // alu module
  alu myalu(OUT1, mux2out, ALURESULT, aluOp, OUT2);

endmodule

module adder(
  input [8:0] PCINPUT,
  output [8:0] RESULT
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

module twosCompliment(
    input [7:0] in,
    output [7:0] result
);

  reg result;
  always @(*) begin
    result = ~in+1;
  end
endmodule

module reg_file(
  input [7:0] IN,
  output [7:0] OUT1,
  output [7:0] OUT2,
  input [2:0] INADDRESS,
  input [2:0] OUT1ADDRESS,
  input [2:0] OUT2ADDRESS,
  input WRITE,
  input CLK,
  input RESET
);

  integer i;
  reg [7:0] regFile [0:7];
  always @(*) begin
    if (RESET == 1) begin
      for (i = 0; i < 8; i = i + 1) begin
        regFile[i] = 8'b00000000;
      end
    end
  end

  always @(posedge CLK) begin
    if (WRITE == 1'b1 && RESET == 1'b0) begin
      regFile[INADDRESS] = IN;
    end
  end

  assign OUT1 = regFile[OUT1ADDRESS];
  assign OUT2 = regFile[OUT2ADDRESS];
endmodule

module alu(
  input [7:0] DATA1,
  input [7:0] DATA2,
  input [7:0] RESULT,
  input [2:0] SELECT,
  output ZERO
);

  reg [7:0] RESULT;
  reg ZERO;
  reg [7:0] RshiftResult;
  // NOT DEFINED YET
  //barrelShifter myRightLogicalShifter(DATA1,DATA2[7:5],RshiftResult);

  always @(DATA1,DATA2,SELECT) begin
   //selecting based on the SELECT input using s switch case
   case(SELECT)
     3'b000: begin
      RESULT = DATA2; //Forward function
     end
     3'b001: begin
      RESULT = DATA1 + DATA2; //Add and Sub function
     end
     3'b010: begin
      RESULT = DATA1 & DATA2; //AND and Sub function
     end
     3'b011: begin
      RESULT = DATA1 | DATA2; //OR and Sub function
     end
     3'b100: begin
      RESULT = RshiftResult;
     end
     3'b101: begin
      RESULT = 8'b00000000;
     end
     3'b110: begin
      RESULT = 8'b00000000;
     end
     3'b111: begin
      RESULT = 8'b00000000;
     end
   endcase
 end

 // creating the ZERO bit using the alu result
 //modified part
 always @(RESULT) begin
  ZERO = RESULT[0]~|RESULT[1]~|RESULT[2]~|RESULT[3]~|RESULT[4]~|RESULT[5]~|RESULT[6]~|RESULT[7];
 end
endmodule

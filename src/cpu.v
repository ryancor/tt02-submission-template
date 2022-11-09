`default_nettype none

module cpu(
  input [8:0] INSTRUCTION,
  input       write_en,
  input       CLK, RESET, RD, CS,
  input [7:0] INALU,
  output [7:0] OUT1,
  output [7:0] OUT2,
  output [8:0] PC,
  output [7:0] ALURESULT
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
  wire [7:0] minusVal;

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
  reg_file myReg(INALU, OUT1, OUT2, DESTINATION, SOURCE1, SOURCE2, write_en, CLK, RESET);
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
  alu myalu(OUT1, mux2out, ALURESULT, aluOp);
  always@(ALURESULT) begin
    INALU = ALURESULT;  //setting the reg input with the alu result
  end

  // store data to ram
  staticRAM SRAM(input_reg, ALURESULT, PCRESULT, CS, write_en, RD, CLK);
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
  output [7:0] RESULT,
  input [2:0] SELECT,
  output ZERO
);

  reg [7:0] RESULT;
  reg ZERO;
  reg [7:0] RshiftResult;
  barrelShifter myRightLogicalShifter(DATA1, DATA2[7:5], RshiftResult);

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

module staticRAM(
  input [8-1:0] dataIn,
  output [8-1:0] dataOut,
  input [8-1:0] Addr,
  input CS,
  input WE,
  input RD,
  input Clk
);

  reg [8-1:0] dataOut;
  reg [8-1:0] SRAM [8-1:0];


  always @ (posedge Clk) begin
    if (CS == 1'b1) begin
      if (WE == 1'b1 && RD == 1'b0) begin
        SRAM [Addr] = dataIn;
      end
      else if (RD == 1'b1 && WE == 1'b0) begin
        dataOut = SRAM [Addr];
      end
    end
  end
endmodule


module barrelShifter(
  input [7:0] Ip,
  output [7:0] Op,
  input [2:0] shift_mag
);

  wire [7:0] ST1, ST2;

  mux2_1 m0(1'b0, Ip[0], shift_mag[0], ST1[0]);
  mux2_1 m1(Ip[0], Ip[1], shift_mag[0], ST1[1]);
  mux2_1 m2(Ip[1], Ip[2], shift_mag[0], ST1[2]);
  mux2_1 m3(Ip[2], Ip[3], shift_mag[0], ST1[3]);
  mux2_1 m4(Ip[3], Ip[4], shift_mag[0], ST1[4]);
  mux2_1 m5(Ip[4], Ip[5], shift_mag[0], ST1[5]);
  mux2_1 m6(Ip[5], Ip[6], shift_mag[0], ST1[6]);
  mux2_1 m7(Ip[6], Ip[7], shift_mag[0], ST1[7]);

  mux2_1 m00(1'b0, Ip[0], shift_mag[1], ST1[0]);
  mux2_1 m11(1'b0, Ip[1], shift_mag[1], ST1[1]);

  mux2_1 m22 (ST1[0], ST1[2], shift_mag[1], ST2[2]);
  mux2_1 m33 (ST1[1], ST1[3], shift_mag[1], ST2[3]);
  mux2_1 m44 (ST1[2], ST1[4], shift_mag[1], ST2[4]);
  mux2_1 m55 (ST1[3], ST1[5], shift_mag[1], ST2[5]);
  mux2_1 m66 (ST1[4], ST1[6], shift_mag[1], ST2[6]);
  mux2_1 m77 (ST1[5], ST1[7], shift_mag[1], ST2[7]);

  mux2_1 m000 (1'b0  , ST2[0], shift_mag[2], Op[0]);
  mux2_1 m111 (1'b0  , ST2[1], shift_mag[2], Op[1]);
  mux2_1 m222 (1'b0  , ST2[2], shift_mag[2], Op[2]);
  mux2_1 m333 (1'b0  , ST2[3], shift_mag[2], Op[3]);
  mux2_1 m444 (ST2[0], ST2[4], shift_mag[2], Op[4]);
  mux2_1 m555 (ST2[1], ST2[5], shift_mag[2], Op[5]);
  mux2_1 m666 (ST2[2], ST2[6], shift_mag[2], Op[6]);
  mux2_1 m777 (ST2[3], ST2[7], shift_mag[2], Op[7]);

endmodule

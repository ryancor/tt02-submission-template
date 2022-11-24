// Code your testbench here
// or browse Examples
module tb_alu;
	reg [1:0] A,B;
	reg [3:0] ALU_Sel;

  wire [6:0] ALU_Out;
  wire CarryOut;

 	//integer i;

  alu test_unit(
    .A(A),
    .B(B),  // ALU 2-bit Inputs
    .ALU_Sel(ALU_Sel),// ALU Selection
    .ALU_Out(ALU_Out), // ALU 7-bit Output
    .CarryOut(CarryOut) // Carry Out Flag
  );

	initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);

    $display("ALU.");

    // hold reset state for 100 ns.
    A = 2'b00;
    B = 2'b11;
    ALU_Sel = 4'b1111;

    #20;

    A = 2'b10;
    B = 2'b01;
    ALU_Sel = 4'b1011;

    #20

    // for (i=0;i<=15;i=i+1) begin
    //   ALU_Sel = ALU_Sel + 8'h01;
    //   #10;
    // end

    A = 2'b01;
    B = 2'b11;
    ALU_Sel = 4'b1010;

    #20;

    A = 2'b10;
    B = 2'b11;
    ALU_Sel = 4'b0001;

    #20;

    A = 2'b11;
    B = 2'b01;
    ALU_Sel = 4'b0011;

    #20;

    A = 2'b11;
    B = 2'b01;
    ALU_Sel = 4'b0111;

    #20;

    A = 2'b01;
    B = 2'b01;
    ALU_Sel = 4'b0101;

    #20;

    A = 2'b10;
    B = 2'b10;
    ALU_Sel = 4'b0000;

    #20;

    A = 2'b10;
    B = 2'b01;
    ALU_Sel = 4'b0010;

    #20;
  end
endmodule

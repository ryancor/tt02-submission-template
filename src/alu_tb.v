module tb_alu;
	reg [7:0] A,B;
	reg [3:0] ALU_Sel;

	wire [7:0] ALU_Out;
	wire CarryOut;

 	//integer i;

  alu test_unit(
    .A(A),
    .B(B),  // ALU 8-bit Inputs
    .ALU_Sel(ALU_Sel),// ALU Selection
    .ALU_Out(ALU_Out), // ALU 8-bit Output
    .CarryOut(CarryOut) // Carry Out Flag
  );

	initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);

    $display("ALU.");

    // hold reset state for 100 ns.
    A = 8'h0A;
    B = 8'h02;
    ALU_Sel = 4'b1111;

    #20;

    A = 8'h0B;
    B = 8'h03;
    ALU_Sel = 4'b1011;

    #20

    // for (i=0;i<=15;i=i+1) begin
    //   ALU_Sel = ALU_Sel + 8'h01;
    //   #10;
    // end

    A = 8'hF6;
    B = 8'h0A;
    ALU_Sel = 4'b1010;

    #20;

    A = 8'hA0;
    B = 8'hC7;
    ALU_Sel = 4'b0001;

    #20;

    A = 8'h23;
    B = 8'h05;
    ALU_Sel = 4'b0011;

    #20;

    A = 8'h10;
    B = 8'h02;
    ALU_Sel = 4'b0011;

    #20;

    A = 8'hA;
    B = 8'h02;
    ALU_Sel = 4'b0011;

    #20;
  end
endmodule

module cpu_tb;

  reg CLK, RESET;
  reg [8:0] INSTRUCTION;
  wire [8:0] PC;
  reg write_en;

  reg [7:0] instr_mem [1023:0];

  always @(PC) begin
    #2
    INSTRUCTION = {instr_mem[PC+1], instr_mem[PC+2], instr_mem[PC+1], instr_mem[PC]};
  end

  initial begin
    {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000000000000000000000000011;
    {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000000000100000000000100001;
    {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00001100000000100000000000100001;
    {instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]} = 32'b11000000110000100000110000100001;
  end

  cpu mycpu(INSTRUCTION, write_en, CLK, RESET, PC);

  initial begin
   // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1);

    $display("CPU.");

    CLK = 1'b1;
    RESET = 1'b0;

    #2
    RESET = 1'b1;

    #4
    RESET = 1'b0;

    #4
    RESET = 1'b1;

    #4
    write_en = 1'b1;
    RESET = 1'b0;

    #500
    $finish;
  end

  always
    #5 CLK = ~CLK;
endmodule

`timescale 1ns / 1ps

module barrelShifter_tb;

  reg [7:0] Ip;
  reg [2:0] shift_mag;
  wire [7:0] Op;

  barrelShifter uut (
    .Ip(Ip),
    .Op(Op),
    .shift_mag(shift_mag)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);

    $display("Barrel Shifter Init.");

    Ip    = 8'd0;
    shift_mag = 3'd0;

    #100;

    Ip    = 8'd16;
    shift_mag = 3'd2;

    #20;

    Ip    = 8'd4;
    shift_mag = 3'd2;

    #20;

    Ip    = 8'd44;
    shift_mag = 3'd1;

    #20;

    Ip    = 8'd6;
    shift_mag = 3'd2;

    #20

    Ip    = 8'd12;
    shift_mag = 3'd2;

    #20

    Ip    = 8'd10;
    shift_mag = 3'd2;
  end
endmodule

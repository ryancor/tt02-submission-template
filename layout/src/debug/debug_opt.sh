yosys -p "read_verilog alu.v" -p "hierarchy -top alu" -p "synth" -p "show alu"

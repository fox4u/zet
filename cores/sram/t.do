quit -sim
if {[file exists work]} {
  vdel -all -lib work
}

vlib work
vlog -work work -lint csr_ocram.v tb_csr_ocram.v

vsim -novopt -t ns work.tb_csr_ocram
add wave -radix hexadecimal -r /*
run 100us
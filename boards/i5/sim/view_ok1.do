quit -sim

vsim -view ok1.wlf

add wave -label clk -hex kotku/clk
add wave -label rst -hex kotku/rst

add wave -label pc  -hex kotku/pc
add wave -label st  -hex kotku/zet/core/fetch/state
add wave -label ns  -hex kotku/zet/core/fetch/next_state

add wave -label opcode     -hex kotku/zet/core/opcode
add wave -label modrm      -hex kotku/zet/core/modrm
add wave -label seq_addr   -hex kotku/zet/core/seq_addr
add wave -label end_seq    -hex kotku/zet/core/end_seq
add wave -label need_modrm -hex kotku/zet/core/need_modrm
add wave -label need_off   -hex kotku/zet/core/need_off
add wave -label off_size   -hex kotku/zet/core/off_size
add wave -label need_imm   -hex kotku/zet/core/need_imm
add wave -label imm_size   -hex kotku/zet/core/imm_size
add wave -label ir         -hex kotku/zet/core/ir
add wave -label imm        -hex kotku/zet/core/imm
add wave -label off        -hex kotku/zet/core/off

add wave -divider regfile
add wave -label ax  -hex kotku/zet/core/exec/regfile/r\[0\]
add wave -label bx  -hex kotku/zet/core/exec/regfile/r\[3\]
add wave -label cx  -hex kotku/zet/core/exec/regfile/r\[1\]
add wave -label dx  -hex kotku/zet/core/exec/regfile/r\[2\]
add wave -label si  -hex kotku/zet/core/exec/regfile/r\[6\]
add wave -label di  -hex kotku/zet/core/exec/regfile/r\[7\]
add wave -label sp  -hex kotku/zet/core/exec/regfile/r\[4\]
add wave -label es  -hex kotku/zet/core/exec/regfile/r\[8\]
add wave -label cs  -hex kotku/zet/core/exec/regfile/r\[9\]
add wave -label ss  -hex kotku/zet/core/exec/regfile/r\[10\]
add wave -label ds  -hex kotku/zet/core/exec/regfile/r\[11\]
add wave -label ip  -hex kotku/zet/core/exec/regfile/r\[15\]
add wave -label tmp -hex kotku/zet/core/exec/regfile/r\[13\]
add wave -label d   -hex kotku/zet/core/exec/regfile/d\[15:0\]
add wave -label wr  -hex kotku/zet/core/exec/regfile/wr

add wave -divider wb_master
add wave -label cpu_block -hex kotku/zet/cpu_block
add wave -label stb       -hex kotku/stb
add wave -label ack       -hex kotku/ack
add wave -label adr       -hex kotku/adr
add wave -label sel       -hex kotku/sel
add wave -label dat_o     -hex kotku/dat_o
add wave -label dat_i     -hex kotku/dat_i
add wave -label we        -hex kotku/we
add wave -label tga       -hex kotku/tga
add wave -label cs        -hex kotku/zet/wb_master/cs
add wave -label ns        -hex kotku/zet/wb_master/ns

add wave -divider flash
add wave -label stb     -hex kotku/u_flash_0/wb_stb_i
add wave -label we      -hex kotku/u_flash_0/wb_we_i
add wave -label addr    -hex kotku/u_flash_0/wb_adr_i
add wave -label data_i  -hex kotku/u_flash_0/wb_dat_i
add wave -label data_o  -hex kotku/u_flash_0/wb_dat_o
add wave -label ack     -hex kotku/u_flash_0/wb_ack_o

# add wave -divider alu
# add wave -label x       -hex kotku/zet/core/exec/a
# add wave -label y       -hex kotku/zet/core/exec/bus_b
# add wave -label t       -hex kotku/zet/core/exec/alu/t
# add wave -label func    -hex kotku/zet/core/exec/alu/func
# add wave -label d       -hex kotku/zet/core/exec/regfile/d
# add wave -label addr_a  -hex kotku/zet/core/exec/regfile/addr_a
# add wave -label addr_d  -hex kotku/zet/core/exec/regfile/addr_d
# add wave -label wr      -hex kotku/zet/core/exec/regfile/wr
# add wave -label exec_st -hex kotku/zet/core/exec_st
# 
# add wave -divider GPIO
# add wave -label ledg_   -hex kotku/ledg_
# add wave -label ledr_   -hex kotku/ledr_
add wave -divider intr
add wave -hex kotku/sw_dat_o
add wave -hex kotku/pic0/*

add wave -divider kotku
add wave -hex kotku/fmlbrg/*
add wave -hex kotku/fmlarb/*
add wave -hex kotku/hpdmc/*
add wave -divider vga
add wave -hex kotku/vga_clk
add wave -hex kotku/vga_dat_o
add wave -hex kotku/vga_dat_i
add wave -hex kotku/vga_tga_i
add wave -hex kotku/vga_adr_i
add wave -hex kotku/vga_sel_i
add wave -hex kotku/vga_we_i
add wave -hex kotku/vga_cyc_i
add wave -hex kotku/vga_stb_i
add wave -hex kotku/vga_ack_o
add wave -hex kotku/vga/lcd/*
add wave -hex kotku/vga/lcd/pal_dac/*
add wave -hex kotku/vga/lcd/sequencer/*
# add wave -hex kotku/vga/cpu_mem_iface/*
# add wave -hex kotku/vga/config_iface/*

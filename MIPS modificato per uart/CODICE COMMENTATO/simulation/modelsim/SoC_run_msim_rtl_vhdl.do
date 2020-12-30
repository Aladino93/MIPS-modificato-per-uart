transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {D:/progetti enrico mainetti/PROGETTONE/MIPS/uart_parity.vhd}
vcom -93 -work work {D:/progetti enrico mainetti/PROGETTONE/MIPS/hex_decoder.vhd}
vcom -93 -work work {D:/progetti enrico mainetti/PROGETTONE/MIPS/opcodes.vhd}
vcom -93 -work work {D:/progetti enrico mainetti/PROGETTONE/MIPS/uart_tx.vhd}
vcom -93 -work work {D:/progetti enrico mainetti/PROGETTONE/MIPS/uart_rx.vhd}
vcom -93 -work work {D:/progetti enrico mainetti/PROGETTONE/MIPS/rom.vhd}
vcom -93 -work work {D:/progetti enrico mainetti/PROGETTONE/MIPS/cpu.vhd}
vcom -93 -work work {D:/progetti enrico mainetti/PROGETTONE/MIPS/uart.vhd}
vcom -93 -work work {D:/progetti enrico mainetti/PROGETTONE/MIPS/ParallelInOut.vhd}


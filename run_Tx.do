vlib work
vlog Tx.v Tx_tb.v
vsim -voptargs=+acc work.uart_Tx_tb
add wave *
add wave -position insertpoint  \
sim:/uart_Tx_tb/DUT/state
run -all
#quit -sim
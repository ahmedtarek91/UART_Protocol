vlib work
vlog Rx.v Rx_tb.v
vsim -voptargs=+acc work.uart_Rx_tb
add wave *
add wave -position insertpoint  \
sim:/uart_Rx_tb/DUT/state
add wave -position insertpoint  \
sim:/uart_Rx_tb/DUT/tick_counter
run -all
#quit -sim
vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 \
"../../../../TempAlarm_NexysA7.gen/sources_1/ip/xadc_wiz_0_2/xadc_wiz_0.v" \


vlog -work xil_defaultlib \
"glbl.v"


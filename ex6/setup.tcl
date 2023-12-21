set_global_assignment -name FAMILY "Cyclone IV"
set_global_assignment -name DEVICE EP4CE40F23C8
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
# system clock and reset-------------------------
set_location_assignment PIN_G1  -to clk
set_location_assignment PIN_K21	-to rstn
# led--------------------------------------------
set_location_assignment PIN_D22	-to led0
set_location_assignment PIN_D21	-to led1
set_location_assignment PIN_N7	-to TXD
set_location_assignment PIN_U2	-to RXD
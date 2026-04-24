#!/bin/bash
iverilog -g2009 -o simv picosoc/picosoc.v picorv32.v picosoc/simpleuart.v picosoc/spimemio.v tb_freertos.v
vvp simv
surfer freertos.vcd
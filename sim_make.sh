 #!/bin/bash
iverilog -o qqq *.v -g2009
vvp qqq
surfer system.vcd

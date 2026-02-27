 #!/bin/bash
iverilog -g2009 -o qqq *.v
vvp qqq
surfer system.vcd

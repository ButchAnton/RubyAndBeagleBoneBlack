require 'beaglebone'
include Beaglebone

# The MCP9700A provides 500mV at 0C and 10mV/C change.

p9_40 = AINPin.new(:P9_40)

loop do
  millivolts = p9_40.read
  temp_c = (millivolts - 500) / 10.0
  temp_f = (temp_c * 9/5) + 32.0
  puts "millivolts: #{millivolts}, temp_c: #{temp_c}, temp_f: #{temp_f}"
  sleep(1)
end


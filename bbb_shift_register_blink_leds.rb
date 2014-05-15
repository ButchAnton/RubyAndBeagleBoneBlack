#!/usr/bin/env ruby

require 'beaglebone'
include Beaglebone

# Power (+5v) P9_5, red
# Ground P9_1, black

clock = :P9_11 # yellow, pin 11 on 595
latch = :P9_12 # green, pin 12 on 595
data = :P9_14 # orange, pin 14 on 595

shiftreg = ShiftRegister.new(latch, clock, data)

loop do

  # shift the LEDs in the forward direction
  
  for i in 0..7
    shiftreg.shift_out(0b00000001 << i)
    sleep(0.125)
  end

  # shift the LEDs in the reverse direction

  for i in 0..7
    shiftreg.shift_out(0b10000000 >> i)
    sleep(0.125)
  end

end


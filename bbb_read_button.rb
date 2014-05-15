#!/usr/bin/env ruby

require 'beaglebone'
include Beaglebone

pin8_12 = GPIOPin.new(:P8_12, :IN)

loop do
  state = pin8_12.digital_read
  puts state
  sleep(0.1)
end


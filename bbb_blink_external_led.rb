#!/usr/bin/env ruby

require 'beaglebone'
include Beaglebone

5.times do
  led1 = GPIOPin.new(:P8_10, :OUT)
  led1.digital_write(:HIGH)
  sleep(1)
  led1.digital_write(:LOW)
  sleep(1)
end

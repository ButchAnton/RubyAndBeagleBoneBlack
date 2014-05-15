require 'beaglebone'
include Beaglebone

# You can't use all the PWM pins at the same time.  For this
# demo, we will use the following, which can be used at the same time:
# P8_13
# P9_14
# P9_21

red = :P8_13
green = :P9_21
blue = :P9_14

def fade(colorA, colorB, ignore_color)
  PWM.set_duty_cycle(ignore_color, 100)
  (0..100).each do |i|
    PWM.set_duty_cycle(colorA, i)
    PWM.set_duty_cycle(colorB, 100-i)
    sleep(0.05)
  end
end

PWM.start(red, 0)
PWM.start(green, 0)
PWM.start(blue, 0)

loop do
  fade(red, green, blue)
  fade(green, blue, red)
  fade(blue, red, green)
end


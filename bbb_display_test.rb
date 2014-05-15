require 'beaglebone'
include Beaglebone

# This code is specific to the Winstar WH2004A-CFH-JT# 20x4 RGB
# backlight display.

# Commands
LCD_CLEARDISPLAY        = 0x01
LCD_RETURNHOME          = 0x02
LCD_ENTRYMODESET        = 0x04
LCD_DISPLAYCONTROL      = 0x08
LCD_CURSORSHIFT         = 0x10
LCD_FUNCTIONSET         = 0x20
LCD_SETCGRAMADDR        = 0x40
LCD_SETDDRAMADDR        = 0x80

# Entry flags
LCD_ENTRYRIGHT          = 0x00
LCD_ENTRYLEFT           = 0x02
LCD_ENTRYSHIFTINCREMENT = 0x01
LCD_ENTRYSHIFTDECREMENT = 0x00

# Control flags
LCD_DISPLAYON           = 0x04
LCD_DISPLAYOFF          = 0x00
LCD_CURSORON            = 0x02
LCD_CURSOROFF           = 0x00
LCD_BLINKON             = 0x01
LCD_BLINKOFF            = 0x00

# Move flags
LCD_DISPLAYMOVE         = 0x08
LCD_CURSORMOVE          = 0x00
LCD_MOVERIGHT           = 0x04
LCD_MOVELEFT            = 0x00

# Function set flags
LCD_8BITMODE            = 0x10
LCD_4BITMODE            = 0x00
LCD_2LINE               = 0x08
LCD_1LINE               = 0x00
LCD_5x10DOTS            = 0x04
LCD_5x8DOTS             = 0x00

# Offset for up to 4 rows.
LCD_ROW_OFFSETS         = [0x00, 0x40, 0x14, 0x54]

# Pin setup for the BBB
RS = :P8_8
EN = :P8_10
D4 = :P8_18
D5 = :P8_16
D6 = :P8_14
D7 = :P8_12
LCD_RED = :P9_16
LCD_GREEN = :P9_14
LCD_BLUE = :P8_13
COLUMNS = 20
LINES = 4

# Display status variables
$displaycontrol = 0
$displayfunction = 0
$displaymode = 0

def init
  # Set the output state of all the pins we'll use
  GPIO.pin_mode(D4, :OUT)
  GPIO.pin_mode(D5, :OUT)
  GPIO.pin_mode(D6, :OUT)
  GPIO.pin_mode(D7, :OUT)
  GPIO.pin_mode(RS, :OUT)
  GPIO.pin_mode(EN, :OUT)
  PWM.start(LCD_RED)
  PWM.start(LCD_GREEN)
  PWM.start(LCD_BLUE)

  # Initialize the display.  Magic values -- don't know where they
  # came from nor what they do.  :-(
  # It looks like they could be the Function Set for the display
  # but we're sending 0011 0011 followed by 0011 0010, so
  # I'm not completely sure, because those values don't really
  # make sense based on the data sheet.
  
  write8bit(0x33)
  write8bit(0x32)

  # Set up the display to a reasonable initial state
  $displaycontrol = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF
  $displayfunction = LCD_4BITMODE | LCD_1LINE | LCD_2LINE | LCD_5x8DOTS
  $displaymode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT
  write8bit(LCD_DISPLAYCONTROL | $displaycontrol)
  write8bit(LCD_FUNCTIONSET | $displayfunction)
  write8bit(LCD_ENTRYMODESET | $displaymode)
  clear()
end

# Busy wait for specified number of microseconds

def delay_microseconds(microseconds)
  end_time = Time.now.to_f + (microseconds / 1000000)
  while (Time.now.to_f < end_time)
    # do nothing
  end
end

# Toggle the enable state Low/High/Low to send a command.

def pulse_enable(enable_pin = EN)
  # Signal needs to be present for more than ~450ns
  GPIO.digital_write(enable_pin, :LOW)
  delay_microseconds(1)
  GPIO.digital_write(enable_pin, :HIGH)
  delay_microseconds(1)
  GPIO.digital_write(enable_pin, :LOW)
  delay_microseconds(1)
end

def normalize_bit_to_logic(value)
  if value == 0 || value == false
    return :LOW
  else
    return :HIGH
  end
end

def normalize_bit_to_binary(value)
  if value == 0 || value == false
    return 0
  else
    return 1
  end
end

def write8bit(value, character_mode = false)

  high_nibble = ""
  low_nibble = ""

  # printf("write8bit: value = %d, 0x%x, %08b\n", value, value, value)

  # Convert true/false to digital logic (high/low)
  if (character_mode == true)
    character_mode = :HIGH
  else
    character_mode = :LOW
  end

  # Sleep a bit to prevent collisions

  delay_microseconds(1000)

  # Set the write mode (data or character)
  # puts "write8bit: character_mode: #{character_mode}"
  GPIO.digital_write(RS, character_mode)

  # Write upper four bits
  bit = normalize_bit_to_binary(((value >> 4) & 1) > 0)
  GPIO.digital_write(D4, normalize_bit_to_logic(bit))
  # puts "write8bit: writing upper D4: #{bit}"
  high_nibble = bit.to_s + high_nibble

  bit = normalize_bit_to_binary(((value >> 5) & 1) > 0)
  GPIO.digital_write(D5, normalize_bit_to_logic(bit))
  # puts "write8bit: writing upper D5: #{bit}"
  high_nibble = bit.to_s + high_nibble

  bit = normalize_bit_to_binary(((value >> 6) & 1) > 0)
  GPIO.digital_write(D6, normalize_bit_to_logic(bit))
  # puts "write8bit: writing upper D6: #{bit}"
  high_nibble = bit.to_s + high_nibble

  bit = normalize_bit_to_binary(((value >> 7) & 1) > 0)
  GPIO.digital_write(D7, normalize_bit_to_logic(bit))
  # puts "write8bit: writing upper D7: #{bit}"
  high_nibble = bit.to_s + high_nibble

  pulse_enable(EN)

  # Write lower four bits
  bit = normalize_bit_to_binary(((value ) & 1) > 0)
  GPIO.digital_write(D4, normalize_bit_to_logic(bit))
  # puts "write8bit: writing lower D4: #{bit}"
  low_nibble = bit.to_s + low_nibble

  bit = normalize_bit_to_binary(((value >> 1) & 1) > 0)
  GPIO.digital_write(D5, normalize_bit_to_logic(bit))
  # puts "write8bit: writing lower D5: #{bit}"
  low_nibble = bit.to_s + low_nibble

  bit = normalize_bit_to_binary(((value >> 2) & 1) > 0)
  GPIO.digital_write(D6, normalize_bit_to_logic(bit))
  # puts "write8bit: writing lower D6: #{bit}"
  low_nibble = bit.to_s + low_nibble

  bit = normalize_bit_to_binary(((value >> 3) & 1) > 0)
  GPIO.digital_write(D7, normalize_bit_to_logic(bit))
  # puts "write8bit: writing lower D7: #{bit}"
  low_nibble = bit.to_s + low_nibble

  pulse_enable(EN)

  # puts "write8bit: wrote #{high_nibble} #{low_nibble}"
end

def home
  write8bit(LCD_RETURNHOME)
  delay_microseconds(3000)
end

def clear
  write8bit(LCD_CLEARDISPLAY)
  delay_microseconds(3000)
end

def set_cursor(column, row)
  if (row > LINES)
    row = LINES - 1
  end
  write8bit(LCD_SETDDRAMADDR | (column + LCD_ROW_OFFSETS[row]))
end

def enable_display(enable)
  if enable
    $displaycontrol |= LCD_DISPLAYON
  else
    $displaycontrol &= ~LCD_DISPLAYON
  end
  write8bit(LCD_DISPLAYCONTROL | $displaycontrol)
end

def show_cursor(show)
  if show
    $displaycontrol |= LCD_CURSORON
  else
    $displaycontrol &= ~LCD_CURSORON
  end
  write8bit(LCD_DISPLAYCONTROL | $displaycontrol)
end

def blink(blink)
  if blink
    $displaycontrol |= LCD_BLINKON
  else
    $displaycontrol &= ~LCD_BLINKON
  end
  write8bit(LCD_DISPLAYCONTROL | $displaycontrol)
end

def move_left
  write8bit(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVELEFT)
end

def move_right
  write8bit(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVERIGHT)
end

def set_left_to_right
  $displaymode |= LCD_ENTRYLEFT
  write8bit(LCD_ENTRYMODESET | $displaymode)
end

def set_right_to_left
  $displaymode &= ~LCD_ENTRYLEFT
  write8bit(LCD_ENTRYMODESET | $displaymode)
end

def autoscroll(autoscroll)
  if autoscroll
    $displaymode |= LCD_ENTRYSHIFTINCREMENT
  else
    $displaymode &= ~LCD_ENTRYSHIFTINCREMENT
  end
  write8bit(LCD_ENTRYMODESET | $displaymode)
end

def message(text)
  line = 0

  text.each_char do | character |
    if (character.ord == 10) # newline
      line += 1
      if (($displaymode & LCD_ENTRYLEFT) > 0)
        column = 0
      else
        column = COLUMNS - 1
      end
      set_cursor(column, line)
    else
      write8bit(character.ord, true)
    end
  end
end

def rgb_to_duty_cycle(rgb)
  red, green, blue = rgb

  red = [ 0.0, [ 1.0, red].min ].max
  green = [ 0.0, [ 1.0, green].min ].max
  blue = [ 0.0, [ 1.0, blue].min ].max

  return[pwm_duty_cycle(red),
         pwm_duty_cycle(green),
         pwm_duty_cycle(blue)]
end

def pwm_duty_cycle(intensity)
  intensity = 100.0 * intensity
  # PWM is inverted, so let's invert
  # intensity = 100.0 - intensity
end

def set_color(red, green, blue)
  red_duty_cycle, green_duty_cycle, blue_duty_cycle = rgb_to_duty_cycle([red, green, blue])
  # puts "red: #{red_duty_cycle}, green: #{green_duty_cycle}, blue: #{blue_duty_cycle}"
  PWM.set_duty_cycle(LCD_RED, red_duty_cycle)
  PWM.set_duty_cycle(LCD_GREEN, green_duty_cycle)
  PWM.set_duty_cycle(LCD_BLUE, blue_duty_cycle)
end

def hsv_to_rgb(hsv)
  h, s, v = hsv
  if (0 == s)
    return [v, v, v]
  end

  h /= 60.0
  i = h.floor
  f = h - i
  p = v * (1.0 - s)
  q = v * (1.0 - (s * f))
  t = v * (1.0 - (s * (1.0 - f)))

  if (0 == i)
    return [v, t, p]
  elsif (1 == i)
    return [q, v, p]
  elsif (2 == i)
    return [p, v, t]
  elsif (3 == i)
    return [p, q, v]
  elsif (4 == i)
    return [t, p, v]
  else
    return [v, p, q]
  end
end

# Run through a bunch of colors and show off!!!!

init

set_color(1.0, 0.0, 0.0)
clear()
message("RED")
sleep(3)

set_color(0.0, 1.0, 0.0)
clear()
message("GREEN")
sleep(3)

set_color(0.0, 0.0, 1.0)
clear()
message("BLUE")
sleep(3)

set_color(1.0, 1.0, 0.0)
clear()
message("YELLOW")
sleep(3)

set_color(0.0, 1.0, 1.0)
clear()
message("CYAN")
sleep(3)

set_color(1.0, 0.0, 1.0)
clear()
message("MAGENTA")
sleep(3)

set_color(1.0, 1.0, 1.0)
clear()
message("WHITE")
sleep(3)

hue = 0.0
saturation = 1.0
value = 1.0

# Loop through all the RGB colors

clear()
puts "Hit Ctrl-C to quit"
loop do
  red, green, blue = hsv_to_rgb([hue, saturation, value])
  set_color(red, green, blue)
  set_cursor(0, 0)
  string = sprintf("RED   GREEN  BLUE\n%.2f  %.2f   %.2f", red, green, blue)
  message(string)
  hue += 1
  if ( hue > 359.0)
    hue = 0.0
  end
end


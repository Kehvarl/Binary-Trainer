require 'app/switch.rb'
require 'app/7segment_display.rb'

class Switch_Display
  attr_accessor :value, :show_target
  def initialize vars={}
    @x = vars.x || 640
    @y = vars.y || 360
    @w = 256
    @h = 264
    @mode = vars.mode || :Decimal
    setup_display
    @inactive_color = vars.inactive || {r:64, g:64, b:64}
    @active_color = vars.active || {r:0, g:255, b:32}
    @value = vars.value || 0
    @show_target = vars.show_target || false
  end

  def setup_display
    case @mode
    when :Decimal
      setup_decimal
    when :Octal
      setup_octal
    when :Hexadecimal
      setup_hexadecimal
    when :BCD
      setup_bcd
    else
      puts "Error, #{@mode} is not recognized"
    end
  end

  def setup_decimal
    @display = SevenSegmentDisplay.new({x:@x+@w/4, y:@y+168, w:@w/2, h:96, digits:2})
    @switches = create_switchline(4)
    @leds = create_leds (4)
  end

  def setup_octal
    @display = SevenSegmentDisplay.new({x:@x+@w/4, y:@y+168, w:@w/2, h:96, digits:1})
    @switches = create_switchline(3)
    @leds = create_leds (3)
  end

  def setup_hexadecimal
    @display = SevenSegmentDisplay.new({x:@x+@w/4, y:@y+168, w:@w/2, h:96, digits:1})
    @switches = create_switchline(4)
    @leds = create_leds (4)
  end

  def setup_bcd
    @display = SevenSegmentDisplay.new({x:@x+@w/4, y:@y+168, w:@w/2, h:96, digits:1})
    @switches = create_switchline(4)
    @leds = create_leds (4)
  end

  def check_range value
    case @mode
    when :Decimal
      return (15 >= value and value >= 0)
    when :Octal
      return (7 >= value and value >= 0)
    when :Hexadecimal
      return (15 >= value and value >= 0)
    when :BCD
      return (9 >= value and value >= 0)
    end
  end

  def create_switchline count
    line = []
    (0...count).each do |x|
      line << Toggle_Switch.new({x:x*64 + @x,y:@y, w:60, h:96})
    end
    line
  end

  def create_leds count, spacing=5, color={r:64, g:64, b:64}
    leds = []
    count.times do |t|
      leds << make_led(t, color)
    end
    leds
  end

  def make_led index, color
    total_gaps = (4 - 1) * 3
    spacing = @w - total_gaps
    segment_w = spacing.to_f / 4
    x = index * (segment_w + 3) + (segment_w - 64) / 2.0
    {x:x+@x+16, y:@y+116, w:32, h:32, path: "sprites/led_gs.png", **color}.sprite!
  end

  def tick args
    @switches.each {|s| s.tick(args)}
    if not @show_target
      cur_value = 0
      @switches.each_with_index do |s,i|
        cur_value ^= (s.status << ((@switches.size()-1)-i))
        if s.status == 1
          @leds[i] = @leds[i].merge(@active_color)
        else
          @leds[i] = @leds[i].merge(@inactive_color)
        end
      end
      if check_range(cur_value)
        @value = cur_value
      else
        puts "#{cur_value} is out of range for mode #{@mode}"
      end
    else
      @leds.each_with_index do |l,i|
        if (@value >> (@leds.length - 1 - i)) & 1 == 1
          @leds[i] = @leds[i].merge(@active_color)
        else
          @leds[i] = @leds[i].merge(@inactive_color)
        end
      end
    end
    @display.set_value("%01d"%@value)
  end

  def render
    out = []
    out << @display.render
    out << @switches
    out << @leds
    out
  end
end

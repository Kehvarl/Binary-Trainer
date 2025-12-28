require 'app/switch.rb'
require 'app/display.rb'
require 'app/timer.rb'
require 'app/7segment_display.rb'

class Switch_Display
  def initialize vars={}
    @x = vars.x || 640
    @y = vars.y || 360
    @w = 256
    @h = 264
    @display = SevenSegmentDisplay.new({x:@x+@w/4, y:@y+168, w:@w/2, h:96, digits:2})
    @switches = create_switchline(4)
    @leds = create_leds (4)

  end

  def create_switchline count
    line = []
    (0...count).each do |x|
      line << Toggle_Switch.new({x:x*64 + @x,y:@y, w:60, h:96})
    end
    line
  end

  def create_leds count, spacing=5, color={r:128, g:128, b:128}
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
    value = 0
    @switches.each {|s| s.tick(args)}
    @switches.each_with_index do |s,i|
      value ^= (s.status << (3-i))
      if s.status == 1
        @leds[i].r = 255
        @leds[i].g = 255
        @leds[i].b = 0
      else
        @leds[i].r = 128
        @leds[i].g = 128
        @leds[i].b = 128
      end
    end
    @display.set_value("%02d"%value)
  end

  def render
    out = []
    out << @display.render
    out << @switches
    out << @leds
    out
  end
end

def init args
  args.state.test1 = Switch_Display.new({x:128})
  args.state.test2 = Switch_Display.new({x:512})
end

def set_switches(args, count)
    args.state.switches = switchline(count)
    args.state.target = generate_target(count)
end

def generate_target (switch_count)
  rand(2**switch_count)
end

def tick args
  if Kernel.tick_count <= 0
      init args
  end
  args.state.test1.tick(args)
  args.state.test2.tick(args)

  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:0, b:0}.solid!

  args.outputs.primitives << args.state.test1.render
  args.outputs.primitives << args.state.test2.render

end

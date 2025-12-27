require 'app/switch.rb'
require 'app/display.rb'
require 'app/timer.rb'
require 'app/7segment_display.rb'

class Switch_Display
  def initialize vars={}
    @x = vars.x || 640
    @y = vars.y || 360
    @w = 256
    @h = 192
    @display = SevenSegmentDisplay.new({x:@x, y:@y+96, w:@w, h:96})
    @switches = create_switchline(4)
    @leds = create_leds (4)

  end

  def create_switchline count
    line = []
    start = (640 - (count * 48)).div(2)
    (0...count).each do |x|
      line << Toggle_Switch.new({x:x*50 + start,y:@y+32, w:48, h:96})
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
    y = (@h - 64) / 2
    {x:x, y:y, w:64, h:64, path: "sprites/led_gs.png", **color}.sprite!
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
  args.state.test = Switch_Display.new()
end

def set_switches(args, count)
    args.state.switches = switchline(count)
    args.state.target = generate_target(count)
end

def generate_target (switch_count)
  rand(2**switch_count)
end

def switchline count
  line = []
  start = (720 - (count * 48)).div(2)
  (0...count).each do |x|
    line << Toggle_Switch.new({x:x*50 + start,y:640, w:48, h:96})
  end
  line
end

def calculate args
  output = 0
  states = [0,0,0]

  args.state.switches.each_with_index do |s,i|
    expected = (args.state.target >> (args.state.switches.length - 1 - i)) & 1
    if s.status == expected
      states[0] += 1
    else
      states[2] += 1
    end
    if i > 0
      output <<= 1
    end
    output |= s.status
  end
  if args.inputs.keyboard.key_up.enter or args.state.button.status
    args.state.display.add_line(states)
    args.state.button.status = false
    if output == args.state.target
      args.state.timer.color_override = {r:0, g:255, b:255}
      set_switches(args, args.state.switches.size + 1)
    end
  end
  return output
end


def tick args
  if Kernel.tick_count <= 0
      init args
  end

  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:0, b:0}.solid!

  args.outputs.primitives << args.state.test.render
end

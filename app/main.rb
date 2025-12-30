require 'app/switch.rb'
require 'app/display.rb'
require 'app/timer.rb'
require 'app/7segment_display.rb'


def init args
  args.state.d1 = Switch_Display.new({x:128, show_target:true, value:13})
  args.state.d2 = Switch_Display.new({x:512})
end

def generate_target (switch_count)
  rand(2**switch_count)
end

def tick args
  if Kernel.tick_count <= 0
      init args
  end
  args.state.d1.tick(args)
  args.state.d2.tick(args)

  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:0, b:0}.solid!

  args.outputs.primitives << args.state.d1.render
  args.outputs.primitives << args.state.d2.render

end

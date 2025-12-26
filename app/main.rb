require 'app/switch.rb'
require 'app/display.rb'
require 'app/timer.rb'
require 'app/7segment_display.rb'

def init args
  args.state.game_over = false
  args.state.won = false
  args.state.button = Pushbutton.new({x:500, y:640, w:96, h:96, source_w:64, source_h:32})
  args.state.display = Display.new()
  args.state.timer = Timer.new({x:160, y:800, w:384, h:144, time:20.0})
  set_switches(args, 1)
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

def game_over_tick args
    args.outputs.primitives << {x:0, y:0, w:720, h:1280, r:0, g:0, b:0}.solid!
    args.outputs.primitives << {x:280, y:800, w:50, h:50, r:0, g:196, b:0, size_enum: 30, text:"GAME"}.label!
    args.outputs.primitives << {x:280, y:700, w:50, h:50, r:0, g:196, b:0, size_enum: 30, text:"OVER"}.label!
    if not args.state.won
      args.outputs.primitives << {x:255, y:600, w:50, h:50, r:255, g:196, b:0, size_enum: 16, text:"You Lose!"}.label!
    else
      args.outputs.primitives << {x:255, y:600, w:50, h:50, r:255, g:196, b:0, size_enum: 16, text:"You Won!"}.label!
    end
    args.outputs.primitives << {x:230, y:300, w:260, h:80, r:0, g:196, b:0}.solid!
    args.outputs.primitives << {x:260, y:370, w:80, h:80, r:0, g:0, b:0, size_enum: 20, text:"RESTART"}.label!

    if args.inputs.mouse.button_left and args.inputs.mouse.inside_rect?({x:320, y:300, w:80, h:80})
      init args
    end
end

def tick args
  if Kernel.tick_count <= 0
      init args
  end
  if args.state.game_over
    game_over_tick(args)
    return
  end

  args.state.switches.each {|s| s.tick(args)}
  args.state.button.tick(args)
  args.state.timer.tick(args)

  if args.state.timer.ended
        args.state.game_over = true
  end

  if args.state.button.status > 0
      calculate(args)
      args.state.button.status = 0
  end

  args.outputs.primitives << {x:0, y:0, w:720, h:1280, r:0, g:0, b:0}.solid!
  args.outputs.primitives << {x:260, y:1280, w:720, h:280,size_enum:36, text:"Stop",r:255, g:196, b:0}.label
  args.outputs.primitives << {x:290, y:1200, w:720, h:280,size_enum:36, text:"The",r:255, g:196, b:0}.label
  args.outputs.primitives << {x:250, y:1120, w:720, h:280,size_enum:36, text:"Timer",r:255, g:196, b:0}.label
  args.outputs.primitives << args.state.switches

  args.outputs.primitives << args.state.timer.render
  args.outputs.primitives << args.state.display.render
  args.outputs.primitives << args.state.button
end

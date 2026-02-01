require 'app/switch_display.rb'
require 'app/keypad.rb'

def init args
  args.state.binary = setup_displays(2)
  args.state.dec = KeyPadDisplay.new({x:512})
  args.state.game_mode = :menu
end

def menu_tick args
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:0, b:0}.solid!
  args.outputs.primitives << {x:280, y:600, text:"Binary Trainer", size_enum:52, r:128, g:128, b:128}.label!
  args.outputs.primitives << {x:440, y:400, text:"Convert To Binary", size_enum:24, r:128, g:128, b:128}.label!
  args.outputs.primitives << {x:440, y:300, text:"Convert To Decimal", size_enum:24, r:128, g:128, b:128}.label!

  if args.mouse.click or args.keyboard.key_up.space
    if args.mouse.intersect_rect?({x:460, y:300, w:480, h:90})
      args.state.game_mode = :bin
    elsif args.mouse.intersect_rect?({x:460, y:200, w:480, h:90})
      args.state.game_mode = :dec
    end
  end
end

def setup_displays display_count
  displays = []
  max_width = 1280
  screen_center = 640
  display_width = 256
  start_x = screen_center - ((display_width * display_count)/2)
  display_count.each do |c|
    displays << Switch_Display.new({x: (start_x + (c * display_width)), mode: :Octal})
  end
  displays
end

def generate_target (switch_count)
  rand(2**switch_count)
end

def tick args
  if Kernel.tick_count <= 0
      init args
  end
  if args.state.game_mode == :menu
    menu_tick args
  elsif args.state.game_mode == :bin
    binary_tick args
  elsif args.state.game_mode == :dec
    decimal_tick args
  end
end

def decimal_tick args
  args.state.dec.tick(args)
  args.outputs.primitives << args.state.dec.render()
  if args.state.dec.status
    # puts args.state.test.status
  end
end

def binary_tick args
  args.state.binary.each{|d| d.tick(args)}

  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:0, b:0}.solid!

  args.state.binary.each do |d|
    args.outputs.primitives << d.render
  end
end

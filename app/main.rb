require 'app/switch_display.rb'
require 'app/keypad.rb'

def init args
  args.state.displays = setup_displays(2)
  args.state.test = KeyPadDisplay.new({x:512})
  args.state.game_mode = :menu
end

def menu_tick args
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:0, b:0}.solid!
  args.outputs.primitives << {x:280, y:600, text:"Binary Trainer", size_enum:52, r:128, g:128, b:128}.label!

  if args.mouse.click or args.keyboard.key_up.space
    args.state.game_mode = :game
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
  else
    game_tick args
  end
end

def game_tick args
  args.state.displays.each{|d| d.tick(args)}

  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:0, g:0, b:0}.solid!

  args.state.displays.each do |d|
    args.outputs.primitives << d.render
  end
  args.state.test.tick(args)
  args.outputs.primitives << args.state.test.render()
  if args.state.test.status
    # puts args.state.test.status
  end
end

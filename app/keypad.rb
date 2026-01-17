require 'app/7segment_display.rb'

class Key
    attr_sprite
    attr_accessor :value, :animating
    def initialize vars={}
        @x = vars.x || 0
        @y = vars.y || 0
        @w = vars.w || 64
        @h = vars.h || 64
        @path = 'sprites/7s-64x96_digits_sheet.png'
        @source_x = vars.source_x || 0
        @source_y = vars.source_y || 0
        @source_w = 64
        @source_h = 96
        @r = 64
        @g = 64
        @b = 64
        @value = vars.value || 0
        @animating = false
        @frame_delay = 5
        @next_frame = 0
        @frame = 0
        @frame_count = 1
    end

    def start_animation
        @animating = true
        @g = 255
        @next_frame = @frame_delay
        @frame = 0
    end

    def animate
        if @next_frame > 0
            @next_frame -= 1
        else
            @next_frame = @frame_delay
            @frame +=1
        end
        if @frame >= @frame_count
            @animating = false
            @frame = 0
            @g = 64
        end
    end

    def tick args
        if @animating
            animate
        end
        if self.intersect_rect?(args.mouse)
            @g = 255
        else
            @g = 64
        end
    end
end

class KeyPad
    attr_accessor :status
    def initialize vars={}
        @x = vars.x || 0
        @y = vars.y || 0
        @w = vars.w || 256
        @h = vars.h || 320
        @keys = ['0', '1', '2', '3',
                '4', '5', '6', '7',
                '8', '9', 'A', 'B',
                'C', 'D', 'E', 'F',
                :DEL, :OK, :CLR]
        @cols = 4
        setup_keypad
        @status = nil
    end

    def setup_keypad
        @buttons = []
        @keys.each_with_index do |b, i|
            # Need to add numbers somehow.
            @buttons << Key.new({x:(i%@cols)*64+@x, y:i.div(@cols)*64+@y, source_x:(i*64), value:b})
        end
    end

    def tick args
        @status = nil
        if args.mouse.click
            #Find all collision [buttons]+mouse

            clicked_buttons = args.geometry.find_all_intersect_rect(args.mouse, @buttons)
            if clicked_buttons.size > 0
                @status = clicked_buttons[0].value
                clicked_buttons[0].animating = true
            end
        end
        @buttons.each{|b| b.tick args}

    end

    def render
        @buttons
    end
end

class KeyPadDisplay
    def initialize vars={}
        @x = vars.x || 0
        @y = vars.y || 0
        @w = vars.w || 288
        @h = vars.h || 384
        @background = {x:@x, y:@y, w:@w, h:@h, r:96, g:96, b:96}.solid!
        @display = SevenSegmentDisplay.new({x:@x+16, y:@y+272, w:@w-32, h:96, digits:4})
        @keypad = KeyPad.new({x:@x+16, y:@y+16, w:@w-32, h:@h-128})
    end

    def status
        @keypad.status
    end

    def tick args
        @keypad.tick args
        @display.tick args
    end

    def render
        [@background, @display.render, @keypad.render]
    end
end

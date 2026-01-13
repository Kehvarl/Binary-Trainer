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
        end
    end

    def tick args
        if @animating
            animate
        end
    end
end

class KeyPad
    attr_accessor :status
    def initialize vars={}
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
            @buttons << Key.new({x:(i%@cols)*64, y:i.div(@cols)*64, source_x:(i*64)})
        end
    end

    def tick args
        if args.mouse.clicked
            #Find all collision [buttons]+mouse

            clicked_buttons = args.geometry.find_all_intersect_rect(mouse, @buttons)
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

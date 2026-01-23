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

    def render
        self
    end
end

class LabelKey
    attr_accessor :x, :y, :w, :h, :r, :g, :b, :a, :text, :font, :anchor_x,
            :anchor_y, :blendmode_enum, :size_px, :size_enum, :alignment_enum,
            :vertical_alignment_enum, :value, :animating

    def initialize vars={}
        @x = vars.x || 0
        @y = vars.y || 0
        @w = vars.w || 64
        @h = vars.h || 64
        @size_enum = 12
        @r = 64
        @g = 64
        @b = 64
        @value = vars.value || 0
        @text = vars.value.to_s || ""
        @animating = false
    end

    def tick args
        if args.geometry.intersect_rect?(self, args.mouse)
            @g = 255
        else
            @g = 64
        end
    end

    def render
        out = []
        out << {x:@x, y:@y, w:@w, h:@h, r:@r, g:@g, b:@b}.border!
        out << {x:@x, y:@y+48, r:@r, g:@g, b:@b, size_enum:@size_enum, text:@text}.label!
        out
    end
end

class KeyPad
    attr_accessor :status
    LAYOUT_ORD = ['0', '1', '2', '3',
                  '4', '5', '6', '7',
                  '8', '9', 'A', 'B',
                  'C', 'D', 'E', 'F',
                  :DEL, :OK, :CLR]
    LAYOUT_HEX = [:DEL, '0', :OK, ' ',
                  '1', '2', '3', :CLR,
                  '4', '5', '6', 'F',
                  '7', '8', '9', 'E',
                  'A', 'B', 'C', 'D']
    LAYOUT_DEC = ['7', '8', '9', :CLR,
                  '4', '5', '6', :DEL,
                  '1', '2', '3', ' ',
                  ' ', '0', ' ', :OK,
                  ' ', ' ', ' ', ' ']
    def initialize vars={}
        @x = vars.x || 0
        @y = vars.y || 0
        @w = vars.w || 256
        @h = vars.h || 320
        @layout = vars.layout || LAYOUT_HEX
        @cols = 4
        setup_keypad
        @status = nil
    end

    def setup_keypad
        @buttons = []
        @layout.each_with_index do |b, i|
            if b == '' or b == ' ' or b == nil
                next
            end
            # Need to add numbers somehow.
            if false #['0', '1', '2', '3','4', '5', '6', '7','8', '9'].include?(b)
                @buttons << Key.new({x:(i%@cols)*64+@x, y:i.div(@cols)*64+@y, source_x:(i*64), value:b})
            else
                @buttons << LabelKey.new({x:(i%@cols)*64+@x, y:i.div(@cols)*64+@y, value:b})
            end
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
        out = []
        @buttons.each do |b|
            out << b.render
        end
        out
    end
end

class KeyPadDisplay
    def initialize vars={}
        @x = vars.x || 0
        @y = vars.y || 0
        @w = vars.w || 288
        @h = vars.h || 448
        @background = {x:@x, y:@y, w:@w, h:@h, r:96, g:96, b:96}.solid!
        @display = SevenSegmentDisplay.new({x:@x+16, y:@y+334, w:@w-32, h:96, digits:4})
        @keypad = KeyPad.new({x:@x+16, y:@y+16, w:@w-32, h:@h-128})
        @value = "0000"
    end

    def status
        {value:@value, key:@keypad.status}
    end

    def is_numeric value
        begin
            value = Integer(value)
            return true
        rescue
            return false
        end
    end

    def tick args
        @keypad.tick args
        case @keypad.status
        when :CLR
            @value = "0000"
        when :DEL
            @value = "0" + @value[0...-1]
        when '1','2','3','4','5','6','7','8','9','0'
            @value = @value[1,3] + @keypad.status
        else
            # nil value
        end
        @display.set_value(@value)
        @display.tick args
    end

    def render
        [@background, @display.render, @keypad.render]
    end
end

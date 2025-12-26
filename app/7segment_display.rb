class SevenSegmentDigit
    attr_sprite
    def initialize args={}
        @x = args.x || 0
        @y = args.y || 0
        @w = args.w || 64
        @h = args.h || 96
        @path = args.path   || "sprites/7s-64x96_digits_sheet.png"
        @source_x = 0
        @source_y = 0
        @source_w = 64
        @source_h = 96
        set_color(args.r || 255, args.g || 255, args.b || 255)
        @value = 0
        set_value(args.val || 0)
    end

    def set_color r, g, b
        @r = r
        @g = g
        @b = b
    end

    def set_value value
        @value = value % 10
        @source_x = @value * @source_w
    end

    def increment
        set_value @value + 1
    end
end

class SevenSegnment
    def initialize args={}
        @x = args.x || 0
        @y = args.y || 0
        @w = args.w || 64
        @h = args.h || 96
        @bgpath = args.bgpath || "sprites/7s-64x96_background.png"
        @digit = SevenSegmentDigit.new(args)
    end

    def set_value value
        @digit.set_value value
    end

    def increment
        @digit.increment
    end

    def set_color r, g, b
        @digit.set_color r, g, b
    end

    def render
        out = []
        out << {x:@x, y:@y, w:@w, h:@h, a:128, path:@bgpath}.sprite!
        out << @digit
        out
    end
end

class SevenSegmentDisplay
    def initialize args={}
        @x = args.x || 0
        @y = args.y || 0
        @w = args.w || 256
        @h = args.h || 96
        @count = args.digits || 4
        @digits = []
        setup_digits args
    end

    def setup_digits args
        tmp = args.copy()
        dw = @w / @count
        @count.each do |c|
            tmp.x =  @x + (dw*c)
            tmp.w = dw
            tmp.val = 0
            @digits << SevenSegnment.new(tmp)
        end
    end

    def set_value value
        value.delete('.').chars.map(&:to_i).each_with_index do |d, i|
            @digits[i].set_value(d)
        end
    end

    def set_digit digit, value
    end

    def set_color r, g, b
        @digits.each{|d| d.set_color(r, g, b)}
    end

    def render
        out = []
        @digits.each do |d|
            out << d.render
        end
        out
    end
end



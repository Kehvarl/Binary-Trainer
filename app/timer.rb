class Timer
    attr_accessor :ended, :color_override
    def initialize args={}
        @x = args.x || 0
        @y = args.y || 0
        @w = args.w || 480
        @h = args.h || 64
        @color_override = false
        @time_remaining = args.time || 20.0
        @count_to = Time.now + @time_remaining
        @ended = false
        @display = SevenSegmentDisplay.new({x:@x, y:@y, w:@w, h:@h, digits:4})
    end

    def tick args
        @time_remaining = @count_to - Time.now
        if @time_remaining <= 0.00
            @time_remaining = 0.00
            @ended = true
        end
        @display.set_value("#{"%05.2f" % @time_remaining}")
        c = timer_color()
        @display.set_color(c.r, c.g, c.b)
    end

    def timer_color
        if @color_override
            return @color_override
        end
        color = {r:0, g:255, b:0}
        case @time_remaining
        when 5.0 .. 10.0
            color = {r:255, g:223, b:0}
        when 0.0 .. 5.0
            color = {r:255, g:64, b:64}
        end
        color
    end

    def render
        out = []
        #out << {x:@x-64, y:@y-@h, w:@w, h:@h, path:"sprites/7s-64x96_background.png"}.sprite!
        #out << {x:@x, y:@y-@h, w:@w, h:@h, path:"sprites/7s-64x96_background.png"}.sprite!
        #out << {x:@x+64, y:@y-@h, w:@w, h:@h, path:"sprites/7s-64x96_background.png"}.sprite!
        #out << {x:@x+128, y:@y-@h, w:@w, h:@h, path:"sprites/7s-64x96_background.png"}.sprite!

        #out << {x:@x, y:@y, w:@w, h:@h, **timer_color(), size_enum: 20, text:"#{"%.2f" % @time_remaining}"}.label!
        out << @display.render
        out
    end
end

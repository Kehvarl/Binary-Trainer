class Display_Line
  attr_accessor :x, :y, :w, :h, :led_w, :led_h, :segments
  def initialize args={}
    @x = args.x || 0
    @y = args.y || 0
    @w = args.w || 720
    @h = args.h || 64
    @led_w = args.led_w || 32
    @led_h = args.led_h || 32
    @led_spacing = args.led_spacing || 8
    @segments = args.segments || 5
    @output = []
    @segments.times do |t|
      @output << make_segment(t, {r:128, g:128, b:128})
    end
  end

  def make_segment index, color
    total_gaps = (@segments - 1) * @led_spacing
    spacing = @w - total_gaps
    segment_w = spacing.to_f / @segments
    x = index * (segment_w + @led_spacing) + (segment_w - @led_w) / 2.0
    y = (@h - @led_h) / 2
    {x:x, y:y, w:@led_w, h:@led_h, path: "sprites/led_gs.png", **color}.sprite!
  end

  def store_state (correct, incorrect, invalid)
    @output = []
    correct.times {|t| @output << make_segment(t, {r:0, g:255, b:0})}
    incorrect.times {|t| @output << make_segment(t + correct, {r:255, g:255, b:0})}
    invalid.times {|t| @output << make_segment(t + correct + incorrect, {r:128, g:128, b:128})}
  end

  def render x, y
    out = []
    @output.each do |s|
      c = s.copy
      c.x += x
      c.y += y
      out << c
    end
    out
  end
end

class Display
    def initialize
        @x = 110
        @y = 100
        @w = 500
        @h = 480
        @row_height = 64
        @max_rows = (@h / @row_height).floor
        @lines = []

        @max_rows.times do
          line = Display_Line.new({ x:@x-16, y:0, w:@w, h:20})
          line.store_state(0, 0, line.segments)
          @lines << line
        end
    end

    def add_line state
        line = Display_Line.new({x:@x-16, y:0, w:@w, h:20})
        line.store_state(state[0], state[1], state[2])
        @lines.unshift(line)
    end

    def render
        out = []
        out << {x:@x, y:@y, w:@w, h:@h, r:96, g:96, b:96}.solid!
        out << {x:@x, y:@y, w:@w, h:@h, r:128, g:128, b:128}.border!

        visible = @lines.first(@max_rows)
        visible.each_with_index do |line, i|
          line_y = @y + @h - ((i + 1) * @row_height)
          out << line.render(@x, line_y)
        end

        out
    end
end

class Key
    attr_sprite
    attr_accessor :value, :animating
    def initialize vars={}
        @x = vars.x || 0
        @y = vars.y || 0
        @w = vars.w || 64
        @h = vars.h || 64
        @path = 'sprites/button_gs.png'
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
        col = 0
        @keys.each do |b|
            button = []
            button << b
            @buttons << button
        end
    end

    def tick args
        #Find all collision [buttons]+mouse
        #If clicked and Collision
        # Animate button
        # Get Button value
        # Set clicked state
    end

    def render
    end
end

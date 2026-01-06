class Key
    attr_sprite
    def initialize vars={}
    end

    def tick args
    end
end

class KeyPad
    def initialize vars={}
        setup_keypad
    end

    def setup_keypad
        @buttons = []
        16.each do |b|
            button = []
            button << b
            @buttond << button
        end
    end

    def tick args
    end

    def render
    end
end

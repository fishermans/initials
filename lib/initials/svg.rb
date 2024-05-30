module Initials
  class SVG
    HUE_WHEEL = 360

    attr_reader :name, :colors, :limit, :shape, :size, :text_opacity

    def initialize(name, colors: 12, limit: 3, shape: :circle, size: 32, text_opacity: 0.75)
      @name = name.to_s.strip
      @colors = colors
      @limit = limit
      @shape = shape
      @size = size
      @text_opacity = text_opacity

      raise Initials::Error.new("Colors must be a divider of 360 e.g. 24 but not 16.") unless valid_colors?
      raise Initials::Error.new("Size is not a positive integer.") unless valid_size?
      raise Initials::Error.new("Text opacity should be the value of 0 to 1") unless valid_text_opacity?
    end

    def name
      @name.empty? ? "?" : @name
    end

    def to_s
      svg = [
        "<svg xmlns='http://www.w3.org/2000/svg' width='#{size}' height='#{size}'>",
          shape == :rect ?
            "<rect width='#{size}' height='#{size}' rx='#{size / 32}' ry='#{size / 32}' fill='#{fill}' />"
          :
            "<circle cx='#{size / 2}' cy='#{size / 2}' r='#{size / 2}' fill='#{fill}' />",
          "<text x='50%' y='50%' fill='white' fill-opacity='#{text_opacity}' dominant-baseline='central' text-anchor='middle' style='font-size: #{font_size}px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Oxygen-Sans, Ubuntu, Cantarell, \"Helvetica Neue\", sans-serif; user-select: none;'>",
            "#{initials}",
          "</text>",
        "</svg>"
      ].join

      svg.html_safe rescue svg
    end

    def fill
      return "hsl(0, 0%, 67%)" if @name.empty?

      hue_step = HUE_WHEEL / colors
      char_sum = name.split("").sum do |c|
        # Multiplication makes sure neighboring characters (like A and B) are one hue step apart.
        c.ord * hue_step
      end

      # Spin the wheel!
      hue = char_sum % HUE_WHEEL

      "hsl(#{hue}, 40%, 40%)"
    end

    def font_size
      size/2 + size/16 - (initials.length * size/16)
    end

    def initials
      name.split(' ')[0, limit].map { |s| s[0].capitalize }.join
    end

    private

    def valid_colors?
      return false unless colors.respond_to?(:to_i)
      return false unless colors > 0
      HUE_WHEEL % colors == 0
    end

    def valid_size?
      return false unless size.respond_to?(:to_i)
      size.to_i > 0
    end

    def valid_text_opacity?
      return false unless text_opacity.respond_to?(:to_f)

      puts text_opacity
      (0..1).include? text_opacity.to_f
    end
  end
end

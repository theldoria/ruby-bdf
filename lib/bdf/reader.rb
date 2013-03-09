# -*- coding: utf-8 -*-
module Bdf
  module BitmapArrayToS
    def to_s
      result = String.new
      each do |a|
        a.each do |b|
          if b
            if b.is_a? String
              result << b
            else
              result << "█"
            end
          else
            result << "░"
          end
        end
        result << "\n"
      end
      result
    end
  end

  module RenderFont
    def render_font! fbbx, origin_delta, overwrite = false
      fbbx.each_with_index do |row, y|
        r = self[y + origin_delta[:y]]
        if r
          row.each_with_index do |column, x|
            if x + origin_delta[:x] < r.length
              r[x + origin_delta[:x]] = column unless not overwrite and r[x + origin_delta[:x]]
            else
              # Clipping in x direction!
            end
          end
        else
          # Clipping in y direction!
        end
      end
      self
    end
  end

  class Reader
    attr_reader :font
    attr_reader :size
    attr_reader :bounding_box
    attr_reader :properties
    attr_reader :chars

    def initialize file
      @file = file
      @properties = {}
      @chars = {}
    end

    def get_origin char = nil
      if char
        char = @chars[char]
        {
          x: 0 - char[:bounding_box][:displacement][:x],
          y: (char[:bounding_box][:y] - 1)  + char[:bounding_box][:displacement][:y]
        }
      else
        {
          x: 0 - self.bounding_box[:displacement][:x],
          y: (self.bounding_box[:y] - 1)  + self.bounding_box[:displacement][:y]
        }
      end
    end

    def get_origin_delta char
      origin = get_origin
      origin_char = get_origin(char)
      {
        x: origin[:x] - origin_char[:x],
        y: origin[:y] - origin_char[:y]
      }
    end

    def create_bounding_box_array x, y
      bbx = Array.new(y)
      bbx.extend(BitmapArrayToS)
      bbx.extend(RenderFont)
      y.times do |y|
        bbx[y] = Array.new(x)
      end
      bbx
    end

    def create_font_bounding_box_array
      bbx = create_bounding_box_array(self.bounding_box[:x], self.bounding_box[:y])
#      origin = get_origin
#      bbx[origin[:y]][origin[:x]] = "O"
      bbx
    end

    def char_to_bbx char
      char = @chars[char]
      fbbx = Array.new(char[:bounding_box][:y])
      fbbx.extend(BitmapArrayToS)

      char[:bitmap].each_with_index do |line, y|
        fbbx[y] = Array.new(char[:bounding_box][:x])
      end

      mask = 1 <<
        (char[:bounding_box][:x] / 8 +
         (char[:bounding_box][:x] % 8 > 0 ?
          1 :
          0)) *
        8 - 1

      char[:bounding_box][:x].times do |x|
        char[:bitmap].each_with_index do |row, y|
          fbbx[y][x] = true if (row & mask) == mask
        end
        mask >>= 1
      end

#      begin
#        fbbx[origin[:y]][origin[:x]] = "o"
#      rescue
#      end
      fbbx
    end

    def char_to_s char, x = 0, y = 0
      result = String.new
      result << "#{char}\n"
      origin = get_origin(char)
      origin_delta = get_origin_delta(char)
      fbbx = char_to_bbx(char)
#      result << "Origin delta: #{origin_delta}\n"
      char = @chars[char]
#      result << "#{char}\n"

#      result << fbbx.to_s
#      result << "\n"

      result << create_font_bounding_box_array.render_font!(fbbx, origin_delta).to_s

      x += char[:device_width].first
      y += char[:device_width].last
      result << "x: #{x}, y: #{y}"
    end

    def print_char bbx, char, x, y
      fbbx = char_to_bbx(char)
      origin_delta = get_origin_delta(char)
      origin_delta[:x] += x
      origin_delta[:y] += y
      char = @chars[char]

      bbx.render_font!(fbbx, origin_delta).to_s

      x += char[:device_width].first
      y += char[:device_width].last

      [bbx, x, y]
    end

    def load
      return false unless File.exists?(@file)

      char = nil
      bitmap = nil
      properties_counter = nil
      File.open(@file, 'r').each_line do |line|
        if properties_counter
          properties_counter -= 1
          case line
          when /FONT_NAME\s"([a-z0-9_-]+)"/i
            @properties[:font_name] = $1

          when /FONT_ASCENT\s([0-9]+)/
            @properties[:font_ascent] = $1.to_i

          when /FONT_DESCENT\s([0-9]+)/
            @properties[:font_descent] = $1.to_i

          when /ENDPROPERTIES/
            raise "Malformed file"

          end
          properties_counter = nil if properties_counter == 0
        else
          if char
            if bitmap
              case line
              when /ENDCHAR/
                char = nil
                bitmap = nil

              else
                bitmap << line.to_i(16)
              end
            else
              case line
              when /ENCODING\s+([0-9.]+)/
                char[:encoding] = $1.to_i

              when /DWIDTH\s+([0-9.]+)\s+([0-9.]+)/
                char[:device_width] = [$1.to_i, $2.to_i]

              when /BBX\s+([0-9.]+)\s+([0-9.]+)\s+([0-9.-]+)\s+([0-9.-]+)/
                char[:bounding_box] = {
                  x: $1.to_i,
                  y: $2.to_i,
                  displacement: {
                    x: $3.to_i,
                    y: $4.to_i
                  }
                }

              when /BITMAP/
                bitmap = char[:bitmap] = []

              when /ENDCHAR/
                char = nil
              end
            end
          else
            case line
            when /STARTFONT\s+([0-9.]+)/
              raise "File format version #$1 not supported" unless '2.1' == $1

            when /FONT\s+([a-z0-9-]+)/i
              @font = $1

            when /SIZE\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)/
              @size = [$1.to_i, $2.to_i, $3.to_i]

            when /FONTBOUNDINGBOX\s+([0-9]+)\s+([0-9]+)\s+([0-9-]+)\s+([0-9-]+)/
              @bounding_box = {
                x: $1.to_i,
                y: $2.to_i,
                displacement: {
                  x: $3.to_i,
                  y: $4.to_i
                }
              }

            when /STARTPROPERTIES\s+([0-9]+)/
              properties_counter = $1.to_i

            when /ENDPROPERTIES/
              properties_counter = nil

            when /STARTCHAR\s+([a-z0-9 ]+)/i
              char = @chars[$1.to_sym] = {}
            end
          end
        end
      end

      return self
    end
  end
end


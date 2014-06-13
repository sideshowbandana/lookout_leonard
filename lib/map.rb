require_relative "phone"
require_relative "bug"

module Tiles
  Grass = 0
  Earth = 1
end

# Map class holds and draws tiles and phones.
class Map
  attr_reader :width, :height, :phones, :bugs

  def initialize(window, filename=nil)
    # Load 60x60 tiles, 5px overlap in all four directions.
    @tileset = Image.load_tiles(window, "media/tileset.png", 60, 60, true)

    gem_img = Image.new(window, "media/gg.png", false)
    @phones = []
    @bugs = []

    if filename
      lines = File.readlines(filename).map { |line| line.chomp }
    else
      lines = generate_board
    end

    @height = lines.size
    @width = lines[0].size
    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x, 1]
        when '"'
          Tiles::Grass
        when '#'
          Tiles::Earth
        when 'x'
          @phones.push(Phone.new(gem_img, x * 50 + 25, y * 50 + 25))
          nil
        when "0"
          @bugs.push(Bug.new(window, x * 50 + 25, y * 50 + 25))
          nil
        else
          nil
        end
      end
    end
  end

  def generate_board
    board = []
    24.times do
      board << "#"
      23.times do
        board.last << case rand(100)
                      when (0..10)
                        '"'
                      when (10..20)
                        '#'
                      else
                        '.'
                      end
      end
      board.last << "#"
    end
    board << "#"*25
    board
  end

  def draw
    # Very primitive drawing function:
    # Draws all the tiles, some off-screen, some on-screen.
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[x][y]
        if tile
          # Draw the tile with an offset (tile images have some overlap)
          # Scrolling is implemented here just as in the game objects.
          @tileset[tile].draw(x * 50 - 5, y * 50 - 5, 0)
        end
      end
    end
    @phones.each { |c| c.draw }
    @bugs.each{ |b|
      b.draw
    }
  end

  # Solid at a given pixel position?
  def solid?(x, y)
    y < 0 || @tiles[x / 50][y / 50]
  end
end

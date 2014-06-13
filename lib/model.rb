class Model
  attr_accessor :x, :y
  attr_reader :window
  def initialize(window, x, y)
    @x, @y = x, y
    @dir = :left
    @window = window
  end

  def map
    window.map
  end

  def draw
    # Flip vertically when facing to the left.
    if @dir == :left then
      offs_x = -25
      factor = 1.0
    else
      offs_x = 25
      factor = -1.0
    end
    @cur_image.draw(@x + offs_x, @y - 49, 0, factor, 1.0)
  end

  # Could the object be placed at x + offs_x/y + offs_y without being stuck?
  def would_fit(offs_x, offs_y)
    # Check at the center/top and center/bottom for map collisions
    not map.solid?(@x + offs_x, @y + offs_y) and
      not map.solid?(@x + offs_x, @y + offs_y - 45)
  end
end

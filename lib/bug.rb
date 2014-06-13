require_relative "model"

class Bug < Model
  def initialize(window, x, y)
    super
    # Load all animation frames
    @walk1, @walk2 =
      *Image.load_tiles(window, "media/virus.png", 43, 55, false)
    # This always points to the frame that is currently drawn.
    # This is set in update, and used in draw.
    @cur_image = @walk1
    @dir = :left
    @vy = 0
  end

  def update
    if map
      @cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
      # Directional walking, horizontal movement
      case @dir
      when :right
        if would_fit(1, 0)
          @x += 1
        else
          @dir = :left
        end
      when :left
        if would_fit(-1, 0)
          @x -= 1
        else
          @dir = :right
        end
      end

      # Acceleration/gravity
      # By adding 1 each frame, and (ideally) adding vy to y, the player's
      # jumping curve will be the parabole we want it to be.
      @vy += 1
      # Vertical movement
      if @vy > 0 then
        @vy.times { if would_fit(0, 1) then @y += 1 else @vy = 0 end }
      end
      if @vy < 0 then
        (-@vy).times { if would_fit(0, -1) then @y -= 1 else @vy = 0 end }
      end

    end
  end
end

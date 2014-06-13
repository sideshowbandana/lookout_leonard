require_relative "lookout_leonard/version"

# Basically, the tutorial game taken to a jump'n'run perspective.

# Shows how to
#  * implement jumping/gravity
#  * implement scrolling using Window#translate
#  * implement a simple tile-based map
#  * load levels from primitive text files

# Some exercises, starting at the real basics:
#  0) understand the existing code!
# As shown in the tutorial:
#  1) change it use Gosu's Z-ordering
#  2) add gamepad support
#  3) add a score as in the tutorial game
#  4) similarly, add sound effects for various events
# Exploring this game's code and Gosu:
#  5) make the player wider, so he doesn't fall off edges as easily
#  6) add background music (check if playing in Window#update to implement
#     looping)
#  7) implement parallax scrolling for the star background!
# Getting tricky:
#  8) optimize Map#draw so only tiles on screen are drawn (needs modulo, a pen
#     and paper to figure out)
#  9) add loading of next level when all phones are collected
# ...Enemies, a more sophisticated object system, weapons, title and credits
# screens...

require 'rubygems'
require 'gosu'
include Gosu

# Player class.
class Leonard < Model
  attr_accessor :score, :lives

  def initialize(window, x, y)
    super
    @vy = 0 # Vertical velocity
    # Load all animation frames
    @standing, @walk1, @walk2, @jump =
      *Image.load_tiles(window, "media/leonard.png", 50, 50, false)
    @dead = Image.new(window, "media/dead.png")
    @beep = Gosu::Sample.new(window, "media/Beep.wav")
    @bump = Gosu::Sample.new(window, "media/smb_bump.wav")
    @explosion = Gosu::Sample.new(window, "media/Explosion.wav")

    # This always points to the frame that is currently drawn.
    # This is set in update, and used in draw.
    @cur_image = @standing
    @score = 0
    @lives = 3
  end


  def update(move_x)
    # Select image depending on action
    if (move_x == 0)
      @cur_image = @standing unless @cur_image == @dead
    else
      @cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
    end
    if (@vy < 0)
      @cur_image = @jump
    end

    # Directional walking, horizontal movement
    if move_x > 0 then
      @dir = :right
      move_x.times { if would_fit(1, 0) then @x += 1 end }
    end
    if move_x < 0 then
      @dir = :left
      (-move_x).times { if would_fit(-1, 0) then @x -= 1 end }
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

  def try_to_jump(height = -20)
    if map.solid?(@x, @y + 1) then
      @vy = height
    end
  end

  def handle_collisions(objs)
    objs.reject! do |c|
      if (c.x - @x).abs < 50 and (c.y - @y).abs < 50
        yield
        true
      else
        false
      end
    end
  end

  def collect_phones(phones)
    handle_collisions(phones) do
      self.score += 10
      @beep.play
    end
    # Same as in the tutorial game.
  end

  def dodge_bugs(bugs)
    handle_collisions(bugs) do
      if @vy > 0
        self.score += 20
        @bump.play
      else
        self.lives -= 1
        @explosion.play
        @cur_image = @dead
      end
    end
  end
end


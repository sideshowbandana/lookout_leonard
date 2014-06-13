require "gosu"
require_relative "map"
require_relative "leonard"

include Gosu

class Game < Window
  attr_reader :map

  def initialize
    super(640, 480, false)
    self.caption = "Lookout Leonard!"
    @sky = Image.new(self, "media/Space.png", true)
    @level = 1
    @map = Map.new(self, "media/level1.txt")
    @song = Gosu::Song.new(self, "media/ff7.ogg")
    @game_over_songs = [
                        Gosu::Song.new(self, "media/smb_gameover.wav"),
                        Gosu::Song.new(self, "media/smb_stage_clear.wav")
                       ]
    @leonard = Leonard.new(self, 400, 100)
    # The scrolling position is stored as top left corner of the screen.
    @camera_x = @camera_y = 0

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def update
    if !game_over?
      @song.play unless @song.playing?
      check_level
      move_x = 0
      move_x -= 5 if button_down? KbLeft
      move_x += 5 if button_down? KbRight
      @leonard.dodge_bugs(@map.bugs)
      @leonard.update(move_x)
      @map.bugs.each{ |b| b.update }
      @leonard.collect_phones(@map.phones)
      # Scrolling follows player
      @camera_x = [[@leonard.x - 320, 0].max, @map.width * 50 - 640].min
      @camera_y = [[@leonard.y - 240, 0].max, @map.height * 50 - 480].min
    else
      unless @done
        @song.stop if @song.playing?
        @game_over_songs[@end_song_id].play
        @done = true
      end
    end
  end

  def check_level
    if @map.phones.empty?
      @level += 1
      f = "media/level#{@level}.txt"
      if !File.exist?(f)
        @game_over = "You WIN!!!"
        @end_song_id = 1
      else
        @map = Map.new(self, f)
        @leonard.x = 400
        @leonard.y = 100
      end
    end
  end

  def game_over?
    if @leonard.lives < 1
      @game_over = "Game Over"
      @end_song_id = 0
      true
    else
      @game_over
    end
  end

  def draw
    @sky.draw 0, 0, 0
    translate(-@camera_x, -@camera_y) do
      @map.draw
      @leonard.draw
    end
    @font.draw("Level: #{@level} Score: #{@leonard.score} Lives: #{@leonard.lives}", 10, 10, 3, 1.0, 1.0, 0xffffff00)
    @font.draw(@game_over, 300, 240, 4, 1.0, 1.0, 0xfffffffff) if game_over?
  end

  def button_down(id)
    if id == KbSpace then @leonard.try_to_jump end
    if id == KbEscape then close end
  end
end

Game.new.show

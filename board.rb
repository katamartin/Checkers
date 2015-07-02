require_relative 'piece'
require 'io/console'

class Board
  attr_reader :grid
  attr_accessor :cursor, :selected_positions
  def initialize(populate = true)
    @grid = Array.new(8) { Array.new(8) }
    @cursor = [0, 0]
    @selected_positions = []
    fill_grid(populate)
  end

  def [](pos)
    x, y  = pos
    grid[x][y]
  end

  def []=(pos, value)
    x, y = pos
    grid[x][y] = value
  end

  def fill_grid(populate)
    return unless populate
    grid.each_with_index do |row, i|
      row.each_with_index do |el, j|
        if i < 2 && (i + j).even?
          Piece.new(self, [i, j], :red)
        elsif i > 5 && (i + j).even?
          Piece.new(self, [i, j], :black)
        end
      end
    end
  end

  def on_board?(pos)
    return false unless pos.all? { |idx| idx.between?(0, 7) }
    # return false unless (pos[0] + pos[1]).even?

    true
  end

  def add_piece(piece, pos)
    self[pos] = piece
  end

  def render
    system("clear")
    grid.each_with_index do |row, i|
      print "#{i} "
      row.each_with_index do |el, j|
        if el == nil
          string = "   ".colorize(:background => background_color([i, j]))
        else
          string = " #{el} ".colorize(:background => background_color([i, j]))
        end
        print string
      end
      puts ""
    end

    nil
  end

  def background_color(pos)
    if pos == cursor
      return :yellow
    elsif selected_positions.include?(pos)
      return :green
    elsif (pos[0] + pos[1]).odd?
      return :black
    else
      :light_white
    end
  end

  def valid_pos?(pos)
    on_board?(pos) && (pos[0] + pos[1]).even?
  end

  def empty?(pos)
    raise "Not a valid piece position" unless valid_pos?(pos)

    self[pos].nil?
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end

    ensure
      STDIN.echo = true
      STDIN.cooked!

      return input
  end

  def move_cursor(delta)
    moved_cursor = add_arrs(cursor, delta)
    self.cursor = moved_cursor if on_board?(moved_cursor)
  end

  def select_position(pos)
    selected_positions << pos
    if selected_positions.length == 2
      piece = self[selected_positions.first]
      piece.perform_slide(selected_positions.last) unless piece.nil?
      self.selected_positions = []
      render
    elsif selected_positions.length > 2
      self.selected_positions = [pos]
      render
    end
  end

  def use_cursor
    c = read_char

    case c

    when "\r"
      select_position(cursor)
    when "\u0003"
      raise Interrupt
    when "\e[A"
      move_cursor([-1, 0])
    when "\e[B"
      move_cursor([1, 0])
    when "\e[C"
      move_cursor([0, 1])
    when "\e[D"
      move_cursor([0, -1])
    end
  end

  def add_arrs(arr1, arr2)
    raise "Can only add 2D vecs!" unless arr1.length == 2 and arr2.length == 2

    [arr1[0] + arr2[0], arr1[1] + arr2[1]]
  end

end

b = Board.new
while true
  b.render
  b.use_cursor
end

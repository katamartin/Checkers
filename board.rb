require_relative 'piece'
require_relative 'arrays'
require 'io/console'
require 'byebug'

class Board
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

    true
  end

  def add_piece(piece, pos)
    self[pos] = piece
  end

  def deep_dup
    duped = Board.new(false)
    grid.each_with_index do |row, i|
      row.each_with_index do |el, j|
        duped[[i, j]] = el.dup(duped) unless el.nil?
      end
    end

    duped
  end

  def render(message = "")
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
    puts message

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

  def pick_position(color, message = "")
    chosen = false
    until chosen
      render(message)
      c = read_char

      case c
      when "\r"
        chosen = true
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

    cursor
  end

  def get_move_sequence(color, message = "")
    complete = false
    until complete
      render
      next_position = pick_position(color, message)
      if next_position == selected_positions.last
        complete = true
      else
        selected_positions << next_position
      end
    end
    sequence = selected_positions
    self.selected_positions = []

    sequence
  end

  def pieces
    grid.flatten.select { |piece| !piece.nil? }
  end



  private
  include ArrayArithmetic
  attr_reader :grid
  attr_accessor :cursor, :selected_positions

end

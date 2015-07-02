require_relative 'piece'


class Board
  attr_reader :grid
  def initialize(populate = true)
    @grid = Array.new(8) { Array.new(8) }
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
    return false unless (pos[0] + pos[1]).even?

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
          string = "   "
        else
          string = " #{el} "
        end
        string = string.colorize(:background => :black) if (i + j).odd?
        print string
      end
      puts ""
    end

    nil
  end

end

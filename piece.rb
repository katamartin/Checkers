require 'colorize'

class Piece
  attr_accessor :pos
  attr_reader :board, :color, :kinged, :heading
  def initialize(board, pos, color)
    raise "Invalid position" unless board.valid_pos?(pos)
    raise "Invalid color" unless [:red, :black].include?(color)

    @board = board
    @pos = pos
    @color = color
    @heading = color == :red ? 1 : -1
    @kinged = false
    board.add_piece(self, pos)
  end

  def inspect
    "●".colorize(color)
  end

  def king?
    kinged
  end

  def to_s
    inspect
  end

  def perform_slide(end_pos)
    return false unless moves.include?(end_pos) && board.empty?(end_pos)
    update_pos(end_pos)

    true
  end

  def update_pos(end_pos)
    board[pos] = nil
    self.pos = end_pos
    board[end_pos] = self
  end

  def move_diffs
    [[heading, -1], [heading, 1]]
  end

  def moves
    possible_moves = move_diffs.map { |delta| add_arrs(delta, pos) }

    possible_moves.select { |move| board.valid_pos?(move) }
  end

  def add_arrs(arr1, arr2)
    raise "Can only add 2D vecs!" unless arr1.length == 2 and arr2.length == 2

    [arr1[0] + arr2[0], arr1[1] + arr2[1]]
  end

end

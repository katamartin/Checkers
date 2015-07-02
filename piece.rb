class Piece
  attr_reader :board, :pos, :color
  def initialize(board, pos, color)
    raise "Invalid position" unless board.on_board?(pos)
    raise "Invalid color" unless [:red, :black].include?(color)

    @board = board
    @pos = pos
    @color = color
    board.add_piece(self, pos)
  end

end

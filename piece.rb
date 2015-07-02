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

  def delete
    board[pos] = nil
    self.pos = nil
  end

  def perform_slide(end_pos)
    return false unless slides.include?(end_pos) && board.empty?(end_pos)
    update_pos(end_pos)

    maybe_promote
    true
  end

  def perform_jump(end_pos)
    return false unless jumps.include?(end_pos) && board.empty?(end_pos)
    jump_dir = jumps.index(end_pos)
    jumped_piece = board[slides[jump_dir]]
    return false if jumped_piece.nil? || jumped_piece.color == color
    update_pos(end_pos)
    jumped_piece.delete

    maybe_promote
    true
  end

  def maybe_promote
    if (heading == 1 && pos.first == 7) || (heading == -1 && pos.first == 0)
      self.kinged = true
    end
  end

  def update_pos(end_pos)
    board[pos] = nil
    self.pos = end_pos
    board[end_pos] = self
  end

  def slide_diffs
    [[heading, -1], [heading, 1]]
  end

  def jump_diffs
    [[2 * heading, -2], [2 * heading, 2]]
  end

  def slides
    possible_slides = slide_diffs.map { |delta| add_arrs(delta, pos) }

    possible_slides.select { |slide| board.valid_pos?(slide) }
  end

  def jumps
    possible_jumps = jump_diffs.map { |delta| add_arrs(delta, pos) }

    possible_jumps.select { |jump| board.valid_pos?(jump) }
  end

  def add_arrs(arr1, arr2)
    raise "Can only add 2D vecs!" unless arr1.length == 2 and arr2.length == 2

    [arr1[0] + arr2[0], arr1[1] + arr2[1]]
  end

  def subtract_arrs(arr1, arr2)
    raise "Can only subtract 2D vecs!" unless arr1.length == 2 and arr2.length == 2

    [arr1[0] - arr2[0], arr1[1] - arr2[1]]
  end

end

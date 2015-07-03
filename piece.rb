require 'colorize'
require_relative 'arrays'
require_relative 'errors'

class Piece
  attr_reader :color
  attr_accessor :kinged, :headings
  def initialize(board, pos, color, kinged = false)
    raise "Invalid position" unless board.valid_pos?(pos)
    raise "Invalid color" unless [:red, :black].include?(color)

    @board = board
    @pos = pos
    @color = color
    @headings = color == :red ? [1] : [-1]
    @kinged = kinged
    board.add_piece(self, pos)
  end

  def to_s
    if kinged
      "♛".colorize(color)
    else
      "●".colorize(color)
    end
  end

  def king?
    kinged
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
    jumped_piece = board[midpoint(end_pos, pos)]
    return false if jumped_piece.nil? || jumped_piece.color == color
    update_pos(end_pos)
    jumped_piece.delete

    maybe_promote
    true
  end

  def perform_moves!(move_sequence)
    count = move_sequence.length
    if count == 0
      raise InvalidMoveError
    elsif count == 1
      unless perform_slide(move_sequence.last) || perform_jump(move_sequence.last)
        raise InvalidMoveError
      end
    else
      move_sequence.each do |move|
        raise InvalidMoveError unless perform_jump(move)
      end
    end
  end

  def valid_move_seq?(move_sequence)
    duped_board = board.deep_dup
    duped_piece = duped_board[pos]
    begin
      duped_piece.perform_moves!(move_sequence)
    rescue InvalidMoveError
      return false
    end

    true
  end

  def perform_moves(move_sequence)
    if valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
    else
      raise InvalidMoveError
    end
  end

  def maybe_promote
    bottom = headings.include?(1) && pos.first == 7
    top = headings.include?(-1) && pos.first == 0
    if !kinged && (bottom || top)
      self.kinged = true
      headings << headings.first * -1
    end
  end

  def update_pos(end_pos)
    board[pos] = nil
    self.pos = end_pos
    board[end_pos] = self
  end

  def slide_diffs
    diffs = []
    headings.each do |dir|
      diffs << [dir, -1]
      diffs << [dir, 1]
    end

    diffs
  end

  def jump_diffs
    diffs = []
    headings.each do |dir|
      diffs << [2 * dir, -2]
      diffs << [2 * dir, 2]
    end

    diffs
  end

  def slides
    possible_slides = slide_diffs.map { |delta| add_arrs(delta, pos) }

    possible_slides.select { |slide| board.valid_pos?(slide) }
  end

  def jumps
    possible_jumps = jump_diffs.map { |delta| add_arrs(delta, pos) }

    possible_jumps.select { |jump| board.valid_pos?(jump) }
  end

  def dup(duped_board)
    duped = Piece.new(duped_board, pos.dup, color, kinged)
    duped.headings = [1, -1] if king?

    duped
  end

  protected
  attr_reader :board
  #attr_accessor :kinged, :headings

  private
  include ArrayArithmetic
  attr_accessor :pos

end

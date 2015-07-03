require_relative 'board'
require_relative 'piece'

class Game
  def initialize
    @board = Board.new
    @players = [:red, :black]
  end

  def play
    until won?
      switch_players
      board.render
      player = players.first
      play_turn(player)
    end
    board.render
    puts "#{player.capitalize} wins!"
  end

  def play_turn(color)
      message = "It's #{color.capitalize}'s turn!"
    begin
      board.render("It's #{color.to_s.capitalize}'s turn!")
      sequence = board.get_move_sequence(color, message)
      try_sequence(color, sequence)
      move_made = true
    rescue InvalidMoveError => e
      message = e.message
      retry
    end
  end

  def try_sequence(color, sequence)
    piece = board[sequence.first]
    if piece.nil? || color != piece.color
      raise InvalidMoveError.new(Piece), "Move a #{color} piece!"
    end
    piece.perform_moves(sequence.drop(1))
  end


  def won?
    pieces = board.pieces

    pieces.all? { |p| p.color == :red } || pieces.all? { |p| p.color == :black }
  end

  def switch_players
    players.rotate!
  end

  private
  attr_reader :players, :board

end

g = Game.new
g.play

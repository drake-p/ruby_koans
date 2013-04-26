require File.expand_path(File.dirname(__FILE__) + '/neo')

# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.

class Player
  attr_accessor :total_score
  attr_reader :turn_score
  attr_reader :dice

  def initialize
    @total_score, @turn_score, @dice = 0, 0, DiceSet.new(5)
  end

  def in_game?
    @total_score > 0 || @turn_score >= 300
  end

  def has_turn?
    @dice.count > 0
  end

  def end_turn
    @total_score += @turn_score
    @dice.count = 5
  end

  def roll
    @dice.count > 0 ? (@dice.roll(@dice.count)) : (raise(GameError, "Your turn has ended"))

    s = score(@dice.values)

    @turn_score += s[:score]

    case s[:scoring_dice]
    when 0
      @dice.count = 0
      #@turn_score = 0
    when @dice.count
      @dice.count = 5
    else
      @dice.count -= s[:scoring_dice]
    end
    return s[:score]
  end
end

class DiceSet
  attr_accessor :values
  attr_accessor :count

  def initialize(initial_count)
    @count = initial_count
  end

  def roll(count)
    @values = []
    count.times { @values << rand(1..6) }
  end
end

def score(dice)
  triplet_score, singlet_score = [[0, 1000, 200, 300, 400, 500, 600], [0, 100, 0, 0, 0, 50, 0]]
  dice.sort!

  # Find and remove any triplets from the dice
  triplet = dice.find { |item| dice.count(item) >=3 }.to_i
  dice.slice!(dice.index(triplet), 3) unless triplet == 0

  # Add up scores for the triplet and any remaining singlets
  score = triplet_score[triplet] + dice.inject(0) { |sum, singlet| sum + singlet_score[singlet] }
  scoring_dice = triplet * 3 + dice.count(1) + dice.count(5)

  return {score: score, scoring_dice: scoring_dice}
end

class GameError < StandardError
end

class AboutPlayers < Neo::Koan
	def test_can_create_a_player
		bob = Player.new
		assert_not_nil bob
	end

  def test_player_starts_with_certain_attributes
    bob = Player.new

    assert_equal 0, bob.turn_score
    assert_equal 0, bob.total_score
    assert_not_nil bob.dice
    assert_equal false, bob.in_game?
  end

  def test_player_can_roll_dice_to_score
    bob = Player.new

    tally_before = bob.turn_score
    score = bob.roll

    assert_equal true, bob.turn_score == tally_before + score
  end

  def test_roll_multiple_times_to_accumulate_score
    bob = Player.new
    scores = []
    while bob.has_turn? do
      scores << bob.roll
    end

    assert_equal bob.turn_score, scores.inject(0) { |total, s| total + s }, scores
  end

  def test_turn_score_is_added_to_total
    bob = Player.new
    scores = []
    total_before = bob.total_score

    while bob.has_turn? do
      scores << bob.roll
    end
    bob.end_turn

    assert_equal total_before + bob.turn_score, bob.total_score
    assert false, "#{scores}"
  end

  # def test_player_cannot_roll_out_of_turn
  #   bert = Player.new
  #   ernie = Player.new
  #   game = Greed.new(bert, ernie)

  #   assert_raise(GameError) { ernie.roll }
  # end

  def test_player_score_accumulates_if_in_game
    bert = Player.new
    ernie = Player.new
    game = Greed.new(bert, ernie)

    assert_equal bert.total_score, 0
    bert.roll
  end

  def test_player_can_check_their_score

  end

  def test_player_can_win_or_lose
    
  end

  # def test_player_is_in_or_out_of_game
  #   bert = Player.new
  #   ernie = Player.new
  #   game = Greed.new(bert, ernie)
  #   assert_equal false, bert.in_game?
  #   game.round
  #   game.round
  #   game.round
  #   assert_equal true, bert.in_game?
  # end
end

class AboutDice < Neo::Koan
  def test_can_create_a_dice_set
    dice = DiceSet.new(5)
    assert_not_nil dice
  end

  def test_rolling_the_dice_returns_a_set_of_integers_between_1_and_6
    dice = DiceSet.new(5)

    dice.roll(5)
    assert dice.values.is_a?(Array), "should be an array"
    assert_equal 5, dice.values.size
    dice.values.each do |value|
      assert value >= 1 && value <= 6, "value #{value} must be between 1 and 6"
    end
  end

  def test_dice_values_do_not_change_unless_explicitly_rolled
    dice = DiceSet.new(5)
    dice.roll(5)
    first_time = dice.values
    second_time = dice.values
    assert_equal first_time, second_time
  end

  def test_dice_values_should_change_between_rolls
    dice = DiceSet.new(5)

    dice.roll(5)
    first_time = dice.values

    dice.roll(5)
    second_time = dice.values

    assert_not_equal first_time, second_time,
      "Two rolls should not be equal"
  end

  def test_you_can_roll_different_numbers_of_dice
    dice = DiceSet.new(5)

    dice.roll(3)
    assert_equal 3, dice.values.size

    dice.roll(1)
    assert_equal 1, dice.values.size
  end
end

class AboutScoring < Neo::Koan

  def test_score_of_an_empty_list_is_zero
    assert_equal 0, score([])[:score]
  end

  def test_score_of_a_single_roll_of_5_is_50
    assert_equal 50, score([5])[:score]
  end

  def test_score_of_a_single_roll_of_1_is_100
    assert_equal 100, score([1])[:score]
  end

  def test_score_of_multiple_1s_and_5s_is_the_sum_of_individual_scores
    assert_equal 300, score([1,5,5,1])[:score]
  end

  def test_score_of_single_2s_3s_4s_and_6s_are_zero
    assert_equal 0, score([2,3,4,6])[:score]
  end

  def test_score_of_a_triple_1_is_1000
    assert_equal 1000, score([1,1,1])[:score]
  end

  def test_score_of_other_triples_is_100x
    assert_equal 200, score([2,2,2])[:score]
    assert_equal 300, score([3,3,3])[:score]
    assert_equal 400, score([4,4,4])[:score]
    assert_equal 500, score([5,5,5])[:score]
    assert_equal 600, score([6,6,6])[:score]
  end

  def test_score_of_mixed_is_sum
    assert_equal 250, score([2,5,2,2,3])[:score]
    assert_equal 550, score([5,5,5,5])[:score]
  end

  def test_this_surfaces_some_values
    score = Player.new.roll
    assert_equal -1, score[:score]
  end

	def test_this_is_just_to_avoid_end_screen
		assert false, "Keep working"
	end
end

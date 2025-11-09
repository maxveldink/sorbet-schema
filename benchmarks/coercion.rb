# typed: strict
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "benchmark/ips"
require "sorbet-schema"

# Define some enums for the benchmark
class Rank < T::Enum
  enums do
    Ace = new
    King = new
    Queen = new
    Jack = new
    Ten = new
    Nine = new
    Eight = new
    Seven = new
    Six = new
    Five = new
    Four = new
    Three = new
    Two = new
  end
end

class Suit < T::Enum
  enums do
    Spades = new
    Hearts = new
    Clubs = new
    Diamonds = new
  end
end

# Define some structs for the benchmark
class Card < T::Struct
  const :rank, Rank
  const :suit, Suit
end

class Player < T::Struct
  const :name, String
  const :hand, T::Array[Card]
end

class Round < T::Struct
  const :number, Integer
  const :winner, T.nilable(Player)
end

class Game < T::Struct
  const :name, String
  const :players, T::Array[Player]
  const :rounds, T::Array[Round]
  const :deck_size, Integer
  const :shuffled, T::Boolean
end

# Create a schema for the Game struct
game_schema = Typed::Schema.from_struct(Game)

# Generate some data for the benchmark
game_data = {
  name: "Poker",
  players: Array.new(10) do |i|
    {
      name: "Player #{i}",
      hand: [
        {rank: "Ace", suit: "Spades"},
        {rank: "King", suit: "Spades"}
      ]
    }
  end,
  rounds: Array.new(5) do |i|
    {
      number: i + 1,
      winner: {
        name: "Player #{i % 2}",
        hand: [
          {rank: "Queen", suit: "Hearts"},
          {rank: "Jack", suit: "Hearts"}
        ]
      }
    }
  end,
  deck_size: 52,
  shuffled: true
}

# Run the benchmark
Benchmark.ips do |x|
  x.report("deserialization") do
    game_schema.from_hash(game_data)
  end

  x.compare!
end

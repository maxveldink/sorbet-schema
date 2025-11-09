# typed: strict
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "json"
require "sorbet-schema"

module BenchmarkHelpers
  extend T::Sig

  class Rank < T::Enum
    enums do
      Ace = new("Ace")
      King = new("King")
      Queen = new("Queen")
      Jack = new("Jack")
      Ten = new("Ten")
      Nine = new("Nine")
      Eight = new("Eight")
      Seven = new("Seven")
      Six = new("Six")
      Five = new("Five")
      Four = new("Four")
      Three = new("Three")
      Two = new("Two")
    end
  end

  class Suit < T::Enum
    enums do
      Spades = new("Spades")
      Hearts = new("Hearts")
      Clubs = new("Clubs")
      Diamonds = new("Diamonds")
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

  # Define a struct with MANY fields of the same types that require coercion
  # This will stress-test coercer caching by reusing the same coercers many times
  class Humongous < T::Struct
    const :field_1, Integer
    const :field_2, Integer
    const :field_3, Integer
    const :field_4, Integer
    const :field_5, Integer
    const :field_6, Integer
    const :field_7, Integer
    const :field_8, Integer
    const :field_9, Integer
    const :field_10, Integer
    const :field_11, Integer
    const :field_12, Integer
    const :field_13, Integer
    const :field_14, Integer
    const :field_15, Integer
    const :field_16, Integer
    const :field_17, Integer
    const :field_18, Integer
    const :field_19, Integer
    const :field_20, Integer
    const :field_21, Integer
    const :field_22, Integer
    const :field_23, Integer
    const :field_24, Integer
    const :field_25, Integer
    const :field_26, Integer
    const :field_27, Integer
    const :field_28, Integer
    const :field_29, Integer
    const :field_30, Integer
    const :field_31, Integer
    const :field_32, Integer
    const :field_33, Integer
    const :field_34, Integer
    const :field_35, Integer
    const :field_36, Integer
    const :field_37, Integer
    const :field_38, Integer
    const :field_39, Integer
    const :field_40, Integer
    const :field_41, Integer
    const :field_42, Integer
    const :field_43, Integer
    const :field_44, Integer
    const :field_45, Integer
    const :field_46, Integer
    const :field_47, Integer
    const :field_48, Integer
    const :field_49, Integer
    const :field_50, Integer

    const :float_1, Float
    const :float_2, Float
    const :float_3, Float
    const :float_4, Float
    const :float_5, Float
    const :float_6, Float
    const :float_7, Float
    const :float_8, Float
    const :float_9, Float
    const :float_10, Float
    const :float_11, Float
    const :float_12, Float
    const :float_13, Float
    const :float_14, Float
    const :float_15, Float
    const :float_16, Float
    const :float_17, Float
    const :float_18, Float
    const :float_19, Float
    const :float_20, Float

    const :bool_1, T::Boolean
    const :bool_2, T::Boolean
    const :bool_3, T::Boolean
    const :bool_4, T::Boolean
    const :bool_5, T::Boolean
    const :bool_6, T::Boolean
    const :bool_7, T::Boolean
    const :bool_8, T::Boolean
    const :bool_9, T::Boolean
    const :bool_10, T::Boolean
    const :bool_11, T::Boolean
    const :bool_12, T::Boolean
    const :bool_13, T::Boolean
    const :bool_14, T::Boolean
    const :bool_15, T::Boolean
    const :bool_16, T::Boolean
    const :bool_17, T::Boolean
    const :bool_18, T::Boolean
    const :bool_19, T::Boolean
    const :bool_20, T::Boolean

    const :sym_1, Symbol
    const :sym_2, Symbol
    const :sym_3, Symbol
    const :sym_4, Symbol
    const :sym_5, Symbol
    const :sym_6, Symbol
    const :sym_7, Symbol
    const :sym_8, Symbol
    const :sym_9, Symbol
    const :sym_10, Symbol
    const :sym_11, Symbol
    const :sym_12, Symbol
    const :sym_13, Symbol
    const :sym_14, Symbol
    const :sym_15, Symbol
    const :sym_16, Symbol
    const :sym_17, Symbol
    const :sym_18, Symbol
    const :sym_19, Symbol
    const :sym_20, Symbol
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def self.game_data
    {
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
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def self.humongous_data
    {
      field_1: "1", field_2: "2", field_3: "3", field_4: "4", field_5: "5",
      field_6: "6", field_7: "7", field_8: "8", field_9: "9", field_10: "10",
      field_11: "11", field_12: "12", field_13: "13", field_14: "14", field_15: "15",
      field_16: "16", field_17: "17", field_18: "18", field_19: "19", field_20: "20",
      field_21: "21", field_22: "22", field_23: "23", field_24: "24", field_25: "25",
      field_26: "26", field_27: "27", field_28: "28", field_29: "29", field_30: "30",
      field_31: "31", field_32: "32", field_33: "33", field_34: "34", field_35: "35",
      field_36: "36", field_37: "37", field_38: "38", field_39: "39", field_40: "40",
      field_41: "41", field_42: "42", field_43: "43", field_44: "44", field_45: "45",
      field_46: "46", field_47: "47", field_48: "48", field_49: "49", field_50: "50",
      float_1: "1.1", float_2: "2.2", float_3: "3.3", float_4: "4.4", float_5: "5.5",
      float_6: "6.6", float_7: "7.7", float_8: "8.8", float_9: "9.9", float_10: "10.1",
      float_11: "11.1", float_12: "12.2", float_13: "13.3", float_14: "14.4", float_15: "15.5",
      float_16: "16.6", float_17: "17.7", float_18: "18.8", float_19: "19.9", float_20: "20.1",
      bool_1: "true", bool_2: "false", bool_3: "true", bool_4: "false", bool_5: "true",
      bool_6: "false", bool_7: "true", bool_8: "false", bool_9: "true", bool_10: "false",
      bool_11: "true", bool_12: "false", bool_13: "true", bool_14: "false", bool_15: "true",
      bool_16: "false", bool_17: "true", bool_18: "false", bool_19: "true", bool_20: "false",
      sym_1: "sym1", sym_2: "sym2", sym_3: "sym3", sym_4: "sym4", sym_5: "sym5",
      sym_6: "sym6", sym_7: "sym7", sym_8: "sym8", sym_9: "sym9", sym_10: "sym10",
      sym_11: "sym11", sym_12: "sym12", sym_13: "sym13", sym_14: "sym14", sym_15: "sym15",
      sym_16: "sym16", sym_17: "sym17", sym_18: "sym18", sym_19: "sym19", sym_20: "sym20"
    }
  end
end


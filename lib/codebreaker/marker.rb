module Codebreaker
  class Marker
    def initialize(secret, guess)
      @secret, @guess = secret, guess
    end

    def exact_match_count
      (0..3).inject(0) do |count, index|
        count + (exact_match?(index) ? 1 : 0)
      end
    end

    def number_match_count
      (0..3).inject(0) do |count, index|
        count + (number_match?(index) ? 1 : 0)
      end
    end

    def exact_match?(index)
      @guess[index] == @secret[index]
    end

    def number_match?(index)
      @secret.include?(@guess[index]) && !exact_match?(index)
    end
  end
end
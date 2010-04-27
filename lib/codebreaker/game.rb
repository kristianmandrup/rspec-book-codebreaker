module Codebreaker
  class Game
    def initialize(messenger)
      @messenger = messenger
    end      
    
    def start
      @messenger.puts "Welcome to Codebreaker!"
    end
  end
end
require File.join(File.dirname(__FILE__), "..", "spec_helper")

module Codebreaker
  describe Game do  
    context "starting up" do
      it "should send a welcome message" do
        messenger = mock("messenger")
        game = Game.new(messenger)
        messenger.should_receive(:puts).with("Welcome to Codebreaker!")
        game.start
      end  
      
      it "should prompt for the first guess" do
        messenger = mock("messenger")
        game = Game.new(messenger)
        messenger.should_receive(:puts).with("Enter guess:")
        game.start
      end
    end
  end
end
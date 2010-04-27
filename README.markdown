Behavior Driven Development


Description of BDD
- domain-driven design

Principles of BDD
- Enough is enough
- Deliver stakeholder value

Automated scenarios and acceptance tests

The BDD Cycle
- red/green/refactor

Planning the First Release
- selecting stories
-- Code-breaker starts game
-- Code-breaker submits guess
-- Code-breaker wins game
-- Code-breaker loses game
-- Code-breaker plays again
-- Code-breaker saves score

User stories are a planning tool
- have business value
- be testable
- be small enough to implement in one iteration

Planning first iteration
- Acceptance Criteria       
- an example     

Feature: code-breaker starts game

  As a code-breaker
  I want to start a game
  So that I can break the code

  Scenario: start game
    Given I am not yet playing
    When I start a new game
    Then I should see "Welcome to Codebreaker!"
    And I should see "Enter guess:"

Given steps represent the state of the world before an event. 
When steps represent the event. 
Then steps represent the expected outcomes.
              
Cucumber DRYing
- Scenario Outlines

Scenario Outline: submit guess
  Given the secret code is <code>
  When I guess <guess>
  Then the mark should be <mark>

The Scenarios keyword indicates that what follows are rows of example
data.

Scenarios: all colors correct
| code    | guess   | mark |
| r g y c | r g y c | bbbb |
| r g y c | r g c y | bbww |
| r g y c | y r g c | bwww |
| r g y c | c r g y | wwww |


## Automating Features with Cucumber

Project structure
codebreaker
- bin
  - codebreaker
- features
  - step_definitions(folder)
  - support
    - env.rb
- lib
  - codebreaker(folder)
  - codebreaker.rb
- spec
  - codebreaker(folder)
  - spec_helper.rb
                                                    
To run a specific feature
cucumber features/codebreaker_starts_game.feature -s  # s as short
        
You can implement step definitions for undefined steps with these snippets:

Then /^I should see "([^\"]*)"$/ do |arg1|
  @message.should include(message)
end

or, you can put a keyword pending inside the block to indicate that the step
has not been implemented

Then /^I should see "([^\"]*)"$/ do |arg1|
  pending
end
                                  
In addition, we don't want to use STDOUT because Cucumber is using STDOUT
to report results when we run the scenarios. We do want something that
shares an interface with STDOUT so that the Game object won’t know the
difference.

=> use StringIO object

When /^I start a new game$/ do
  @messenger = StringIO.new
  game = Codebreaker::Game.new(@messenger)
  game.start
end

Then /^I should see "([^\"]*)" $/ do |message|
  @messenger.string.split("\n" ).should include(message)
end

=> or use Test Double (write our own)

A fake object that pretends to be real object is called a Test Double
# features/step_definitions/codebreaker_steps.rb


## Describing Code with RSpec

Start to write rspec files 

# spec/codebreaker/game_spec.rb
module Codebreaker
  describe Game do
  end
end

The describe() method hooks into RSpec's API, and it returns a Spec::ExampleGroup,
which is, as it suggests, a group of examples—examples of the expected
behaviour of an object.

Next step is to connect specs to the code

# lib/codebreaker/game.rb
module Codebreaker
  class Game
  end
end

# lib/codebreaker.rb
require 'codebreaker/game'

# spec/spec_helper.rb
$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")
require 'spec'
require 'codebreaker'

# last, need to require spec_helper.rb inside game_spec.rb
require File.join(File.dirname(__FILE__), ".." ,"spec_helper" )

module Codebreaker
  describe Game do
  end
end
  
next, Connect the features to the code
To see where we are in relation to our feature, add the lib directory to
the load path and require codebreaker in features/support/env.rb:

$LOAD_PATH << File.join(File.dirname(__FILE__),".." ,".." ,"lib" )
require 'codebreaker'

now, we start Red/Green/Refactor cycle

# game_spec.rb
require File.join(File.dirname(__FILE__), "..", "spec_helper")

module Codebreaker
  describe Game do  
    context "starting up" do
      it "should send a welcome message" do
        messenger.should_receive(:puts).with("Welcome to Codebreaker!")
        game.start
      end
    end
  end
end

# using Mock
The mock() method creates an instance of Spec::Mocks::Mock, which will
behave however we program it to.

module Codebreaker
  describe Game do  
    context "starting up" do
      it "should send a welcome message" do
        messenger = mock("messenger")
        game = Game.new(messenger)
        messenger.should_receive(:puts).with("Welcome to Codebreaker!")
        game.start
      end
    end
  end
end

# ... after a few iteration, we get                                     
# lib/codebreaker/game.rb
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

# run spec spec/codebreaker/game_spec.rb --format specdoc

as_null_object

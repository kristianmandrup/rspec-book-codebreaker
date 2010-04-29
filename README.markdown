Behavior Driven Development
---------------------------

### Description of BDD

* domain-driven design

### Principles of BDD

* Enough is enough
* Deliver stakeholder value

### Automated scenarios and acceptance tests

### The BDD Cycle

* red/green/refactor

Planning the First Release
--------------------------

### Selecting stories

* Code-breaker starts game
* Code-breaker submits guess
* Code-breaker wins game
* Code-breaker loses game
* Code-breaker plays again
* Code-breaker saves score

### User stories are a planning tool

* have business value
* be testable
* be small enough to implement in one iteration

#### Planning first iteration

* Acceptance Criteria

An example
    Feature: code-breaker starts game
  
    As a code-breaker
    I want to start a game
    So that I can break the code
  
    Scenario: start game
      Given I am not yet playing
      When I start a new game
      Then I should see "Welcome to Codebreaker!"
      And I should see "Enter guess:"

#### Given When Then

* Given steps represent the state of the world before an event. 
* When steps represent the event. 
* Then steps represent the expected outcomes.
              
#### Cucumber DRYing

Scenario Outlines

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


### Automating Features with Cucumber

Conventional project structure

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

    cucumber features/codebreaker_starts_game.feature -s  # s as short?
        
You can implement step definitions for undefined steps with these snippets:

    Then /^I should see "([^\"]*)"$/ do |arg1|
      @message.should include(message)
    end

or, you can put a keyword pending inside the block to indicate that the step
has not been implemented

    Then /^I should see "([^\"]*)"$/ do |arg1|
      pending
    end
         
Key is to 'write the code we wish we had' in step definitions.   
 
### Setting it up

Create these files

    # lib/codebreaker/game.rb
    module Codebreaker
      class Game
      end
    end
    
    # lib/codebreaker.rb
    require 'codebreaker/game'
    
    # features/support/env.rb:
    $LOAD_PATH << File.join(File.expand_path('../../../lib', __FILE__)
    require 'codebreaker'
                            
In addition, we don't want to use STDOUT because Cucumber is using STDOUT
to report results when we run the scenarios. We do want something that
shares an interface with STDOUT so that the Game object won’t know the
difference.

use StringIO object

    # features/step_definitions/codebreaker_steps.rb
    When /^I start a new game$/ do
      @messenger = StringIO.new
      game = Codebreaker::Game.new(@messenger)
      game.start
    end
    
    Then /^I should see "([^\"]*)" $/ do |message|
      @messenger.string.split("\n" ).should include(message)
    end

or build out a message collection object of our own

    # features/step_definitions/codebreaker_steps.rb
    class Output
      def messages
        @messages ||= []
      end
      
      def puts(message)
        messages << message
      end
    end
    
    def output
      @output ||= Output.new
    end

    # features/step_definitions/codebreaker_steps.rb
    When /^I start a new game$/ do
      game = Codebreaker::Game.new(output) # using output method
      game.start
    end
  
or just use a Test Double object provided by RSpec, as we'll see later.
    
Running `cucumber` will lead us to modify the game.rb file

    module Codebreaker
      class Game
        def initialize(output)
        end
        def start
        end
      end
    end
    
### Describing Code with RSpec

Start to write rspec files, and a parallel structure is maintained
in lib and spec folders

    # spec/codebreaker/game_spec.rb
    require 'spec_helper'
    
    module Codebreaker
      describe Game do 
        describe "#start" do 
          it "sends a welcome message"
          it "prompts for the first guess"
        end
      end
    end

The describe() method hooks into RSpec's API, and it returns a Spec::ExampleGroup,
which is, a group of examples of the expected behaviour of an object.

The it() method creates an example. Technically, it's an instance of the
ExampleGroup returned by describe().

Run `spec spec/codebreaker/game_spec.rb --format` to see formatted output

### Connect specs to the code
  
Since we already added lib to $LOAD_PATH, we don't need to do it again

    # spec/spec_helper.rb
    require 'codebreaker'

Run the following to see results

    spec spec/codebreaker/game_spec.rb --format nested
    
  
### Red/Green/Refactor cycle

Start with a failing example. Here, we are using `double'. A fake object that 
pretends to be real object is called a Test Double

    # game_spec.rb
    require 'spec_helper'
    
    module Codebreaker
      describe Game do
        describe "#start" do
          it "sends a welcome message" do
            output = double('output') # double method from rspec
            game = Game.new(output)
    
            output.should_receive(:puts).with('Welcome to Codebreaker!')
    
            game.start
          end
    
          it "prompts for the first guess"
        end
      end
    end

Running `spec spec --color` shows test failed and in red, to fix:

    module Codebreaker
      class Game
        def initialize(output)
          @output = output
        end
    
        def start
          @output.puts 'Welcome to Codebreaker!'
        end
      end
    end

So, now this test passed, continue to next.

    require 'spec_helper'
    
    module Codebreaker
      describe Game do
        describe "#start" do
          it "sends a welcome message" do
            output = double('output')
            game = Game.new(output)
    
            output.should_receive(:puts).with('Welcome to Codebreaker!')
    
            game.start
          end
    
          it "prompts for the first guess" do
            output = double('output')
            game = Game.new(output)
    
            output.should_receive(:puts).with('Enter guess:')
    
            game.start
          end
        end
      end
    end

Running `spec` again would show failing test in red, To fix it,
however, we need something more. because will expect exactly what 
you tell them to expect. 

    module Codebreaker
      class Game
        def initialize(output)
          @output = output
        end
    
        def start
          @output.puts 'Welcome to Codebreaker!'
          @output.puts 'Enter guess:'
        end
      end
    end

### as_null_object
    
The simplest way is to tell the double output to only listen for the 
messages we tell it to expect, and ignore any other messages.

    # game_spec.rb will work!
    require 'spec_helper'

    module Codebreaker
      describe Game do
        describe "#start" do
          it "sends a welcome message" do
            output = double('output').as_null_object
            game = Game.new(output)
    
            output.should_receive(:puts).with('Welcome to Codebreaker!')
    
            game.start
          end
    
          it "prompts for the first guess" do
            output = double('output').as_null_object
            game = Game.new(output)
    
            output.should_receive(:puts).with('Enter guess:')
    
            game.start
          end
        end
      end
    end
    
### Refactor

#### before(:each)  

Modify game_spec.rb

    require 'spec_helper'
    
    module Codebreaker
      describe Game do
        describe "#start" do
          before(:each) do
            @output = double('output').as_null_object
            @game = Game.new(@output)
          end
    
          it "sends a welcome message" do
            @output.should_receive(:puts).with('Welcome to Codebreaker!')
            @game.start
          end
    
          it "prompts for the first guess" do
            @output.should_receive(:puts).with('Enter guess:')
            @game.start
          end
        end
      end
    end
    
#### let(:method) {}

When the code in a before block is only creating instance variables and
assigning them values, which is most of the time, we can use RSpec's
let() method instead.

    require 'spec_helper'
    
    module Codebreaker
      describe Game do
        describe "#start" do
          let(:output) { double('output').as_null_object }
          let(:game)   { Game.new(output) }
    
          it "sends a welcome message" do
            output.should_receive(:puts).with('Welcome to Codebreaker!')
            game.start
          end
    
          it "prompts for the first guess" do
            output.should_receive(:puts).with('Enter guess:')
            game.start
          end
        end
      end
    end
    
### See the game in action

Add a bin/codebreaker file.

    #!/usr/bin/env ruby
    $LOAD_PATH.unshift File.expand_path('../../lib' , __FILE__)
    require 'codebreaker'
    
    game = Codebreaker::Game.new(STDOUT)
    game.start
    
Run `chmod 755 bin/codebreaker` and run it. 


















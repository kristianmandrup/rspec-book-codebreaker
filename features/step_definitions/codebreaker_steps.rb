Given /^I am not yet playing$/ do
end

When /^I start a new game$/ do
  game = Codebreaker::Game.new
  @message = game.start
end

Then /^I should see "([^\"]*)" $/ do |message|
  @message.should include(message)
end


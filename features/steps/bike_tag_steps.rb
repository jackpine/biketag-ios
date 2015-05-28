Given(/^the game has started$/) do
  wait_for do
    !query('UINavigationBar').empty?
  end
end

Then(/^I should see a photo of the current tag$/) do
  wait_for do
    query("UIImageView marked:'current photo'", :image).first != nil
  end
end

Given(/^I've created an account$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I'm near the current tag$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I submit a tag$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see that I got the tag right$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be prompted to submit the next tag$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I submit the next tag$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^my new tag should be the current tag$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I dilly dally$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^someone else submits the current tag and a new tag before I can$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^their tag should be the current tag$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see that I was too slow$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I'm nowhere near the current tag$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see that I guessed wrong$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I've just installed the app$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I submit a unique username and email$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should be logged into my new account$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I submit a pre\-existing username and email$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see an error message$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I finally submit my tag$/) do
    pending # express the regexp above with the code you wish you had
end

Then(/^their tag should still be the current tag$/) do
    pending # express the regexp above with the code you wish you had
end

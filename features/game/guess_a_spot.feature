Feature: Guessing a spot
  As a player
  I should be able to submit a new spot

  Background: Get past the splash page
    Given I have dismissed the splash page

  @correct_spot
  Scenario: Submitting the correct spot
    Given I'm looking at the list of current spots
    And I guess correctly for the first one
    Then I should see that I was correct
    And I should be prompted to submit a new spot
    When I submit the next spot
    Then my new spot should be the current spot

  Scenario: Submitting the wrong spot
    Given I'm nowhere near the current spot
    When I submit a spot
    Then I should see that I guessed wrong

  Scenario: Being a slow poke
    Given I'm near the current spot
    When I submit a spot
    Then I should see that I got the spot right
    And I should be prompted to submit the next spot
    When I dilly dally
    And someone else submits the current spot and a new spot before I can
    Then their spot should be the current spot
    When I finally submit my spot
    Then I should see that I was too slow
    And their spot should still be the current spot

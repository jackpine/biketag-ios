Feature: Making a new Tag
  As a player
  I should be able to submit a new tag

  Background:
    Given I've created an account

  Scenario: Submitting the correct tag
    Given I'm near the current tag
    When I submit a tag
    Then I should see that I got the tag right
    And I should be prompted to submit the next tag
    When I submit the next tag
    Then my new tag should be the current tag

  Scenario: Submitting the wrong tag
    Given I'm nowhere near the current tag
    When I submit a tag
    Then I should see that I guessed wrong

  Scenario: Being a slow poke
    Given I'm near the current tag
    When I submit a tag
    Then I should see that I got the tag right
    And I should be prompted to submit the next tag
    When I dilly dally
    And someone else submits the current tag and a new tag before I can
    Then their tag should be the current tag
    When I finally submit my tag
    Then I should see that I was too slow
    And their tag should still be the current tag

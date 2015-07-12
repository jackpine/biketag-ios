Feature: See current spots
  As a player
  I should be able to see the list of current spots
  So that I can try to find one of them

  Scenario: Seeing current spots
    Given the game has started
    Then I should see a photo of a current spot

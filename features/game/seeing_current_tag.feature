Feature: Seeing the Current Tag
  As a player
  I should be able to see what the current tag is
  So that I can try to find it and get a point

  @wip
  Scenario: Seeing the current tag
    Given the game has started
    Then I should see a photo of the current tag

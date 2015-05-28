Feature: Creating my account
  As someone who just installed the app
  I should be able to create an account
  So that my gameplay can be attributed to me

  Background:
    Given I've just installed the app

  Scenario: Successful account creation
    When I submit a unique username and email
    Then I should be logged into my new account

  Scenario: Duplicate username
    When I submit a pre-existing username and email
    Then I should see an error message
    When I submit a unique username and email
    Then I should be logged into my new account

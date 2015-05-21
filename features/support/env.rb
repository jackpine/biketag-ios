require 'calabash-cucumber/wait_helpers'
require 'calabash-cucumber/operations'
World(Calabash::Cucumber::Operations)

# Pry is not allowed on the Xamarin Test Cloud.  This will force a validation
# error if you mistakenly submit a binding.pry to the Test Cloud.
unless ENV['XAMARIN_TEST_CLOUD']
  require 'pry'
end

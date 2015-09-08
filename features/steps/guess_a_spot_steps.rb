module BikeTag
  module Wait

    def wait_for_button_enabled(mark, timeout=5.0)
      query = "view marked:'#{escape_single_quotes(mark)}'"

      wait_for_view(query, {:timeout => timeout})

      message = "Timed out after '#{timeout}' waiting from '#{mark}' to become enabled"
      wait_for(message, {:timeout => timeout}) do
        result = query(query, :isEnabled)
        if result.empty?
          false
        else
          result.first == 1
        end
      end
    end
  end
end

World(BikeTag::Wait)

Given(/^I'm looking at the list of current spots$/) do
  wait_for_view("view marked:'current spots'")

  wait_for_button_enabled('guess spot')
end

And(/I guess correctly for the first one$/) do
  tap("view marked:'guess spot'")

  wait_for_view("view marked:'photo evidence'")

  wait_for_button_enabled('take picture: evidence')
  tap("view marked:'take picture: evidence'")

  wait_for_view("view marked:'check guess'")
  tap("view marked:'pretend I was right'")
end

Then(/I should see that I was correct$/) do
  wait_for_view("view marked:'guessed correct'")
end

Then(/I should be prompted to submit a new spot$/) do
  tap("view marked:'at new spot button'")
end

Then(/I submit the next spot$/) do
  wait_for_view("view marked:'new spot'")

  wait_for_button_enabled('take picture: claim spot')
  tap("view marked:'take picture: claim spot'")
end

Then(/my new spot should be the current spot$/) do
  wait_for_view("view marked:'current spots'")
  # TODO: check that the image is correct with a checksum
end

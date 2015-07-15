module BikeTag
  module Wait

    DEFAULT_WAIT = 5

    def wait_options(waiting_for, timeout=DEFAULT_WAIT)
      {
        :timeout => 5,
        :timeout_message =>
        "Timed out waiting for '#{waiting_for}' after #{timeout} seconds"
      }
    end

    def wait_for_view(mark, timeout=DEFAULT_WAIT)
      wait_for_none_animating
      options = wait_options(mark, timeout)
      wait_for(options) do
        !query("view marked:'#{mark}'").empty?
      end
    end

    def touch_view(mark, timeout=DEFAULT_WAIT)
      wait_for_view(mark, timeout)
      touch("view marked:'#{mark}'")
    end

    def wait_for_button_enabled(mark, timeout=DEFAULT_WAIT)
      wait_for_view(mark, timeout)

      options = wait_options("'#{mark}' button to become enabled", timeout)
      query = "button marked:'#{mark}'"

      wait_for(options) do
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
  wait_for_view('current spots')

  wait_for_button_enabled('guess spot')
end

And(/I guess correctly for the first one$/) do
  touch_view('guess spot')

  wait_for_view('photo evidence')

  wait_for_button_enabled('take picture: evidence')
  touch_view('take picture: evidence')

  wait_for_view('check guess')
  touch_view('(pretend I was right)')
end

Then(/I should see that I was correct$/) do
  wait_for_view('guessed correct')
end

Then(/I should be prompted to submit a new spot$/) do
  touch_view('at new spot button')
end

Then(/I submit the next spot$/) do
  wait_for_view('new spot')

  wait_for_button_enabled('take picture: claim spot')
  touch_view('take picture: claim spot')
end

Then(/my new spot should be the current spot$/) do
  wait_for_view('current spots')
  # TODO: check that the image is correct with a checksum
end

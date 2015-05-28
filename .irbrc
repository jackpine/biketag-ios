require 'irb/completion'
require 'irb/ext/save-history'

module Calabash
  module IRBRC
    def self.with_warn_suppressed(&block)
      warn_level = $VERBOSE
      begin
        $VERBOSE = nil
        block.call
      ensure
        $VERBOSE = warn_level
      end
    end

    def self.message_of_the_day
      motd = ["Let's get this done!", 'Ready to rumble.', 'Enjoy.', 'Remember to breathe.',
              'Take a deep breath.', "Isn't it time for a break?", 'Can I get you a coffee?',
              'What is a calabash anyway?', 'Smile! You are on camera!', 'Let op! Wild Rooster!',
              "Don't touch that button!", "I'm gonna take this to 11.", 'Console. Engaged.',
              'Your wish is my command.', 'This console session was created just for you.',
              'Den som jager to harer, får ingen.', 'Uti, non abuti.', 'Non Satis Scire',
              'Nullius in verba', 'Det ka æn jå væer ei jált']

      begin
        puts "Calabash #{Calabash::Cucumber::VERSION} says: '#{motd.shuffle.first}'"
      rescue NameError => _
        puts "Calabash says: '#{motd.shuffle.first}'"
      end
    end
  end
end

has_skipped_requires = false

Calabash::IRBRC.with_warn_suppressed do
  begin
    require 'calabash-cucumber/operations'
    extend Calabash::Cucumber::Operations

    def embed(x,y=nil,z=nil)
      puts "Screenshot at #{x}"
    end
  rescue LoadError => _
    puts 'INFO: Skipping calabash dependency'
    has_skipped_requires = true
  end

  begin
    require 'awesome_print'
    AwesomePrint.irb!
  rescue LoadError => _
    puts 'INFO: Skipping awesome_print dependency'
    has_skipped_requires = true
  end

  begin
    require 'pry'
  rescue LoadError => _
    puts 'INFO: Skipping pry dependency'
    has_skipped_requires = true
  end

  begin
    require 'pry-nav'
  rescue LoadError => _
    puts 'INFO: Skipping pry-nav dependency'
    has_skipped_requires = true
  end
end


if has_skipped_requires
  puts 'INFO: Some requires have been skipped.'
  puts 'INFO: Run with bundle exec if you need these dependencies'
end

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = '.irb-history'

ARGV.concat [ '--readline',
              '--prompt-mode',
              'simple']
unless ENV['APP']
  ENV['APP'] = './BikeTag.app'
end

puts 'INFO: *** Application Information ***'
puts "INFO: Target app is #{ENV['APP']}"
puts 'INFO: You can build a new app with `make_app`'
puts ''

def make_app
  system('make', 'app')
  printf 'INFO: Installing the new application...'
  system('run-loop', *['simctl', 'install', '-a', ENV['APP'], '--force'])
  puts 'done!'
end

def print_marks(marks, max_width)
  counter = -1
  marks.sort.each { |elm|
    printf("%4s %#{max_width + 2}s => %s\n", "[#{counter = counter + 1}]", elm[0], elm[1])
  }
end

def accessibility_marks(kind, opts={})
  opts = {:print => true, :return => false}.merge(opts)

  kinds = [:id, :label]
  raise "'#{kind}' is not one of '#{kinds}'" unless kinds.include?(kind)

  res = Array.new
  max_width = 0
  query('*').each { |view|
    aid = view[kind.to_s]
    unless aid.nil? or aid.eql?('')
      cls = view['class']
      len = cls.length
      max_width = len if len > max_width
      res << [cls, aid]
    end
  }
  print_marks(res, max_width) if opts[:print]
  opts[:return] ? res : nil
end

def text_marks(opts={})
  opts = {:print => true, :return => false}.merge(opts)

  indexes = Array.new
  idx = 0
  all_texts = query('*', :text)
  all_texts.each { |view|
    indexes << idx unless view.eql?('*****') or view.eql?('')
    idx = idx + 1
  }

  res = Array.new

  all_views = query('*')
  max_width = 0
  indexes.each { |index|
    view = all_views[index]
    cls = view['class']
    text = all_texts[index]
    len = cls.length
    max_width = len if len > max_width
    res << [cls, text]
  }

  print_marks(res, max_width) if opts[:print]
  opts[:return] ? res : nil
end

def ids
  accessibility_marks(:id)
end

def labels
  accessibility_marks(:label)
end

def text
  text_marks
end

def marks
  opts = {:print => false, :return => true }
  res = accessibility_marks(:id, opts).each { |elm|elm << :ai }
  res.concat(accessibility_marks(:label, opts).each { |elm| elm << :al })
  res.concat(text_marks(opts).each { |elm| elm << :text })
  max_width = 0
  res.each { |elm|
    len = elm[0].length
    max_width = len if len > max_width
  }

  counter = -1
  res.sort.each { |elm|
    printf("%4s %-4s => %#{max_width}s => %s\n",
           "[#{counter = counter + 1}]",
           elm[2], elm[0], elm[1])
  }
  nil
end

puts 'INFO: *** Useful Functions ***'
puts '>     ids #=> all accessibilityIdentifiers'
puts '>  labels #=> all accessibilityLabels'
puts '>    text #=> all text'
puts ''

Calabash::IRBRC.message_of_the_day

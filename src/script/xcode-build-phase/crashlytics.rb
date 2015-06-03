#!/usr/bin/env ruby

if File.exists?('/Applications/Crashlytics.app')
  puts 'INFO: Activating Crashlytics'

  keys =
    [
      '393e3b32fad6dec245cd2f9e4a061d7904608ca5',
      'c072b55ca7323d937ab0d36adba3eb97541698104b7b1b8c28dccf40274f7205'
  ]
  system('./Frameworks/Crashlytics.framework/run', *keys)
else
  puts 'WARN: /Applications/Crashlytics.app is not installed; skipping activation'
end

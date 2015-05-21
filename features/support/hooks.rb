require 'calabash-cucumber/launcher'

module LaunchControl
  @@launcher = nil

  def self.launcher
    @@launcher ||= Calabash::Cucumber::Launcher.new
  end

  def self.launcher=(launcher)
    @@launcher = launcher
  end

  def self.target
    ENV['DEVICE_TARGET'] || RunLoop::Core.default_simulator
  end

  def self.target_is_simulator?
    RunLoop::Core.simulator_target?({:device_target => LaunchControl.target})
  end

  def self.target_is_physical_device?
    !self.target_is_simulator?
  end

  def self.ensure_ipa
    ipa_path = File.expand_path('./BikeTag.ipa')
    unless File.exist?(ipa_path)
      system('make', 'ipa')
    end
    ipa_path
  end

  def self.install_on_physical_device
    Calabash::IDeviceInstaller.new(LaunchControl.ensure_ipa,
                                   LaunchControl.target).install_app
  end

  def self.ensure_app_installed_on_device
    ideviceinstaller = Calabash::IDeviceInstaller.new(LaunchControl.ensure_ipa,
                                                      LaunchControl.target)
    unless ideviceinstaller.app_installed?
      ideviceinstaller.install_app
    end
  end
end

Before('@reset_app_btw_scenarios') do
  if xamarin_test_cloud?
    ENV['RESET_BETWEEN_SCENARIOS'] = '1'
  elsif LaunchControl.target_is_simulator?
    target = LaunchControl.target
    simulator = RunLoop::Device.device_with_identifier(target)
    bridge = RunLoop::Simctl::Bridge.new(simulator, ENV['APP'])
    bridge.reset_app_sandbox
  else
    LaunchControl.install_on_physical_device
  end
end

Before('@reset_device_settings') do
  if xamarin_test_cloud?
    ENV['RESET_BETWEEN_SCENARIOS'] = '1'
  elsif LaunchControl.target_is_simulator?
    target = LaunchControl.target
    RunLoop::Core.simulator_target?({:device_target => target})
    sim_control = RunLoop::SimControl.new
    sim_control.reset_sim_content_and_settings
  else
    LaunchControl.install_on_physical_device
  end
end

Before do |scenario|
  launcher = LaunchControl.launcher

  unless launcher.calabash_no_launch?
    launcher.relaunch
    launcher.calabash_notify(self)
  end

  if xamarin_test_cloud?
    ENV['RESET_BETWEEN_SCENARIOS'] = '0'
  end

  # Re-installing the app on a device does not clear the Keychain settings
  if scenario.source_tag_names.include?('@reset_device_settings')
    if xamarin_test_cloud? || LaunchControl.target_is_physical_device?
      keychain_clear
    end
  end
end

After do |_|

end

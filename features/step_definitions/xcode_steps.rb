require 'set'

When(/^I add an (iOS|OS X) (Spec Suite|Testing Bundle) target$/) do |os, target_type|
  template_name = "#{os} Cedar #{target_type.downcase}"
  `osascript features/support/scripts/add_target.applescript #{os.downcase.inspect} #{template_name.inspect}`
  expect(File.exist?("template-project/Specs")).to be_truthy
end

Given(/^an Xcode (iOS|OS X) project$/) do |os|
  `rm -rf template-project`
  `find features/support/#{os.downcase.gsub(/\s+/, '')}-project-template -name "xcuserdata" | rm -rf`
  `cp -pr features/support/#{os.downcase.gsub(/\s+/, '')}-project-template template-project`
  expect($?.exitstatus).to eq(0)
  expect(File.exist?("template-project")).to be_truthy

  xcode = File.absolute_path(File.join(`xcode-select -p`.strip, '../..'))
  `open -a #{xcode.inspect} template-project/template-project.xcodeproj`
end

Then(/^I should only see the (iOS|OS X) Targets$/) do |os|
  targets = `osascript features/support/scripts/list_targets.applescript #{os.downcase.inspect}`.chomp.split(',')
  expect(targets.to_set).to eq(["#{os} Cedar Testing Bundle", "#{os} Cedar Spec Suite"].to_set)
end

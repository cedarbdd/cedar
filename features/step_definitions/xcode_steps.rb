When(/^I add an (iOS|OS X) Spec (suite|bundle) target$/) do |os, target_type|
  xcode = File.absolute_path(File.join(`xcode-select -p`.strip, '../..'))
  `open -a #{xcode.inspect} template-project/template-project.xcodeproj`
  `osascript features/support/scripts/#{os.downcase.gsub(/\s+/, '')}_add_spec_#{target_type.downcase.gsub(/\s+/, '')}.applescript`
  expect(File.exist?("template-project/Specs")).to be_truthy
end

Given(/^an Xcode (iOS|OS X) project$/) do |os|
  `rm -rf template-project`
  `cp -pr features/support/#{os.downcase.gsub(/\s+/, '')}-project-template template-project`
  expect($?.exitstatus).to eq(0)
  expect(File.exist?("template-project")).to be_truthy
end

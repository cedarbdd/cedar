When(/^I add an (iOS|OS X) Spec (suite|bundle) target$/) do |os, target_type|
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript features/support/scripts/#{os.downcase.gsub(/\s+/, '')}_add_spec_#{target_type.downcase.gsub(/\s+/, '')}.scpt`
  File.exist?("template-project/Specs").should be_true
end

Given(/^an Xcode (iOS|OS X) project$/) do |os|
  `rm -rf template-project`
  `cp -pr features/support/#{os.downcase.gsub(/\s+/, '')}-project-template template-project`
  $?.exitstatus.should == 0
  File.exist?("template-project").should be_true
end

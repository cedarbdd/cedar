require 'pry'

Given(/^a Xcode project$/) do
  `rm -rf template-project`
  `cp -pr template-project-template template-project`
  $?.exitstatus.should == 0
  File.exist?("template-project").should be_true
end

When(/^I add a Spec bundle target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript scripts/add_spec_bundle.scpt`
  File.exist?("template-project/Specs").should be_true
end

Then(/^the `rake Spec` should work$/) do
  `cd template-project; cd Specs; rake Specs 2> /dev/null`
  $?.exitstatus.should == 0
end

When(/^I add a Spec suite target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript scripts/add_spec_suite.scpt`
  File.exist?("template-project/Specs").should be_true
end

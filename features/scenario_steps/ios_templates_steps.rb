Given(/^an Xcode iOS project$/) do
  `rm -rf template-project`
  `cp -pr ios-project-template template-project`
  $?.exitstatus.should == 0
  File.exist?("template-project").should be_true
end

When(/^I add an iOS Spec bundle target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript scripts/ios_add_spec_bundle.scpt`
  File.exist?("template-project/Specs").should be_true
end

When(/^I add an iOS Spec suite target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript scripts/ios_add_spec_suite.scpt`
  File.exist?("template-project/Specs").should be_true
end

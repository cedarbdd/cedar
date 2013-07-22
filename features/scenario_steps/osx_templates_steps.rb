Given(/^an Xcode OS X project$/) do
  `rm -rf template-project`
  `cp -pr osx-project-template template-project`
  $?.exitstatus.should == 0
  File.exist?("template-project").should be_true
end

When(/^I add an OS X Spec bundle target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript scripts/osx_add_spec_bundle.scpt`
  File.exist?("template-project/Specs").should be_true
end

When(/^I add an OS X Spec suite target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript scripts/osx_add_spec_suite.scpt`
  File.exist?("template-project/Specs").should be_true
end

Then(/^the `rake Spec` should work$/) do
  `cd template-project; cd Specs; rake Specs 2> /dev/null`
  $?.exitstatus.should == 0
end

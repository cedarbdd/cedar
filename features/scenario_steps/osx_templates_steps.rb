Given(/^an Xcode OS X project$/) do
  `rm -rf template-project`
  `cp -pr features/support/osx-project-template template-project`
  $?.exitstatus.should == 0
  File.exist?("template-project").should be_true
end

When(/^I add an OS X Spec bundle target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript features/support/scripts/osx_add_spec_bundle.scpt`
  File.exist?("template-project/Specs").should be_true
end

When(/^I add an OS X Spec suite target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript features/support/scripts/osx_add_spec_suite.scpt`
  File.exist?("template-project/Specs").should be_true
end

Then(/^the `rake Specs` should work$/) do
  output = `cd template-project; cd Specs; rake Specs 2> /dev/null`
  if $? != 0
    puts "!!! Spec target failed. Build output:"
    puts output
  end
  $?.exitstatus.should == 0
end

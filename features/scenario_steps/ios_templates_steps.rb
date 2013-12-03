Given(/^an Xcode iOS project$/) do
  `rm -rf template-project`
  `cp -pr features/support/ios-project-template template-project`
  $?.exitstatus.should == 0
  File.exist?("template-project").should be_true
end

When(/^I add an iOS Spec bundle target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript features/support/scripts/ios_add_spec_bundle.scpt`
  File.exist?("template-project/Specs").should be_true
end

When(/^I add an iOS Spec suite target$/) do
  `open -a Xcode template-project/template-project.xcodeproj`
  `osascript features/support/scripts/ios_add_spec_suite.scpt`
  File.exist?("template-project/Specs").should be_true
end

When(/^I reference AppDelegate in the test$/) do
  `cp features/support/templates/ExampleSpec.mm template-project/Specs`
end

Then(/^the `rake Specs` should work$/) do
  Dir.chdir('template-project/Specs') do
    output = `rake Specs 2> /dev/null`
    if $? != 0
      puts "!!! Spec target failed. Build output:"
      puts output
    end
    $?.exitstatus.should == 0
  end
end

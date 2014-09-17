When(/^I add an (iOS|OS X) (Spec Suite|Testing Bundle) target$/) do |os, target_type|
  xcode = File.absolute_path(File.join(`xcode-select -p`.strip, '../..'))
  `open -a #{xcode.inspect} template-project/template-project.xcodeproj`
  template_name = "#{os} Cedar #{target_type.downcase}"
  `osascript features/support/scripts/add_target.applescript #{os.downcase.inspect} #{template_name.inspect}`
  expect(File.exist?("template-project/Specs")).to be_truthy
end

Given(/^an Xcode (iOS|OS X) project$/) do |os|
  `rm -rf template-project`
  `cp -pr features/support/#{os.downcase.gsub(/\s+/, '')}-project-template template-project`
  expect($?.exitstatus).to eq(0)
  expect(File.exist?("template-project")).to be_truthy
end

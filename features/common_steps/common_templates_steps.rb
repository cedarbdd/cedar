setup_block = Proc.new do
  When(/^I add a failing test$/) do
    `cp features/support/templates/FailingSpec.mm template-project/Specs/ExampleSpec.mm`
  end

  When(/^I add an (iOS|OS X) Spec (suite|bundle) target$/) do |os, target_type|
    `open -a Xcode template-project/template-project.xcodeproj`
    `osascript features/support/scripts/#{os.downcase.gsub(/\s+/, '')}_add_spec_#{target_type.downcase.gsub(/\s+/, '')}.scpt`
    File.exist?("template-project/Specs").should be_true
  end

  Then(/^the `rake Specs` should work$/) do
    Dir.chdir('template-project/Specs') do
      output = `rake Specs 2> /dev/null`
      if $? != 0
        puts "!!! Spec target failed. Build output:"
        puts output
      end
      $?.exitstatus.should eq(0)
    end
  end

  Then(/^running the specs from the rake task should fail$/) do
    Dir.chdir('template-project/Specs') do
      `rake Specs 2> /dev/null`
      $?.exitstatus.should_not eq(0)
    end
  end

  Given(/^an Xcode (iOS|OS X) project$/) do |os|
    `rm -rf template-project`
    `cp -pr features/support/#{os.downcase.gsub(/\s+/, '')}-project-template template-project`
    $?.exitstatus.should == 0
    File.exist?("template-project").should be_true
  end
end

module CommonActions
  @initialized ||= false

  def self.init(setup_block)
    return if @initialized

    @initialized = true
    setup_block.call
  end
end

CommonActions.init(setup_block)


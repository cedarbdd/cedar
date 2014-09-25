Then(/^the `rake Specs` should work$/) do
  Dir.chdir('template-project/Specs') do
    output = `rake Specs 2> /dev/null`
    if $? != 0
      puts "!!! Spec target failed. Build output:"
      puts output
    end
    expect($?.exitstatus).to eq(0)
  end
end

Then(/^running the specs from the rake task should fail$/) do
  Dir.chdir('template-project/Specs') do
    `rake Specs 2> /dev/null`
    expect($?.exitstatus).to_not eq(0)
  end
end

Then(/^I should see an error telling me to install ios-sim since I do not have it installed/) do
  path_to_ios_sim = File.dirname(`which ios-sim`.chomp)
  path_without_ios_sim = (ENV['PATH'].split(':') - [path_to_ios_sim]).join(":")

  out = ""
  Dir.chdir('template-project/Specs') do
    out = `env PATH=#{path_without_ios_sim.inspect} rake Specs 2>&1`
  end

  if $? == 0
    puts '!!! Spec target succeeded but expected it to fail. See output:'
    puts out
  end

  expect($?.exitstatus).to_not eq(0)
  expect(out).to include("No ios-sim found. Use 'brew install ios-sim'.")
end

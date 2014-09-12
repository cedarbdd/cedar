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

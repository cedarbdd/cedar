# other, unrelated top level rake tasks

desc 'Trims whitespace and runs all the tests (suites and bundles)'
task :default => [:trim_whitespace, "suites:run", "suites:iosdynamicframeworkspecs:run", "testbundles:run"]

desc 'Runs static analyzer on suites and the ios framework'
task :analyze => [:clean, "suites:analyze", "suites:iosdynamicframeworkspecs:analyze"]

desc 'Cleans, trims whitespace, runs all tests and static analyzer'
task :full => [:clean, :default, :analyze]
task :ci => [:clean, "testbundles:run", "suites:run", "suites:iosdynamicframeworkspecs:run"]

desc "Trim whitespace"
task :trim_whitespace do
  Shell.run %Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[cmh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;']
end

desc "Clean all targets"
task :clean do
  Xcode.clean
end

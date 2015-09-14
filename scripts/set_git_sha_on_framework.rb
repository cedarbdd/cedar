#!/usr/bin/ruby

key = "CDRBuildVersionSHA"
ver = `git rev-parse HEAD`.strip
puts "Git commit SHA is #{ver}"
path = "#{ENV['BUILT_PRODUCTS_DIR']}/#{ENV['INFOPLIST_PATH']}"
puts "Updating #{path}"
`/usr/libexec/PlistBuddy -c "Add :#{key} string #{ver}" "#{path}"`

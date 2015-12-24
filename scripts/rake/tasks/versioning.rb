# tasks related to setting / bumping Cedar's version number
task :set_version, [:version_number] do |t, args|
  version = args[:version_number]
  File.write("Source/Headers/CDRVersion.h", "NSString *CDRVersion = @\"#{version}\";")
  podspec = File.read("Cedar.podspec")
  podspec.gsub!(/s\.version +=.+$/, "s.version = '#{version}'")
  podspec.gsub!(/:tag +=>.+$/, ":tag => 'v#{version}' }")
  File.write("Cedar.podspec", podspec)
  Shell.run "/usr/libexec/PlistBuddy -c \"Set :CFBundleShortVersionString #{version}\" Cedar-Info.plist"
end

task :tag_version, [:version_number] do |t, args|
  unless system("git diff --quiet ")
    raise Exception.new("Uncommitted changes. Aborting.")
  end
  unless system("git diff-index --quiet HEAD")
    raise Exception.new("Uncommitted changes. Aborting.")
  end
  Rake::Task['set_version'].invoke(args[:version_number])

  Shell.run "git commit -am 'Update version to #{args[:version_number]}'"

  previously_latest_version=`git for-each-ref refs/tags --sort=-refname --format="%(refname:short)"  | grep v\\?\\d\\+\\.\\d\\+\\.\\d\\+ | ruby -e 'puts STDIN.read.split("\n").sort { |a,b| a.gsub("v", "").split(".").map(&:to_i) <=> b.gsub("v", "").split(".").map(&:to_i) }.last'`
  template_file = Tempfile.new("tag-notes")
  template_file.write(system("git log --format=\"%h %s %b\" HEAD...#{previously_latest_version}"))
  template_file.close
  begin
    Shell.run "git tag v#{args[:version_number]} -F #{template_file.path.inspect}"
  ensure
    template_file.unlink
  end
end

# tasks related to setting / bumping Cedar's version number
task :set_version, [:version_number] do |t, args|
  unless args[:version_number]
    raise Exception.new("Must specify version number. Aborting.")
  end

  version = args[:version_number]
  File.write("Source/Headers/Public/CDRVersion.h", "NSString *CDRVersion = @\"#{version}\";")

  podspec = File.read("Cedar.podspec")
  podspec.gsub!(/s\.version +=.+$/, "s.version = '#{version}'")
  podspec.gsub!(/:tag +=>.+$/, ":tag => 'v#{version}' }")
  File.write("Cedar.podspec", podspec)

  Shell.run "/usr/libexec/PlistBuddy -c \"Set :CFBundleShortVersionString #{version}\" Cedar-Info.plist"
end

task :tag_version, [:version_number] do |t, args|
  unless args[:version_number]
    raise Exception.new("Must specify version number. Aborting.")
  end

  unless system("git diff --quiet ") && system("git diff-index --quiet HEAD")
    raise Exception.new("Uncommitted changes. Aborting.")
  end

  Rake::Task['set_version'].invoke(args[:version_number])

  Shell.run "git commit -am 'Update version to #{args[:version_number]}'"

  previously_latest_version = `git for-each-ref refs/tags --sort=-refname --format="%(refname:short)"  | grep v\\\\?\\\\d\\\\+\\\\.\\\\d\\\\+\\\\.\\\\d\\\\+`
    .chomp
    .split("\n")
    .each { |version| version.gsub("v", "").split(".").map(&:to_i) }
    .sort { |a, b| a <=> b }
    .last

  template_file = Tempfile.new("tag-notes")
  template_file.write(system("git log --format=\"%h %s %b\" HEAD...#{previously_latest_version}"))
  template_file.close
  begin
    Shell.run "git tag v#{args[:version_number]} -F #{template_file.path.inspect}"
  ensure
    template_file.unlink
  end
end

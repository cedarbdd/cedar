PROJECT_NAME = "Cedar"
CONFIGURATION = "Release"
SPECS_TARGET_NAME = "Specs"
UI_SPECS_TARGET_NAME = "iPhoneSpecs"
SDK_DIR = "/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator4.3.sdk"
BUILD_DIR = File.join(File.dirname(__FILE__), "build")

def build_dir(effective_platform_name)
  File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or raise "******** Build failed ********"
end

def output_file(target)
  output_dir = if ENV['IS_CI_BOX']
    ENV['CC_BUILD_ARTIFACTS']
  else
    Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
    BUILD_DIR
  end

  output_file = File.join(output_dir, "#{target}.output")
  puts "Output: #{output_file}"
  output_file
end

task :default => [:trim_whitespace, :specs, :uispecs]
task :cruise do
  Rake::Task[:clean].invoke
  Rake::Task[:build_all].invoke
  Rake::Task[:specs].invoke
  Rake::Task[:uispecs].invoke
end

task :trim_whitespace do
  system_or_exit(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[mh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;'])
end

task :clean do
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}], output_file("clean"))
end

task :build_specs do
puts "SYMROOT: #{ENV['SYMROOT']}"
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{SPECS_TARGET_NAME} -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], output_file("specs"))
end

task :build_uispecs do
  `osascript -e 'tell application "iPhone Simulator" to quit'`
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{UI_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} build], output_file("uispecs"))
end

task :build_all do
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -alltargets -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], output_file("build_all"))
end

task :specs => :build_specs do
  build_dir = build_dir("")
  ENV["DYLD_FRAMEWORK_PATH"] = build_dir
  ENV["CEDAR_REPORTER_CLASS"] = "CDRTeamCityReporter"
  system_or_exit(File.join(build_dir, SPECS_TARGET_NAME))
end

require 'tmpdir'
task :uispecs => :build_uispecs do
  ENV["DYLD_ROOT_PATH"] = SDK_DIR
  ENV["IPHONE_SIMULATOR_ROOT"] = SDK_DIR
  ENV["CFFIXED_USER_HOME"] = Dir.tmpdir
  ENV["CEDAR_HEADLESS_SPECS"] = "1"
  ENV["CEDAR_REPORTER_CLASS"] = "CDRColorizedReporter"

  system_or_exit(%Q[#{File.join(build_dir("-iphonesimulator"), "#{UI_SPECS_TARGET_NAME}.app", UI_SPECS_TARGET_NAME)} -RegisterForSystemEvents]);
end

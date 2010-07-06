PROJECT_NAME = "Cedar"
CONFIGURATION = "Release"
SPECS_TARGET_NAME = "Specs"
UI_SPECS_TARGET_NAME = "iPhoneSpecs"
SDK_DIR = "/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator4.0.sdk"

def build_dir(effective_platform_name)
  File.join(File.dirname(__FILE__), "build", CONFIGURATION + effective_platform_name)
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or raise "******** Build failed ********"
end

task :default => [:specs, :uispecs]
task :cruise => :default

task :build do
  stdout = File.join(ENV['CC_BUILD_ARTIFACTS'], "build.output") if (ENV['IS_CI_BOX'])
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean build], stdout)
end

task :specs => :build do
  build_dir = build_dir("")
  ENV["DYLD_FRAMEWORK_PATH"] = build_dir
  system_or_exit(File.join(build_dir, SPECS_TARGET_NAME))
end

require 'tmpdir'
task :uispecs => :build do
  ENV["DYLD_ROOT_PATH"] = SDK_DIR
  ENV["IPHONE_SIMULATOR_ROOT"] = SDK_DIR
  ENV["CFFIXED_USER_HOME"] = Dir.tmpdir
  ENV["CEDAR_HEADLESS_SPECS"] = "1"

  system_or_exit(%Q[#{File.join(build_dir("-iphonesimulator"), "#{UI_SPECS_TARGET_NAME}.app", UI_SPECS_TARGET_NAME)} -RegisterForSystemEvents]);
end

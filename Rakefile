PROJECT_NAME = "Cedar"
APP_NAME = "OCUnitApp"
CONFIGURATION = "Debug"

SPECS_TARGET_NAME = "Specs"
UI_SPECS_TARGET_NAME = "iPhoneSpecs"

OCUNIT_LOGIC_SPECS_TARGET_NAME = "OCUnitAppLogicTests"
OCUNIT_APPLICATION_SPECS_TARGET_NAME = "OCUnitAppTests"

SDK_VERSION = "4.3"
SDK_DIR = "/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{SDK_VERSION}.sdk"
BUILD_DIR = File.join(File.dirname(__FILE__), "build")


def build_dir(effective_platform_name)
  File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or raise "******** Build failed ********"
end

def with_env_vars(env_vars)
  old_values = {}
  env_vars.each do |key,new_value|
    old_values[key] = ENV[key]
    ENV[key] = new_value
  end

  yield

  env_vars.each_key do |key|
    ENV[key] = old_values[key]
  end
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

def kill_simulator
  system %Q[killall -m -KILL "gdb"]
  system %Q[killall -m -KILL "otest"]
  system %Q[killall -m -KILL "iPhone Simulator"]
end

task :default => [:trim_whitespace, "ocunit:logic", "ocunit:application", :specs, :focused_specs, :uispecs]
task :cruise => [:clean, :build_all, "ocunit:logic", "ocunit:application", :specs, :focused_specs, :uispecs]

task :trim_whitespace do
  system_or_exit %Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[cmh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;']
end

task :clean do
  system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean SYMROOT=#{BUILD_DIR}", output_file("clean")
end

task :build_specs do
  puts "SYMROOT: #{ENV['SYMROOT']}"
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{SPECS_TARGET_NAME} -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], output_file("specs"))
end

task :build_uispecs do
  kill_simulator
  system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{UI_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} build", output_file("uispecs")
end

task :build_all do
  kill_simulator
  system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -alltargets -configuration #{CONFIGURATION} build TEST_AFTER_BUILD=NO SYMROOT=#{BUILD_DIR}", output_file("build_all")
end

task :specs => :build_specs do
  build_dir = build_dir("")
  with_env_vars("DYLD_FRAMEWORK_PATH" => build_dir, "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
    system_or_exit(File.join(build_dir, SPECS_TARGET_NAME))
  end
end

task :focused_specs do
  # This target was made just for testing focused specs mode
  # and should not be created in applications that want to use Cedar.

  focused_specs_target_name = "FocusedSpecs"
  system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{focused_specs_target_name} -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}", output_file("focused_specs")

  build_dir = build_dir("")
  ENV["DYLD_FRAMEWORK_PATH"] = build_dir
  ENV["CEDAR_REPORTER_CLASS"] = "CDRColorizedReporter"
  system_or_exit File.join(build_dir, focused_specs_target_name)
end

require 'tmpdir'
task :uispecs => :build_uispecs do
  env_vars = {
    "DYLD_ROOT_PATH" => SDK_DIR,
    "IPHONE_SIMULATOR_ROOT" => SDK_DIR,
    "CFFIXED_USER_HOME" => Dir.tmpdir,
    "CEDAR_HEADLESS_SPECS" => "1",
    "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
  }

  with_env_vars(env_vars) do
    system_or_exit "#{File.join(build_dir("-iphonesimulator"), "#{UI_SPECS_TARGET_NAME}.app", UI_SPECS_TARGET_NAME)} -RegisterForSystemEvents";
  end
end


desc "Build and run OCUnit Logic and Application specs"
task :ocunit => ["ocunit:logic", "ocunit:application"]

namespace :ocunit do
  desc "Build and run OCUnit Logic specs (#{OCUNIT_LOGIC_SPECS_TARGET_NAME})"
  task :logic do
    with_env_vars("CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
      system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{OCUNIT_LOGIC_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} -arch x86_64 build SYMROOT=#{BUILD_DIR}"
    end
  end

  desc "Build and run OCUnit Application specs (#{OCUNIT_APPLICATION_SPECS_TARGET_NAME})"
  task :application do
    kill_simulator

    system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{OCUNIT_APPLICATION_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} -sdk iphonesimulator#{SDK_VERSION} build TEST_AFTER_BUILD=NO SYMROOT=#{BUILD_DIR}", output_file("ocunit_application_specs")

    env_vars = {
      "DYLD_ROOT_PATH" => SDK_DIR,
      "DYLD_INSERT_LIBRARIES" => "/Developer/Library/PrivateFrameworks/IDEBundleInjection.framework/IDEBundleInjection",
      "DYLD_FALLBACK_LIBRARY_PATH" => SDK_DIR,
      "XCInjectBundle" => "#{File.join(build_dir("-iphonesimulator"), "#{OCUNIT_APPLICATION_SPECS_TARGET_NAME}.octest")}",
      "XCInjectBundleInto" => "#{File.join(build_dir("-iphonesimulator"), "#{APP_NAME}.app/#{APP_NAME}")}",
      "IPHONE_SIMULATOR_ROOT" => SDK_DIR,
      "CFFIXED_USER_HOME" => Dir.tmpdir,
      "CEDAR_HEADLESS_SPECS" => "1",
      "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
    }

    with_env_vars(env_vars) do
      system_or_exit "#{File.join(build_dir("-iphonesimulator"), "#{APP_NAME}.app/#{APP_NAME}")} -RegisterForSystemEvents -SenTest All";
    end
  end
end

PROJECT_NAME = "Cedar"
APP_NAME = "OCUnitApp"
CONFIGURATION = "Release"

SPECS_TARGET_NAME = "Specs"
UI_SPECS_TARGET_NAME = "iOSSpecs"

OCUNIT_LOGIC_SPECS_TARGET_NAME = "OCUnitAppLogicTests"
OCUNIT_APPLICATION_SPECS_TARGET_NAME = "OCUnitAppTests"

CEDAR_FRAMEWORK_TARGET_NAME = "Cedar"
CEDAR_IOS_FRAMEWORK_TARGET_NAME = "Cedar-iOS"
SNIPPET_SENTINEL_VALUE = "isCedarSnippet"

XCODE_TEMPLATES_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/Templates"
XCODE_SNIPPETS_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/UserData/CodeSnippets"

SDK_VERSION = "6.1"
PROJECT_ROOT = File.dirname(__FILE__)
BUILD_DIR = File.join(PROJECT_ROOT, "build")
TEMPLATES_DIR = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "Templates")
SNIPPETS_DIR = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "CodeSnippets")
DIST_STAGING_DIR = "#{BUILD_DIR}/dist"

def sdk_dir
  "#{xcode_developer_dir}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{SDK_VERSION}.sdk"
end

# Xcode 4.3 stores its /Developer inside /Applications/Xcode.app, Xcode 4.2 stored it in /Developer
def xcode_developer_dir
  `xcode-select -print-path`.strip
end

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

task :default => [:trim_whitespace, :specs, :focused_specs, :uispecs, "ocunit:logic", "ocunit:application"]
task :cruise => [:clean, "ocunit:logic", "ocunit:application", :specs, :focused_specs, :uispecs]

desc "Trim whitespace"
task :trim_whitespace do
  system_or_exit %Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[cmh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;']
end

desc "Clean all targets"
task :clean do
  system_or_exit "rm -rf #{BUILD_DIR}/*", output_file("clean")
end

desc "Build specs"
task :build_specs do
  puts "SYMROOT: #{ENV['SYMROOT']}"
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{SPECS_TARGET_NAME} -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}], output_file("specs"))
end

desc "Build UI specs"
task :build_uispecs do
  kill_simulator
  system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{UI_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} -sdk iphonesimulator build", output_file("uispecs")
end

desc "Build Cedar and Cedar-iOS frameworks"
task :build_frameworks do
  system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{CEDAR_FRAMEWORK_TARGET_NAME} -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}", output_file("build_cedar")
  system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{CEDAR_IOS_FRAMEWORK_TARGET_NAME} -configuration #{CONFIGURATION} build SYMROOT=#{BUILD_DIR}", output_file("build_cedar_ios")
end

desc "Run specs"
task :specs => :build_specs do
  build_dir = build_dir("")
  with_env_vars("DYLD_FRAMEWORK_PATH" => build_dir, "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
    system_or_exit(File.join(build_dir, SPECS_TARGET_NAME))
  end
end

desc "Run focused specs"
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

desc "Run UI specs"
task :uispecs => :build_uispecs do
  env_vars = {
    "DYLD_ROOT_PATH" => sdk_dir,
    "IPHONE_SIMULATOR_ROOT" => sdk_dir,
    "CFFIXED_USER_HOME" => Dir.tmpdir,
    "CEDAR_HEADLESS_SPECS" => "1",
    "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
  }

  with_env_vars(env_vars) do
    system_or_exit "#{File.join(build_dir("-iphonesimulator"), "#{UI_SPECS_TARGET_NAME}.app", UI_SPECS_TARGET_NAME)} -RegisterForSystemEvents";
  end
end

desc "Build and run OCUnit logic and application specs"
task :ocunit => ["ocunit:logic", "ocunit:application"]

namespace :ocunit do
  desc "Build and run OCUnit logic specs (#{OCUNIT_LOGIC_SPECS_TARGET_NAME})"
  task :logic do
    with_env_vars("CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
      system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{OCUNIT_LOGIC_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} -arch x86_64 build TEST_AFTER_BUILD=YES SYMROOT=#{BUILD_DIR}"
    end
  end

  desc "Build and run OCUnit application specs (#{OCUNIT_APPLICATION_SPECS_TARGET_NAME})"
  task :application do
    kill_simulator

    system_or_exit "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{OCUNIT_APPLICATION_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} -sdk iphonesimulator#{SDK_VERSION} build TEST_AFTER_BUILD=NO SYMROOT=#{BUILD_DIR}", output_file("ocunit_application_specs")

    env_vars = {
      "DYLD_ROOT_PATH" => sdk_dir,
      "DYLD_INSERT_LIBRARIES" => "#{xcode_developer_dir}/Library/PrivateFrameworks/IDEBundleInjection.framework/IDEBundleInjection",
      "DYLD_FALLBACK_LIBRARY_PATH" => sdk_dir,
      "XCInjectBundle" => "#{File.join(build_dir("-iphonesimulator"), "#{OCUNIT_APPLICATION_SPECS_TARGET_NAME}.octest")}",
      "XCInjectBundleInto" => "#{File.join(build_dir("-iphonesimulator"), "#{APP_NAME}.app/#{APP_NAME}")}",
      "IPHONE_SIMULATOR_ROOT" => sdk_dir,
      "CFFIXED_USER_HOME" => Dir.tmpdir,
      "CEDAR_HEADLESS_SPECS" => "1",
      "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
    }

    with_env_vars(env_vars) do
      system_or_exit "#{File.join(build_dir("-iphonesimulator"), "#{APP_NAME}.app/#{APP_NAME}")} -RegisterForSystemEvents -SenTest All";
    end
  end
end

desc "Remove code snippets and templates"
task :uninstall do
  puts "\nRemoving old templates...\n"
  system_or_exit "rm -rf \"#{XCODE_TEMPLATES_DIR}/File Templates/Cedar\""
  system_or_exit "rm -rf \"#{XCODE_TEMPLATES_DIR}/Project Templates/Cedar\""
  system_or_exit "grep -Rl #{SNIPPET_SENTINEL_VALUE} #{XCODE_SNIPPETS_DIR} | xargs -I{} rm -f \"{}\""
end

desc "Build a distribution of the templates and code snippets"
task :dist => ["dist:prepare", "dist:package"]

namespace :dist do
  task :prepare => :build_frameworks do
    Dir.mkdir(DIST_STAGING_DIR) unless File.exists?(DIST_STAGING_DIR)
    cedar_project_templates_dir = %{#{DIST_STAGING_DIR}/Library/Developer/Xcode/Templates/Project Templates/Cedar}

    system_or_exit %{rm -rf "#{DIST_STAGING_DIR}"/*}
    system_or_exit %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode"}
    system_or_exit %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData"}

    system_or_exit %{cp "#{PROJECT_ROOT}/README.markdown" "#{DIST_STAGING_DIR}/README-Cedar.markdown"}
    system_or_exit %{cp "#{PROJECT_ROOT}/MIT.LICENSE" "#{DIST_STAGING_DIR}/LICENSE-Cedar.txt"}

    system_or_exit %{cp -R "#{TEMPLATES_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/"}
    system_or_exit %{cp -R "#{SNIPPETS_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData/"}


    system_or_exit %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}-iphoneuniversal/#{CEDAR_IOS_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/iOS Cedar Spec Suite.xctemplate/"}
    system_or_exit %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}-iphoneuniversal/#{CEDAR_IOS_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/iOS Cedar Testing Bundle.xctemplate/"}

    system_or_exit %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}/#{CEDAR_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/OSX Cedar Spec Suite.xctemplate/"}
    system_or_exit %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}/#{CEDAR_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/OSX Cedar Testing Bundle.xctemplate/"}
  end

  task :package do
    package_file_path = "#{BUILD_DIR}/Cedar-#{`git rev-parse --short HEAD`.strip}.tar.gz"
    system_or_exit %{cd #{DIST_STAGING_DIR} ; tar --exclude .DS_Store -zcf "#{package_file_path}" * ; cd -}
    puts "\n*** Built tarball is in #{package_file_path} ***\n"
  end
end

desc "Build frameworks and install templates and code snippets"
task :install => [ :clean, :uninstall, "dist:prepare" ] do
  puts "\nInstalling templates...\n"
  system_or_exit %{ditto "#{DIST_STAGING_DIR}/Library" ~/Library}
end


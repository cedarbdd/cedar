PROJECT_FILE = "Cedar.xcodeproj"
CONFIGURATION = "Release"

IOS_SPEC_SUITE_APP_NAME = "Cedar iOS Specs"
SPECS_OSX_TARGET_NAME = "Cedar OS X Specs"
SPECS_IOS_TARGET_NAME = "Cedar iOS Specs"
FOCUSED_SPECS_OSX_TARGET_NAME = "Cedar OS X FocusedSpecs"

OCUNIT_TEST_BUNDLE_SCHEME_NAME = "Cedar iOS SenTestingKit Tests"
XCUNIT_TEST_BUNDLE_SCHEME_NAME = "Cedar iOS XCTest Tests"

OSX_FAILING_SPEC_SCHEME_NAME = "Cedar OS X Failing Test Bundle"

CEDAR_OSX_FRAMEWORK_TARGET_NAME = "Cedar OS X"
CEDAR_IOS_FRAMEWORK_TARGET_NAME = "Cedar iOS"

TEMPLATE_IDENTIFIER_PREFIX = "com.pivotallabs.cedar."
TEMPLATE_SENTINEL_KEY = "isCedarTemplate"
SNIPPET_SENTINEL_VALUE = "isCedarSnippet"

XCODE_TEMPLATES_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/Templates"
XCODE_SNIPPETS_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/UserData/CodeSnippets"
APPCODE_SNIPPETS_DIR = "#{ENV['HOME']}/Library/Preferences/appCode31/templates"
XCODE_PLUGINS_DIR = "#{ENV['HOME']}/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"

LATEST_SDK_VERSION = `xcodebuild -showsdks | grep iphonesimulator | cut -d ' ' -f 4`.chomp.split("\n").last
SDK_VERSION = ENV["CEDAR_SDK_VERSION"] || LATEST_SDK_VERSION
SDK_RUNTIME_VERSION = ENV["CEDAR_SDK_RUNTIME_VERSION"] || LATEST_SDK_VERSION

PROJECT_ROOT = File.dirname(__FILE__)
BUILD_DIR = File.join(PROJECT_ROOT, "build")
DERIVED_DATA_DIR = File.join(PROJECT_ROOT, "derivedData")
TEMPLATES_DIR = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "Templates")
SNIPPETS_DIR = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "CodeSnippets")
APPCODE_SNIPPETS_FILENAME = "Cedar.xml"
APPCODE_SNIPPETS_FILE = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "AppCodeSnippets", APPCODE_SNIPPETS_FILENAME)
DIST_STAGING_DIR = "#{BUILD_DIR}/dist"
PLUGIN_DIR = File.join(PROJECT_ROOT, "CedarPlugin.xcplugin")
PLISTBUDDY = "/usr/libexec/PlistBuddy"
SIMULATOR_TIMEOUT = 30

require 'tmpdir'
require 'tempfile'

GREEN = "\033[32m"
RED = "\033[31m"
CLEAR = "\033[0m"

class Shell
  def self.run(cmd, opts={})
    logfile = opts.fetch(:log_to, nil)
    print = opts.fetch(:tee, false)

    puts "#{GREEN}==>#{CLEAR} #{cmd}"
    original_cmd = cmd
    if logfile
      logfile = output_file(logfile)
      if print
        tee_logfile = "| tee #{logfile}"
      else
        tee_logfile = "> #{logfile}"
      end
      cmd = "(#{cmd}) 2>&1 #{tee_logfile}; test ${PIPESTATUS[0]} -eq 0"
    end
    system(cmd) or begin
      cmd_msg = "[#{RED}Failed#{CLEAR}] Command: #{original_cmd}"
      if logfile
        raise Exception.new <<EOF
#{File.read(logfile)}
#{cmd_msg}
[#{RED}Failed#{CLEAR}] Also logged to: #{logfile}

EOF
      else
        raise Exception.new <<EOF
#{cmd_msg}

EOF
      end
    end
  end

  def self.with_env(env_vars)
    old_values = {}
    env_vars.each do |key, new_value|
      old_values[key] = ENV[key]
      ENV[key] = new_value
    end

    env_vars.each { |key, new_value| puts "#{key}=#{new_value}" }
    begin
      yield
    ensure
      env_vars.each_key do |key|
        ENV[key] = old_values[key]
      end
    end
  end

  def self.fold(name)
    name = name.gsub(/[^A-Za-z0-9.-]/, '')
    puts "travis_fold:start:#{name}" if ENV['TRAVIS']
    result = yield(self)
    puts "travis_fold:end:#{name}" if ENV['TRAVIS']
    result
  end

  def self.output_file(target)
    output_dir = if ENV['IS_CI_BOX']
                   ENV['CC_BUILD_ARTIFACTS']
                 else
                   Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
                   BUILD_DIR
                 end

    File.join(output_dir, target)
  end
end

class Xcode
  def self.developer_dir
    `xcode-select -print-path`.strip
  end

  def self.build_dir(effective_platform_name = "")
    File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
  end

  def self.sdk_dir_for_version(version)
    path = %x[ xcrun -sdk "iphonesimulator#{version}" -show-sdk-path 2>/dev/null ].strip
    raise("iPhone Simulator SDK version #{version} not installed") if $?.exitstatus != 0
    path
  end

  def self.destination_for_ios_sdk(version)
    "OS=#{version},name=iPhone 5s"
  end

  def self.clean
    Shell.run "rm -rf '#{BUILD_DIR}'; true", :log_to => "clean.build.log"
    Shell.run "rm -rf '#{DERIVED_DATA_DIR}'; true", :log_to => "clean.derivedData.log"
  end

  def self.build(options = nil)
    raise "Options requires :target or :scheme" if !options[:target] and !options[:scheme]

    logfile = options.fetch(:logfile)
    args = options[:args] || ""

    args += " -target #{options[:target].inspect}" if options[:target]
    args += " -sdk #{options[:sdk].inspect}" if options[:sdk]
    args += " -scheme #{options[:scheme].inspect}" if options[:scheme]

    Shell.fold "build.#{options[:scheme] || options[:target]}" do
      Shell.run %Q(xcodebuild -project #{PROJECT_FILE} -configuration #{CONFIGURATION} SYMROOT=#{BUILD_DIR.inspect} clean build #{args}), :log_to => logfile
    end
  end

  def self.test(options = nil)
    raise "Options requires :target or :scheme" if !options[:target] and !options[:scheme]

    logfile = options.fetch(:logfile)
    args = options[:args] || ""

    args += " -target #{options[:target].inspect}" if options[:target]
    args += " -sdk #{options[:sdk].inspect}" if options[:sdk]
    args += " -scheme #{options[:scheme].inspect}" if options[:scheme]

    Shell.fold "test.#{options[:scheme] || options[:target]}" do
      Shell.run %Q(xcodebuild -project #{PROJECT_FILE} -configuration #{CONFIGURATION} -derivedDataPath #{DERIVED_DATA_DIR.inspect} SYMROOT=#{BUILD_DIR.inspect} clean build test #{args}), log_to: logfile
    end
  end

  def self.analyze(options = nil)
    raise "Options requires :target or :scheme" if !options[:target] and !options[:scheme]
    logfile = options.fetch(:logfile)
    args = options[:args] || ""

    args += " -target #{options[:target].inspect}" if options[:target]
    args += " -sdk #{options[:sdk].inspect}" if options[:sdk]
    args += " -scheme #{options[:scheme].inspect}" if options[:scheme]

    Shell.fold "analyze.#{options[:scheme] || options[:target]}" do
      Shell.run %Q[xcodebuild -project #{PROJECT_FILE} -configuration #{CONFIGURATION} clean analyze #{args} SYMROOT='#{BUILD_DIR}'], log_to: logfile
    end
  end

  def self.sed_project(search, replace)
    pbxproj = "#{PROJECT_FILE}/project.pbxproj"
    contents = File.read(pbxproj)
    File.write(pbxproj, contents.gsub(search, replace))
  end
end

def remove_templates_from_directory(templates_directory)
  return unless File.directory?(templates_directory)

  Dir.foreach(templates_directory) do |template|
    next if template == '.' or template == '..'

    template_plist = "#{templates_directory}/#{template}/TemplateInfo.plist"
    next unless File.exists?(template_plist)

    if `#{PLISTBUDDY} -c "Print :Identifier" "#{template_plist}"`.start_with?(TEMPLATE_IDENTIFIER_PREFIX) or
      `#{PLISTBUDDY} -c "Print :#{TEMPLATE_SENTINEL_KEY}" "#{template_plist}"`.start_with?("true")
      Shell.run "rm -rf \"#{templates_directory}/#{template}\""
    end
  end
end

class Simulator
  def self.launch(app_dir, app_name, logfile)
    Shell.with_env({"CEDAR_REPORTER_CLASS" => "CDRColorizedReporter"}) do
      kill # ensure simulator is not currently running
      app_path = File.join(app_dir, "#{app_name}.app")
      # Simulator in iOS 8 SDK seems to hang on first launch. xcodebuild reties, but ios-sim seems to not.
      max_retries = 3
      tries = 0
      while tries < max_retries
        tries += 1
        Shell.run "ios-sim launch #{app_path.inspect} --devicetypeid \"com.apple.CoreSimulator.SimDeviceType.iPhone-5s, #{SDK_RUNTIME_VERSION}\" --setenv \"DYLD_FRAMEWORK_PATH=#{app_dir}\" --stdout \"build/ios_specs.spec.log\""
        if system "grep -q 'Running With Random Seed' build/ios_specs.spec.log"
          Shell.run "grep -q ', 0 failures' build/ios_specs.spec.log", log_to: logfile
          break
        else
          puts "[#{RED}FAILED#{CLEAR}] Detected ios-sim failing to bootstrap simulator. Retrying (#{tries} of #{max_retries})."
        end
      end
     if tries >= max_retries
       raise Exception.new('Failed to run ios-sim (more than #{max_retries}). Failing.')
     end
    end
  end

  def self.launch_bundle(app_dir, app_name, test_bundle, logfile)
    env_vars = {
      "DYLD_INSERT_LIBRARIES" => "#{Xcode.developer_dir}/Library/PrivateFrameworks/IDEBundleInjection.framework/IDEBundleInjection",
      "XCInjectBundle" => test_bundle,
      "XCInjectBundleInto" => "#{File.join(Xcode.build_dir("-iphonesimulator"), "#{IOS_SPEC_SUITE_APP_NAME}.app/#{IOS_SPEC_SUITE_APP_NAME}")}",
    }
    Shell.with_env(env_vars) do
      launch(app_dir, app_name, logfile)
    end
  end

  def self.kill
    system %Q[killall "iOS Simulator"]
    system %Q[killall -m -KILL "gdb" 2>&1 > /dev/null]
    system %Q[killall -m -KILL "otest" 2>&1 > /dev/null]
    system %Q[killall -m -KILL "iPhone Simulator" 2>&1 > /dev/null]
  end
end

desc 'Trims whitespace and runs all the tests (suites and bundles)'
task :default => [:trim_whitespace, "suites:run", "testbundles:run"]

desc 'Runs static analyzer on suites and the ios framework'
task :analyze => [:clean, "suites:analyze"]

desc 'Cleans, trims whitespace, runs all tests and static analyzer'
task :full => [:clean, :default, :analyze]
task :ci => [:clean, "testbundles:run", "suites:run"]

desc "Trim whitespace"
task :trim_whitespace do
  Shell.run %Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[cmh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;']
end

desc "Clean all targets"
task :clean do
  Xcode.clean
end

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

desc 'Analyzes and runs specs, ios_specs, and focused spec suites'
task suites: ['suites:analyze', 'suites:run']
namespace :suites do
  desc 'Analyzes osx_specs, ios_specs, and focused spec suites'
  task analyze: ['osx_specs:analyze', 'ios_specs:analyze', 'focused_specs:analyze']
  desc 'Runs osx_specs, ios_specs, and focused spec suites'
  task run: ['osx_specs:run', 'ios_specs:run', 'focused_specs:run']

  desc "Analyzes and runs the Specs test suite"
  task osx_specs: [:analyze, :run]
  namespace :osx_specs do
    desc "Analyzes osx specs"
    task :analyze do
      Xcode.analyze(target: SPECS_OSX_TARGET_NAME, logfile: "osx_specs.analyze.log")
    end

    desc "Build osx specs"
    task build: 'frameworks:osx:build' do
      Xcode.build(target: SPECS_OSX_TARGET_NAME, logfile: "osx_specs.build.log")
    end

    desc "Run osx specs"
    task run: :build do
      build_dir = Xcode.build_dir("")
      Shell.with_env("DYLD_FRAMEWORK_PATH" => build_dir, "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
        Shell.run(File.join(build_dir, SPECS_OSX_TARGET_NAME).inspect, :log_to => "osx_specs.run.log")
      end
    end
  end

  desc "Analyzes and runs the ios_specs test suite"
  task ios_specs: ['ios_specs:analyze', 'ios_specs:run']
  namespace :ios_specs do

    desc "Analyzes UI specs"
    task :analyze do
      Xcode.analyze(target: SPECS_IOS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386', logfile: "ios_specs.analyze.log")
    end

    desc "Build UI specs"
    task :build do
      Xcode.build(target: SPECS_IOS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386', logfile: "ios_specs.build.log")
    end

    desc "Run UI specs"
    task run: :build do
      Simulator.kill
      env_vars = {
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      }

      Shell.with_env(env_vars) do
        Simulator.launch(Xcode.build_dir("-iphonesimulator"), SPECS_IOS_TARGET_NAME, "ios_specs.run.log")
      end
    end
  end

  desc "Runs analyzer and focused test suite"
  task focused_specs: ['focused_specs:analyze', 'focused_specs:run']
  namespace :focused_specs do
    # This target was made just for testing focused specs mode
    # and should not be created in applications that want to use Cedar.

    desc "Analyzes Cedar's focused specs tests suite"
    task :analyze do
      Xcode.analyze(target: FOCUSED_SPECS_OSX_TARGET_NAME, logfile: "focused_specs.analyze.log")
    end

    desc "Build Cedar's focused specs tests suite"
    task :build do
      Xcode.build(target: FOCUSED_SPECS_OSX_TARGET_NAME, logfile: "focused_specs.build.log")
    end

    desc "Run Cedar's specs for verifying focused test behavior"
    task run: :build do
      env_vars = {
        "DYLD_FRAMEWORK_PATH" => Xcode.build_dir,
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      }
      Shell.with_env(env_vars) do
        Shell.run(File.join(Xcode.build_dir, FOCUSED_SPECS_OSX_TARGET_NAME).inspect, :log_to => "focused_specs.run.log")
      end
    end
  end
end

namespace :frameworks do
  desc "Build Cedar and Cedar-iOS frameworks, and verify built Cedar-iOS.framework"
  task build: ['frameworks:ios:build', 'frameworks:osx:build']

  namespace :osx do
    desc "Builds and installs the Cedar OS X framework"
    task :build do
      Xcode.build(target: CEDAR_OSX_FRAMEWORK_TARGET_NAME, logfile: "frameworks.osx.build.log", args: "install DSTROOT=/")
    end
  end

  namespace :ios do
    desc "Builds the Cedar iOS framework"
    task :build do
      Xcode.build(target: CEDAR_IOS_FRAMEWORK_TARGET_NAME, logfile: "frameworks.ios.build.log")
    end
  end
end

namespace :testbundles do
  desc "Runs all test bundle test suites (xcunit, ocunit:application)"
  task run: ['testbundles:xcunit', 'testbundles:ocunit', 'testbundles:failing_test_bundle']

  desc "Converts the test bundle identifier to ones Xcode 5- recognizes (Xcode 6 postfixes the original bundler identifier)"
  task :convert_to_xcode5 do
    Xcode.sed_project(%r{com\.apple\.product-type\.bundle\.(oc)?unit-test}, 'com.apple.product-type.bundle')
  end

  desc "Build and run XCUnit specs (#{XCUNIT_TEST_BUNDLE_SCHEME_NAME})"
  task xcunit: :convert_to_xcode5 do
    Simulator.kill

    Xcode.test(
      scheme: XCUNIT_TEST_BUNDLE_SCHEME_NAME,
      sdk: "iphonesimulator#{SDK_VERSION}",
      args: "ARCHS=x86_64 -destination '#{Xcode.destination_for_ios_sdk(SDK_RUNTIME_VERSION)}' -destination-timeout #{SIMULATOR_TIMEOUT}",
      logfile: "xcunit.run.log",
    )
  end

  desc "Build and run OCUnit logic and application specs"
  task ocunit: ["ocunit:application"]

  namespace :ocunit do
    desc "Build and run OCUnit application specs (#{OCUNIT_TEST_BUNDLE_SCHEME_NAME})"
    task application: :convert_to_xcode5 do
      Simulator.kill

      Xcode.test(
        scheme: OCUNIT_TEST_BUNDLE_SCHEME_NAME,
        sdk: "iphonesimulator#{SDK_VERSION}",
        args: "ARCHS=i386 -destination '#{Xcode.destination_for_ios_sdk(SDK_RUNTIME_VERSION)}' -destination-timeout #{SIMULATOR_TIMEOUT}",
        logfile: "ocunit-application-specs.log",
      )
    end
  end
  desc 'A target that does not have XCTest or SenTestingKit linked should alert the user'
  task :failing_test_bundle do
    the_exception = nil

    begin
      Xcode.test(
        scheme: OSX_FAILING_SPEC_SCHEME_NAME,
        logfile: "failing.osx.specs.log",
        args: "2>&1",
      )
    rescue Exception => e
      the_exception = e
    end

    unless the_exception && the_exception.to_s =~ /CedarNoTestFrameworkAvailable/
        raise the_exception
    end
  end
end

desc 'Runs integration tests of the templates'
task :test_templates do
  terminal_id = `/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' /Applications/Utilities/Terminal.app/Contents/Info.plist`.strip
  Shell.run %{sudo sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' "INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','#{terminal_id}',0,1,1,NULL);"}
  Shell.run "sudo touch /private/var/db/.AccessibilityAPIEnabled"
  Shell.run "cucumber"
end

desc "Remove code snippets and templates"
task :uninstall do
  puts "\nRemoving old templates...\n"
  remove_templates_from_directory("#{XCODE_TEMPLATES_DIR}/File Templates/Cedar")
  remove_templates_from_directory("#{XCODE_TEMPLATES_DIR}/Project Templates/Cedar")
  Shell.run "rm -f \"#{APPCODE_SNIPPETS_DIR}/#{APPCODE_SNIPPETS_FILENAME}\""
  Shell.run "grep -Rl #{SNIPPET_SENTINEL_VALUE} #{XCODE_SNIPPETS_DIR} | xargs -I{} rm -f \"{}\""
end

desc "Build a distribution of the templates and code snippets"
task :dist => ["dist:prepare", "dist:package"]

namespace :dist do
  task :prepare => 'frameworks:build' do
    Dir.mkdir(DIST_STAGING_DIR) unless File.exists?(DIST_STAGING_DIR)
    cedar_project_templates_dir = %{#{DIST_STAGING_DIR}/Library/Developer/Xcode/Templates/Project Templates/Cedar}

    Shell.run %{rm -rf "#{DIST_STAGING_DIR}"/*}
    Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode"}
    Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData"}
    Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Preferences/appCode20/templates"}

    Shell.run %{cp "#{PROJECT_ROOT}/README.markdown" "#{DIST_STAGING_DIR}/README-Cedar.markdown"}
    Shell.run %{cp "#{PROJECT_ROOT}/MIT.LICENSE.txt" "#{DIST_STAGING_DIR}/LICENSE-Cedar.txt"}

    Shell.run %{cp -R "#{TEMPLATES_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/"}
    Shell.run %{cp -R "#{SNIPPETS_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData/"}
    Shell.run %{cp "#{APPCODE_SNIPPETS_FILE}" "#{DIST_STAGING_DIR}/Library/Preferences/appCode20/templates/#{APPCODE_SNIPPETS_FILENAME}"}


    Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}-iphoneuniversal/#{CEDAR_IOS_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/iOS Cedar Spec Suite.xctemplate/"}
    Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}-iphoneuniversal/#{CEDAR_IOS_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/iOS Cedar Testing Bundle.xctemplate/"}

    Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}/#{CEDAR_OSX_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/OS X Cedar Spec Suite.xctemplate/#{CEDAR_OSX_FRAMEWORK_TARGET_NAME}.framework/"}
    Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}/#{CEDAR_OSX_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/OS X Cedar Testing Bundle.xctemplate/#{CEDAR_OSX_FRAMEWORK_TARGET_NAME}.framework/"}
  end

  task :package do
    package_file_path = "#{BUILD_DIR}/Cedar-#{`git rev-parse --short HEAD`.strip}.tar.gz"
    Shell.run %{cd #{DIST_STAGING_DIR} ; tar --exclude .DS_Store -zcf "#{package_file_path}" * ; cd -}
    puts "\n*** Built tarball is in #{package_file_path} ***\n"
  end
end

desc "Build frameworks and install templates and code snippets"
task :install => [:clean, :uninstall, "dist:prepare", :install_plugin] do
  puts "\nInstalling templates...\n"
  Shell.run %{rsync -vcrlK "#{DIST_STAGING_DIR}/Library/" ~/Library}
end

task :reinstall => [:uninstall, :install_plugin] do
  Dir.mkdir(DIST_STAGING_DIR) unless File.exists?(DIST_STAGING_DIR)
  cedar_project_templates_dir = %{#{DIST_STAGING_DIR}/Library/Developer/Xcode/Templates/Project Templates/Cedar}

  Shell.run %{rm -rf "#{DIST_STAGING_DIR}"/*}
  Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode"}
  Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData"}
  Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Preferences/appCode20/templates"}

  Shell.run %{cp "#{PROJECT_ROOT}/README.markdown" "#{DIST_STAGING_DIR}/README-Cedar.markdown"}
  Shell.run %{cp "#{PROJECT_ROOT}/MIT.LICENSE.txt" "#{DIST_STAGING_DIR}/LICENSE-Cedar.txt"}

  Shell.run %{cp -R "#{TEMPLATES_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/"}
  Shell.run %{cp -R "#{SNIPPETS_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData/"}
  Shell.run %{cp "#{APPCODE_SNIPPETS_FILE}" "#{DIST_STAGING_DIR}/Library/Preferences/appCode20/templates/#{APPCODE_SNIPPETS_FILENAME}"}


  Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}-iphoneuniversal/#{CEDAR_IOS_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/iOS Cedar Spec Suite.xctemplate/"}
  Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}-iphoneuniversal/#{CEDAR_IOS_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/iOS Cedar Testing Bundle.xctemplate/"}

  Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}/#{CEDAR_OSX_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/OS X Cedar Spec Suite.xctemplate/#{CEDAR_OSX_FRAMEWORK_TARGET_NAME}.framework/"}
  Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}/#{CEDAR_OSX_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/OS X Cedar Testing Bundle.xctemplate/#{CEDAR_OSX_FRAMEWORK_TARGET_NAME}.framework/"}
  Shell.run %{rsync -vcrlK "#{DIST_STAGING_DIR}/Library/" ~/Library}
end

desc "Install the CedarPlugin into Xcode (restart required)"
task :install_plugin do
  puts "\nInstalling the CedarPlugin...\n"
  Shell.run %{mkdir -p "#{XCODE_PLUGINS_DIR}" && cp -rv "#{PLUGIN_DIR}" "#{XCODE_PLUGINS_DIR}"}
end

desc "Build the frameworks and upgrade the target"
task :upgrade, [:path_to_framework] do |task, args|
  usage_string = 'Usage: rake upgrade["/path/to/Cedar.framework"]'
  path_to_framework = args.path_to_framework
  raise "*** Missing path to the framework to be upgraded. ***\n#{usage_string}" unless path_to_framework

  path_to_framework = File.expand_path(path_to_framework)
  if File.directory?(path_to_framework)
    framework_folder = args.path_to_framework.split("/").last
    case framework_folder
    when "Cedar-iOS.framework"
      cedar_name = "Cedar-iOS"
      cedar_path = "#{CONFIGURATION}-iphoneuniversal"
    when "Cedar.framework"
      cedar_name = "Cedar"
      cedar_path = "#{CONFIGURATION}"
    end
  end

  raise "*** No framework found. ***\n#{usage_string}" unless cedar_path

  Rake::Task['frameworks:build'].invoke

  puts "\nUpgrading #{cedar_name} framework...\n"

  Shell.run %{rsync -vkcr --delete "#{BUILD_DIR}/#{cedar_path}/#{cedar_name}.framework/" "#{args.path_to_framework}/"}
end

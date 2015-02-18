PROJECT_NAME = "Cedar"
APP_NAME = "Cedar OS X Specs"
APP_IOS_NAME = "Cedar iOS Specs"
CONFIGURATION = "Release"

SPECS_TARGET_NAME = "Cedar OS X Specs"
UI_SPECS_TARGET_NAME = "Cedar iOS Specs"
FOCUSED_SPECS_TARGET_NAME = "Cedar OS X FocusedSpecs"
IOS_FRAMEWORK_SPECS_TARGET_NAME = "Cedar iOS FrameworkSpecs"

OCUNIT_APPLICATION_SPECS_SCHEME_NAME = "Cedar iOS SenTestingKit Tests"
XCUNIT_APPLICATION_SPECS_SCHEME_NAME = "Cedar iOS XCTest Tests"

OSX_FAILING_SPEC_SCHEME_NAME = "Cedar OS X Failing Test Bundle"

CEDAR_FRAMEWORK_TARGET_NAME = "Cedar"
CEDAR_IOS_FRAMEWORK_TARGET_NAME = "Cedar-iOS"
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

require 'tmpdir'
require 'tempfile'

class Shell
  def self.run(cmd, logfile = nil)
    green = "\033[32m"
    red = "\033[31m"
    clear = "\033[0m"
    puts "#{green}==>#{clear} #{cmd}"
    original_cmd = cmd
    if logfile
      logfile = output_file(logfile)
      cmd = "export > #{logfile}; (#{cmd}) 2>&1 >> #{logfile}; test ${PIPESTATUS[0]} -eq 0"
    end
    system(cmd) or begin
      cmd_msg = "[#{red}Failed#{clear}] Command: #{original_cmd}"
      if logfile
        raise Exception.new <<EOF
#{File.read(logfile)}
#{cmd_msg}
[#{red}Failed#{clear}] Also logged to: #{logfile}

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
    Shell.run "rm -rf '#{BUILD_DIR}'; true", "clean.build.log"
    Shell.run "rm -rf '#{DERIVED_DATA_DIR}'; true", "clean.derivedData.log"
  end

  def self.build(options = nil)
    raise "Options requires :target or :scheme" if !options[:target] and !options[:scheme]

    logfile = options.fetch(:logfile)
    args = options[:args] || ""

    args += " -target #{options[:target].inspect}" if options[:target]
    args += " -sdk #{options[:sdk].inspect}" if options[:sdk]
    args += " -scheme #{options[:scheme].inspect}" if options[:scheme]

    Shell.fold "build.#{options[:scheme] || options[:target]}" do
      Shell.run(%Q(xcodebuild -project #{PROJECT_NAME}.xcodeproj -configuration #{CONFIGURATION} SYMROOT=#{BUILD_DIR.inspect} clean build #{args}), logfile)
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
      Shell.run(%Q(xcodebuild -project #{PROJECT_NAME}.xcodeproj -configuration #{CONFIGURATION} -derivedDataPath #{DERIVED_DATA_DIR.inspect} SYMROOT=#{BUILD_DIR.inspect} clean build test #{args}), logfile)
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
      Shell.run(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -configuration #{CONFIGURATION} clean analyze #{args} SYMROOT='#{BUILD_DIR}'], logfile)
    end
  end

  def self.sed_project(search, replace)
    pbxproj = "#{PROJECT_NAME}.xcodeproj/project.pbxproj"
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
    retry_count = 0
    Shell.with_env({"CEDAR_REPORTER_CLASS" => "CDRColorizedReporter"}) do
      begin
        kill # ensure simulator is not currently running
        Shell.run "ios-sim launch #{File.join(app_dir, "#{app_name}.app").inspect} --devicetypeid \"com.apple.CoreSimulator.SimDeviceType.iPhone-5s, #{SDK_RUNTIME_VERSION}\" --verbose --stdout build/uispecs.spec.log"
        Shell.run "grep -q ', 0 failures' build/uispecs.spec.log", logfile
      rescue
        retry_count += 1

        if retry_count == 3
          raise
        else
          retry
        end
      end
      end
  end

  def self.launch_bundle(app_dir, app_name, test_bundle, logfile)
    env_vars = {
      "DYLD_INSERT_LIBRARIES" => "#{Xcode.developer_dir}/Library/PrivateFrameworks/IDEBundleInjection.framework/IDEBundleInjection",
      "XCInjectBundle" => test_bundle,
      "XCInjectBundleInto" => "#{File.join(Xcode.build_dir("-iphonesimulator"), "#{APP_IOS_NAME}.app/#{APP_IOS_NAME}")}",
    }
    Shell.with_env(env_vars) do
      launch(app_dir, app_name, logfile)
    end
  end

  def self.kill
    system %Q[killall -m -KILL "gdb" 2>&1 > /dev/null]
    system %Q[killall -m -KILL "otest" 2>&1 > /dev/null]
    system %Q[killall -m -KILL "iPhone Simulator" 2>&1 > /dev/null]
  end
end

desc 'Trims whitespace and runs all the tests (suites and bundles)'
task :default => [:trim_whitespace, "suites:run", "suites:iosframeworkspecs:run", "testbundles:run"]

desc 'Runs static analyzer on suites and the ios framework'
task :analyze => [:clean, "suites:analyze", "suites:iosframeworkspecs:analyze"]

desc 'Cleans, trims whitespace, runs all tests and static analyzer'
task :full => [:clean, :default, :analyze]
task :ci => [:clean, "testbundles:run", "suites:run", "suites:iosframeworkspecs:run"]

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

desc 'Analyzes and runs specs, uispecs, and focused spec suites'
task suites: ['suites:analyze', 'suites:run']
namespace :suites do
  desc 'Analyzes specs, uispecs, and focused spec suites'
  task analyze: ['specs:analyze', 'uispecs:analyze', 'focused_specs:analyze']
  desc 'Runs specs, uispecs, and focused spec suites'
  task run: ['specs:run', 'uispecs:run', 'focused_specs:run']

  desc "Analyzes and runs the Specs test suite"
  task specs: [:analyze, :run]
  namespace :specs do
    desc "Analyzes specs"
    task :analyze do
      Xcode.analyze(target: SPECS_TARGET_NAME, logfile: "specs.analyze.log")
    end

    desc "Build specs"
    task build: 'frameworks:osx:build' do
      Xcode.build(target: SPECS_TARGET_NAME, logfile: "specs.build.log")
    end

    desc "Run specs"
    task run: :build do
      build_dir = Xcode.build_dir("")
      Shell.with_env("DYLD_FRAMEWORK_PATH" => build_dir, "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
        Shell.run(File.join(build_dir, SPECS_TARGET_NAME).inspect, "Specs.log")
      end
    end
  end

  desc "Analyzes and runs the UISpecs test suite"
  task uispecs: ['uispecs:analyze', 'uispecs:run']
  namespace :uispecs do

    desc "Analyzes UI specs"
    task :analyze do
      Xcode.analyze(target: UI_SPECS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386', logfile: "uispecs.analyze.log")
    end

    desc "Build UI specs"
    task :build do
      Xcode.build(target: UI_SPECS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386', logfile: "uispecs.build.log")
    end

    desc "Run UI specs"
    task run: :build do
      Simulator.kill
      env_vars = {
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      }

      Shell.with_env(env_vars) do
        Simulator.launch(Xcode.build_dir("-iphonesimulator"), UI_SPECS_TARGET_NAME, "uispecs.run.log")
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
      Xcode.analyze(target: FOCUSED_SPECS_TARGET_NAME, logfile: "focused_specs.analyze.log")
    end

    desc "Build Cedar's focused specs tests suite"
    task :build do
      Xcode.build(target: FOCUSED_SPECS_TARGET_NAME, logfile: "focused_specs.build.log")
    end

    desc "Run Cedar's specs for verifying focused test behavior"
    task run: :build do
      env_vars = {
        "DYLD_FRAMEWORK_PATH" => Xcode.build_dir,
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      }
      Shell.with_env(env_vars) do
        Shell.run(File.join(Xcode.build_dir, FOCUSED_SPECS_TARGET_NAME).inspect, "focused_specs.run.log")
      end
    end
  end

  desc "Analyzes and runs ios framework specs"
  task iosframeworkspecs: ['iosframeworkspecs:analyze', 'iosframeworkspecs:run']

  namespace :iosframeworkspecs do
    desc "Analyzes ios framework specs"
    task :analyze do
      Xcode.analyze(target: IOS_FRAMEWORK_SPECS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386', logfile: "frameworks.ios.specs.analyze.log")
    end

    desc "Build iOS static framework specs"
    task :build do
      Xcode.build(target: IOS_FRAMEWORK_SPECS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386', logfile: "frameworks.ios.specs.build.log")
    end

    desc "Runs iOS static framework specs"
    task run: :build do
      Simulator.kill
      env_vars = {
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      }

      Shell.with_env(env_vars) do
        Simulator.launch(Xcode.build_dir("-iphonesimulator"), IOS_FRAMEWORK_SPECS_TARGET_NAME, "frameworks.ios.specs.run.log")
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
      Xcode.build(target: CEDAR_FRAMEWORK_TARGET_NAME, logfile: "frameworks.osx.build.log", args: "install DSTROOT=/")
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

  desc "Build and run XCUnit specs (#{XCUNIT_APPLICATION_SPECS_SCHEME_NAME})"
  task xcunit: :convert_to_xcode5 do
    Simulator.kill

    Xcode.test(
      scheme: XCUNIT_APPLICATION_SPECS_SCHEME_NAME,
      sdk: "iphonesimulator#{SDK_VERSION}",
      args: "ARCHS=x86_64 -destination '#{Xcode.destination_for_ios_sdk(SDK_RUNTIME_VERSION)}' -destination-timeout 9",
      logfile: "xcunit.run.log",
    )
  end

  desc "Build and run OCUnit logic and application specs"
  task ocunit: ["ocunit:application"]

  namespace :ocunit do
    desc "Build and run OCUnit application specs (#{OCUNIT_APPLICATION_SPECS_SCHEME_NAME})"
    task application: :convert_to_xcode5 do
      Simulator.kill

      Xcode.test(
        scheme: OCUNIT_APPLICATION_SPECS_SCHEME_NAME,
        sdk: "iphonesimulator#{SDK_VERSION}",
        args: "ARCHS=i386 -destination '#{Xcode.destination_for_ios_sdk(SDK_RUNTIME_VERSION)}' -destination-timeout 9",
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

    Shell.run %{rm -rf "#{DIST_STAGING_DIR}"/*}
    Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode"}
    Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData"}
    Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Preferences/appCode20/templates"}

    Shell.run %{cp "#{PROJECT_ROOT}/README.markdown" "#{DIST_STAGING_DIR}/README-Cedar.markdown"}
    Shell.run %{cp "#{PROJECT_ROOT}/MIT.LICENSE.txt" "#{DIST_STAGING_DIR}/LICENSE-Cedar.txt"}

    Shell.run %{cp -R "#{TEMPLATES_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/"}
    Shell.run %{cp -R "#{SNIPPETS_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData/"}
    Shell.run %{cp "#{APPCODE_SNIPPETS_FILE}" "#{DIST_STAGING_DIR}/Library/Preferences/appCode20/templates/#{APPCODE_SNIPPETS_FILENAME}"}
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

  Shell.run %{rm -rf "#{DIST_STAGING_DIR}"/*}
  Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode"}
  Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData"}
  Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Preferences/appCode20/templates"}

  Shell.run %{cp "#{PROJECT_ROOT}/README.markdown" "#{DIST_STAGING_DIR}/README-Cedar.markdown"}
  Shell.run %{cp "#{PROJECT_ROOT}/MIT.LICENSE.txt" "#{DIST_STAGING_DIR}/LICENSE-Cedar.txt"}

  Shell.run %{cp -R "#{TEMPLATES_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/"}
  Shell.run %{cp -R "#{SNIPPETS_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData/"}
  Shell.run %{cp "#{APPCODE_SNIPPETS_FILE}" "#{DIST_STAGING_DIR}/Library/Preferences/appCode20/templates/#{APPCODE_SNIPPETS_FILENAME}"}

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

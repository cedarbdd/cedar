PROJECT_NAME = "Cedar"
APP_NAME = "Specs"
APP_IOS_NAME = "OCUnitApp"
CONFIGURATION = "Release"

SPECS_TARGET_NAME = "Specs"
UI_SPECS_TARGET_NAME = "iOSSpecs"
FOCUSED_SPECS_TARGET_NAME = "FocusedSpecs"
IOS_FRAMEWORK_SPECS_TARGET_NAME = "iOSFrameworkSpecs"

OCUNIT_LOGIC_SPECS_TARGET_NAME = "OCUnitAppLogicTests"
OCUNIT_APPLICATION_SPECS_TARGET_NAME = "OCUnitAppTests"
XCUNIT_APPLICATION_SPECS_TARGET_NAME = "OCUnitApp + XCTest"

CEDAR_FRAMEWORK_TARGET_NAME = "Cedar"
CEDAR_IOS_FRAMEWORK_TARGET_NAME = "Cedar-iOS"
TEMPLATE_IDENTIFIER_PREFIX = "com.pivotallabs.cedar."
TEMPLATE_SENTINEL_KEY = "isCedarTemplate"
SNIPPET_SENTINEL_VALUE = "isCedarSnippet"

XCODE_TEMPLATES_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/Templates"
XCODE_SNIPPETS_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/UserData/CodeSnippets"
APPCODE_SNIPPETS_DIR = "#{ENV['HOME']}/Library/Preferences/appCode20/templates"
XCODE_PLUGINS_DIR = "#{ENV['HOME']}/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"

SDK_VERSION = ENV["CEDAR_SDK_VERSION"] || "7.1"
SDK_RUNTIME_VERSION = ENV["CEDAR_SDK_RUNTIME_VERSION"] || "7.1"

PROJECT_ROOT = File.dirname(__FILE__)
BUILD_DIR = File.join(PROJECT_ROOT, "build")
TEMPLATES_DIR = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "Templates")
SNIPPETS_DIR = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "CodeSnippets")
APPCODE_SNIPPETS_FILENAME = "Cedar.xml"
APPCODE_SNIPPETS_FILE = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "AppCodeSnippets", APPCODE_SNIPPETS_FILENAME)
DIST_STAGING_DIR = "#{BUILD_DIR}/dist"
PLUGIN_DIR = File.join(PROJECT_ROOT, "CedarPlugin.xcplugin")
PLISTBUDDY = "/usr/libexec/PlistBuddy"

require 'tmpdir'

class Shell
  def self.run(cmd, logfile = nil)
    green = "\033[32m"
    red = "\033[31m"
    clear = "\033[0m"
    puts "#{green}==>#{clear} #{cmd}"
    original_cmd = cmd
    if logfile
      logfile = output_file(logfile)
      cmd = "export > #{logfile}; (#{cmd}) 2>&1 | tee /dev/stderr >> #{logfile}; test ${PIPESTATUS[0]} -eq 0"
    end
    system(cmd) or begin
      log_msg = ""
      if logfile
        log_msg = "[#{red}Failed#{clear}] Also logged to: #{logfile}"
      end
      raise <<EOF
#{`cat #{logfile}`}
[#{red}Failed#{clear}] Command: #{original_cmd}
#{log_msg}

EOF
    end
  end

  def self.with_env(env_vars)
    old_values = {}
    env_vars.each do |key,new_value|
      old_values[key] = ENV[key]
      ENV[key] = new_value
    end

    begin
      yield
    ensure
      env_vars.each_key do |key|
        ENV[key] = old_values[key]
      end
    end
  end

  def self.fold_start(name)
    puts "travis_fold start #{name}" if ENV['TRAVIS']
  end

  def self.fold_end(name)
    puts "travis_fold end #{name}" if ENV['TRAVIS']
  end

  def self.fold(name)
    fold_start(name)
    result = yield(self)
    fold_end(name)
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

  def self.is_octest_deprecated?
    system("cat #{Xcode.developer_dir}/Tools/RunUnitTests | grep -q 'RunUnitTests is obsolete.'")
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
    if `xcodebuild -showsdks`.include? "iphonesimulator8.0"
      "OS=#{version},name=iPhone 5s"
    else
      "OS=#{version},name=iPhone Retina (3.5-inch)"
    end
  end

  def self.build(options = nil)
    raise "Options requires :target or :scheme" if !options[:target] and !options[:scheme]

    logfile = options.fetch(:logfile)
    args = options[:args] || ""

    args += " -target #{options[:target].inspect}" if options[:target]
    args += " -sdk #{options[:sdk].inspect}" if options[:sdk]
    args += " -scheme #{options[:scheme].inspect}" if options[:scheme]

    Shell.fold "Build #{options[:scheme] || options[:target]}" do
      Shell.run(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -configuration #{CONFIGURATION} SYMROOT='#{BUILD_DIR}' build #{args}], logfile)
    end
  end

  def self.analyze(options = nill)
    raise "Options requires :target or :scheme" if !options[:target] and !options[:scheme]
    logfile = options.fetch(:logfile)
    args = options[:args] || ""

    args += " -target #{options[:target].inspect}" if options[:target]
    args += " -sdk #{options[:sdk].inspect}" if options[:sdk]
    args += " -scheme #{options[:scheme].inspect}" if options[:scheme]

    Shell.fold "Analyze #{options[:scheme] || options[:target]}" do
      Shell.run(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -configuration #{CONFIGURATION} analyze #{args} SYMROOT='#{BUILD_DIR}' | tee /dev/stderr | grep -q -v 'The following commands produced analyzer issues:'], logfile)
    end
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
    kill
    env_vars = {
      "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
    }

    Shell.with_env(env_vars) do
      Shell.run "ios-sim launch #{File.join(app_dir, "#{app_name}.app").inspect} --sdk #{SDK_RUNTIME_VERSION} | tee /dev/stderr | grep -q ', 0 failures'", logfile
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
    system %Q[killall -m -KILL "gdb"]
    system %Q[killall -m -KILL "otest"]
    system %Q[killall -m -KILL "iPhone Simulator"]
  end
end

class Simulator
  def self.launch(app_dir, app_name, logfile)
    kill
    # These comments represent the prior method of bootstrapping iOS apps without using the simulator.
    # It was more reliable, but 7.1+ SDKs fail with "The iOS Simulator libSystem was initialized out of order"
    #
    # sdk_path = Xcode.sdk_dir_for_version(SDK_RUNTIME_VERSION)
    env_vars = {
      # "DYLD_ROOT_PATH" => sdk_path,
      # "DYLD_FALLBACK_LIBRARY_PATH" => sdk_path,
      # "IPHONE_SIMULATOR_ROOT" => sdk_path,
      # "CFFIXED_USER_HOME" => Dir.tmpdir,
      "CEDAR_HEADLESS_SPECS" => "1",
      "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
    }

    Shell.with_env(env_vars) do
      # Shell.run "#{File.join(app_dir, "#{app_name}.app", app_name)} -RegisterForSystemEvents", logfile
      Shell.run "ios-sim launch #{File.join(app_dir, "#{app_name}.app").inspect} | tee /dev/stderr | grep -q ', 0 failures'", logfile
    end
  end

  def self.launch_bundle(app_dir, app_name, test_bundle, logfile)
    sdk_path = Xcode.sdk_dir_for_version(SDK_RUNTIME_VERSION)
    env_vars = {
      "DYLD_INSERT_LIBRARIES" => "#{Xcode.developer_dir}/Library/PrivateFrameworks/IDEBundleInjection.framework/IDEBundleInjection",
      "XCInjectBundle" => "#{}",
      "XCInjectBundleInto" => "#{File.join(Xcode.build_dir("-iphonesimulator"), "#{APP_IOS_NAME}.app/#{APP_IOS_NAME}")}",
    }
    Shell.with_env(env_vars) do
      launch(app_dir, app_name, logfile)
    end
  end

  def self.kill
    Shell.fold "Kill Simulator" do
      system %Q[killall -m -KILL "gdb"]
      system %Q[killall -m -KILL "otest"]
      system %Q[killall -m -KILL "iPhone Simulator"]
    end
  end
end

task :default => [:trim_whitespace, "suites:run", "suites:iosframeworkspecs:run", "testbundles:run"]
task :cruise => [:clean, "testbundles:run", :suites, "suites:iosframeworkspecs"]

desc "Trim whitespace"
task :trim_whitespace do
  Shell.run %Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.[cmh]$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;']
end

desc "Clean all targets"
task :clean do
  Shell.run "rm -rf '#{BUILD_DIR}'/*", "clean.log"
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
    task :build do
      Xcode.build(target: SPECS_TARGET_NAME, logfile: "specs.build.log")
    end

    desc "Run specs"
    task run: :build do
      build_dir = Xcode.build_dir("")
      Shell.with_env("DYLD_FRAMEWORK_PATH" => build_dir, "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
        Shell.run(File.join(build_dir, SPECS_TARGET_NAME), "Specs.log")
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
        "CEDAR_HEADLESS_SPECS" => "1",
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
    task run: [:build, 'frameworks:build'] do
      env_vars = {
        "DYLD_FRAMEWORK_PATH" => Xcode.build_dir,
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      }
      Shell.with_env(env_vars) do
        Shell.run(File.join(Xcode.build_dir, FOCUSED_SPECS_TARGET_NAME), "focused_specs.run.log")
      end
    end
  end

  desc "Analyzes and runs ios framework specs"
  task iosframeworkspecs: ['specs:analyze', 'specs:run']

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
        "CEDAR_HEADLESS_SPECS" => "1",
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
  task build: ['frameworks:ios:build', 'frameworks:osx:build'] do
    begin
      Rake::Task['frameworks:ios:specs:run'].execute
    rescue Exception => e
      puts "Unable to run iOS static framework specs. Skipping validation of Cedar-iOS.framework (#{e})"
    end
  end

  namespace :osx do
    task :build do
      Xcode.build(target: CEDAR_FRAMEWORK_TARGET_NAME, logfile: "frameworks.osx.build.log")
    end
  end

  namespace :ios do
    task :build do
      Xcode.build(target: CEDAR_IOS_FRAMEWORK_TARGET_NAME, logfile: "frameworks.ios.build.log")
    end
  end
end

namespace :testbundles do
  desc "Runs all test bundle test suites (xcunit, ocunit:logic, ocunit:application)"
  task run: ['testbundles:xcunit', 'testbundles:ocunit']

  desc "Build and run XCUnit specs (#{XCUNIT_APPLICATION_SPECS_TARGET_NAME})"
  task :xcunit do
    Simulator.kill

    Shell.fold "Running xcunit bundle #{XCUNIT_APPLICATION_SPECS_TARGET_NAME}" do
      Shell.with_env("CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
        if Xcode.is_octest_deprecated? and SDK_VERSION.split('.')[0].to_i >= 7
          Shell.run "xcodebuild test -project #{PROJECT_NAME}.xcodeproj -scheme #{XCUNIT_APPLICATION_SPECS_TARGET_NAME.inspect} -configuration #{CONFIGURATION} ARCHS=i386 SYMROOT='#{BUILD_DIR}' -destination '#{Xcode.destination_for_ios_sdk(SDK_VERSION)}' -destination-timeout 9", "xcunit.run.log"
        else
          puts "Running SDK #{SDK_VERSION}, which predates XCTest. Skipping."
        end
      end
    end
  end

  desc "Build and run OCUnit logic and application specs"
  task ocunit: ["ocunit:logic", "ocunit:application"]

  namespace :ocunit do
    desc "Build and run OCUnit logic specs (#{OCUNIT_LOGIC_SPECS_TARGET_NAME})"
    task :logic do
      Shell.fold "Running ocunit logic bundle #{OCUNIT_LOGIC_SPECS_TARGET_NAME}" do
        Shell.with_env("CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
          if Xcode.is_octest_deprecated?
            Shell.run "xcodebuild test -project #{PROJECT_NAME}.xcodeproj -scheme #{APP_NAME} -configuration #{CONFIGURATION} SYMROOT='#{BUILD_DIR}' -destination 'arch=x86_64'", "ocunit-logic-specs.log"
          else
            Shell.run "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{OCUNIT_LOGIC_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} -arch x86_64 build TEST_AFTER_BUILD=YES SYMROOT='#{BUILD_DIR}'", "ocunit-logic-specs.log"
          end
        end
      end
    end

    desc "Build and run OCUnit application specs (#{OCUNIT_APPLICATION_SPECS_TARGET_NAME})"
    task :application do
      Simulator.kill

      Shell.fold "Running ocunit application bundle #{OCUNIT_LOGIC_SPECS_TARGET_NAME}" do
        if Xcode.is_octest_deprecated?
          Shell.with_env("CEDAR_REPORTER_CLASS" => "CDRColorizedReporter") do
            Shell.run "xcodebuild test -project #{PROJECT_NAME}.xcodeproj -scheme #{APP_IOS_NAME} -configuration #{CONFIGURATION} ARCHS=i386 SYMROOT='#{BUILD_DIR}' -destination '#{Xcode.destination_for_ios_sdk(SDK_VERSION)}' -destination-timeout 9", "ocunit-application-specs.log"
          end
        else
          Shell.run "xcodebuild -project #{PROJECT_NAME}.xcodeproj -target #{OCUNIT_APPLICATION_SPECS_TARGET_NAME} -configuration #{CONFIGURATION} -sdk iphonesimulator#{SDK_VERSION} build ARCHS=i386 TEST_AFTER_BUILD=NO SYMROOT='#{BUILD_DIR}'", "ocunit-application-build.log"

          test_bundle = File.join(Xcode.build_dir("-iphonesimulator"), "#{OCUNIT_APPLICATION_SPECS_TARGET_NAME}.octest")
          Simulator.launch_bundle(Xcode.build_dir("-iphonesimulator"), APP_IOS_NAME, test_bundle, "ocunit.application.specs.log")
        end
      end
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
    Shell.run %{cp "#{PROJECT_ROOT}/MIT.LICENSE" "#{DIST_STAGING_DIR}/LICENSE-Cedar.txt"}

    Shell.run %{cp -R "#{TEMPLATES_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/"}
    Shell.run %{cp -R "#{SNIPPETS_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData/"}
    Shell.run %{cp "#{APPCODE_SNIPPETS_FILE}" "#{DIST_STAGING_DIR}/Library/Preferences/appCode20/templates/#{APPCODE_SNIPPETS_FILENAME}"}


    Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}-iphoneuniversal/#{CEDAR_IOS_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/iOS Cedar Spec Suite.xctemplate/"}
    Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}-iphoneuniversal/#{CEDAR_IOS_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/iOS Cedar Testing Bundle.xctemplate/"}

    Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}/#{CEDAR_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/OS X Cedar Spec Suite.xctemplate/#{CEDAR_FRAMEWORK_TARGET_NAME}.framework/"}
    Shell.run %{cp -R "#{BUILD_DIR}/#{CONFIGURATION}/#{CEDAR_FRAMEWORK_TARGET_NAME}.framework" "#{cedar_project_templates_dir}/OS X Cedar Testing Bundle.xctemplate/#{CEDAR_FRAMEWORK_TARGET_NAME}.framework/"}
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

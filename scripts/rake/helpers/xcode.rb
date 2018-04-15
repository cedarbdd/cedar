require_relative 'shell'

class Xcode
  def self.version
    `xcodebuild -version | grep Xcode`.chomp.split(' ').last.to_f
  end

  def self.developer_dir
    `xcode-select -print-path`.strip
  end

  def self.build_dir(effective_platform_name = "", configuration = CONFIGURATION)
    File.join(BUILD_DIR, configuration + effective_platform_name)
  end

  def self.sdk_dir_for_version(version)
    path = %x[ xcrun -sdk "iphonesimulator#{version}" -show-sdk-path 2>/dev/null ].strip
    raise("iPhone Simulator SDK version #{version} not installed") if $?.exitstatus != 0
    path
  end

  def self.iPhone_simulator_name
    'iPhone 5s'
  end

  def self.destination_for_ios_sdk(version)
    "name=#{iPhone_simulator_name},OS=#{version}"
  end

  def self.swift_build_settings
    version >= 7.0 ? "" : "OTHER_SWIFT_FLAGS=-DEXCLUDE_SWIFT_SPECS"
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
    args += " -configuration #{options[:configuration] || CONFIGURATION}"

    Shell.fold "build.#{options[:scheme] || options[:target]}" do
      Shell.run(%Q(xcodebuild -project #{PROJECT_NAME}.xcodeproj SYMROOT=#{BUILD_DIR.inspect} clean build #{args}), logfile)
    end
  end

  def self.test(options = nil)
    raise "Options requires :target or :scheme" if !options[:target] and !options[:scheme]

    logfile = options.fetch(:logfile)
    args = options[:args] || ""

    args += " -target #{options[:target].inspect}" if options[:target]
    args += " -sdk #{options[:sdk].inspect}" if options[:sdk]
    args += " -scheme #{options[:scheme].inspect}" if options[:scheme]

    # launch Simulator.app with the uuid matching our device and sdk version
    Shell.run(%Q(open -b com.apple.iphonesimulator \
                      --args -CurrentDeviceUDID `xcrun instruments -s | \
                                                 grep -o "#{iPhone_simulator_name} (#{SDK_VERSION}) \[.*\]" | \
                                                 grep -o "\[.*\]" | \
                                                 sed "s/^\[\(.*\)\]$/\1/" 2>/dev/null`))
    Shell.run("sleep 5", nil) # need to wait for the simulator to be done "launching"

    Shell.fold "test.#{options[:scheme] || options[:target]}" do
      retry_count = 0
      begin
        Shell.run(%Q(
                       xcodebuild -project #{PROJECT_NAME}.xcodeproj \
                       -configuration #{CONFIGURATION} \
                       -derivedDataPath #{DERIVED_DATA_DIR.inspect} \
                       SYMROOT=#{BUILD_DIR.inspect} \
                       clean build test #{args})\
                  , logfile)
      rescue
        retry_count += 1
        raise if retry_count == 3
      end
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

  def self.template_directories
    [
      "#{XCODE_TEMPLATES_DIR}/File Templates/Cedar",
      "#{XCODE_TEMPLATES_DIR}/Project Templates/Cedar"
    ]
  end
end

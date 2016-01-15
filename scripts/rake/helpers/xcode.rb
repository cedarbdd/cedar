require_relative 'shell'

class Xcode
  def self.version
    `xcodebuild -version | grep Xcode`.chomp.split(' ').last.to_f
  end

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
    "name=iPhone 5s,OS=#{version}"
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

  def self.template_directories
    [
      "#{XCODE_TEMPLATES_DIR}/File Templates/Cedar",
      "#{XCODE_TEMPLATES_DIR}/Project Templates/Cedar"
    ]
  end
end

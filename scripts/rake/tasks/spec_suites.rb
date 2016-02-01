# rake tasks related to running Cedar's spec suites

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
      Xcode.analyze(target: SPECS_TARGET_NAME, args: Xcode.swift_build_settings, logfile: "specs.analyze.log")
    end

    desc "Build specs"
    task build: 'frameworks:osx:build' do
      Xcode.build(target: SPECS_TARGET_NAME, args: Xcode.swift_build_settings, logfile: "specs.build.log")
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
        Simulator.launch(Xcode.build_dir("-iphonesimulator"), UI_SPECS_TARGET_NAME, Xcode.build_dir("-uispecs.run.log"))
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

  desc "Analyzes and runs ios static framework specs"
  task iosstaticframeworkspecs: ['iosstaticframeworkspecs:analyze', 'iosstaticframeworkspecs:run']

  namespace :iosstaticframeworkspecs do
    desc "Analyzes ios static framework specs"
    task :analyze do
      Xcode.analyze(target: IOS_STATIC_FRAMEWORK_SPECS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386', logfile: "frameworks.ios.static.specs.analyze.log")
    end

    desc "Build iOS static framework specs"
    task :build do
      Xcode.build(target: IOS_STATIC_FRAMEWORK_SPECS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386', logfile: "frameworks.ios.static.specs.build.log")
    end

    desc "Runs iOS static framework specs"
    task run: :build do
      Simulator.kill
      env_vars = {
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      }

      Shell.with_env(env_vars) do
        Simulator.launch(Xcode.build_dir("-iphonesimulator"), IOS_STATIC_FRAMEWORK_SPECS_TARGET_NAME, Xcode.build_dir("-frameworks.ios.static.specs.run.log"))
      end
    end
  end

  desc "Analyzes and runs ios dynamic framework specs"
  task iosdynamicframeworkspecs: ['iosdynamicframeworkspecs:analyze', 'iosdynamicframeworkspecs:run']

  namespace :iosdynamicframeworkspecs do
    desc "Analyzes ios dynamic framework specs"
    task :analyze do
      Xcode.analyze(target: IOS_DYNAMIC_FRAMEWORK_SPECS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386 '+Xcode.swift_build_settings, logfile: "frameworks.ios.dynamic.specs.analyze.log")
    end

    desc "Build iOS dynamic framework specs"
    task :build do
      Xcode.build(target: IOS_DYNAMIC_FRAMEWORK_SPECS_TARGET_NAME, sdk: "iphonesimulator#{SDK_VERSION}", args: 'ARCHS=i386 '+Xcode.swift_build_settings, logfile: "frameworks.ios.dynamic.specs.build.log")
    end

    desc "Runs iOS dynamic framework specs"
    task run: :build do
      Simulator.kill
      env_vars = {
        "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
      }

      Shell.with_env(env_vars) do
        Simulator.launch(Xcode.build_dir("-iphonesimulator"), IOS_DYNAMIC_FRAMEWORK_SPECS_TARGET_NAME, Xcode.build_dir("-frameworks.ios.dynamic.specs.run.log"))
      end
    end
  end
end

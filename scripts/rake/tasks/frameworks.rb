# rake tasks related to building Cedar's frameworks

namespace :frameworks do
  desc "Build Cedar OSX and iOS frameworks"
  task build: ['frameworks:ios:build', 'frameworks:osx:build']

  namespace :osx do
    desc "Builds and installs the Cedar OS X framework"
    task :build do
      Xcode.build(target: CEDAR_FRAMEWORK_TARGET_NAME, logfile: "frameworks.osx.build.log", args: "install DSTROOT=/")
    end
  end

  namespace :ios do
    desc "Builds the legacy Cedar iOS static framework"
    task :build_static do
      Xcode.build(target: CEDAR_IOS_STATIC_FRAMEWORK_TARGET_NAME, logfile: "frameworks.ios.static.build.log")
    end

    desc "Builds the Cedar iOS dynamic framework"
    task :build do
      Xcode.build(target: CEDAR_IOS_DYNAMIC_FRAMEWORK_TARGET_NAME, logfile: "frameworks.ios.dynamic.build.log")
    end
  end
end

# rake tasks for running Cedar's test bundle targets

namespace :testbundles do
  desc "Runs all test bundle test suites"
  task run: ['testbundles:xctest']

  desc "Converts the test bundle identifier to ones Xcode 5- recognizes (Xcode 6 postfixes the original bundler identifier)"
  task :convert_to_xcode5 do
    Xcode.sed_project(%r{com\.apple\.product-type\.bundle\.(oc)?unit-test}, 'com.apple.product-type.bundle')
  end

  desc "Build and run iOS XCTest spec bundle (#{IOS_SPEC_BUNDLE_SCHEME_NAME})"
  task xctest: :convert_to_xcode5 do
    Simulator.kill

    Xcode.test(
      scheme: IOS_SPEC_BUNDLE_SCHEME_NAME,
      sdk: "iphonesimulator#{SDK_VERSION}",
      args: "-destination '#{Xcode.destination_for_ios_sdk(SDK_RUNTIME_VERSION)}' -destination-timeout 9",
      logfile: "xctest.run.log",
    )
  end
end

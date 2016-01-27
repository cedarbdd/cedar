require_relative 'shell'

class Simulator
  def self.launch(app_dir, app_name, logfile)
    retry_count = 0
    Shell.with_env({"CEDAR_REPORTER_CLASS" => "CDRColorizedReporter"}) do
      begin
        kill # ensure simulator is not currently running
        Shell.run "rm -rf #{logfile}"
        Shell.run "ios-sim launch #{File.join(app_dir, "#{app_name}.app").inspect} --devicetypeid \"com.apple.CoreSimulator.SimDeviceType.iPhone-5s, #{SDK_RUNTIME_VERSION}\" --verbose --stdout #{logfile}"
        Shell.run "grep -q ', 0 failures' #{logfile}"                # Fail unless we find the literal string '0 failures', this is to prevent the tests going green if the test runner itself crashes before it logs ANY output
        Shell.run "! grep -q ', [1-9][0-9]* failures' #{logfile}"    # Fail if we find any number of failures
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
    system %Q[killall -m -KILL "gdb" > /dev/null 2>&1]
    system %Q[killall -m -KILL "otest" > /dev/null 2>&1]
    system %Q[killall -m -KILL "iPhone Simulator" > /dev/null 2>&1]
  end
end

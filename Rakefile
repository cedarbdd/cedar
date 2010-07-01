PROJECT_NAME = "Cedar"
TARGET_NAME = "Specs"
CONFIGURATION = "Release"
BUILD_SUBDIR = CONFIGURATION

BUILD_DIR = File.join(File.dirname(__FILE__), "build", BUILD_SUBDIR)

def system_or_exit(cmd)
  puts "Executing #{cmd}"
  system(cmd) or raise "******** Build failed ********"
end

task :cruise do
  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -alltargets -configuration #{CONFIGURATION} clean build])
#  system_or_exit(%Q[xcodebuild -project #{PROJECT_NAME}.xcodeproj -sdk macosx10.6 -target #{TARGET_NAME} -configuration #{CONFIGURATION} clean build])
  ENV["DYLD_FRAMEWORK_PATH"] = BUILD_DIR
  system_or_exit(%Q[#{File.join(BUILD_DIR, TARGET_NAME)}])
end

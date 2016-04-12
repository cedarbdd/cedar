PROJECT_NAME = "Cedar"
APP_IOS_NAME = "Cedar-iOS StaticLib Specs"
CONFIGURATION = "Release"

SPECS_TARGET_NAME = "Cedar-OSX Specs"
UI_SPECS_TARGET_NAME = "Cedar-iOS StaticLib Specs"
FOCUSED_SPECS_TARGET_NAME = "Cedar-OSX FocusedSpecs"
IOS_STATIC_FRAMEWORK_SPECS_TARGET_NAME = "Cedar-iOS StaticFrameworkSpecs"
IOS_DYNAMIC_FRAMEWORK_SPECS_TARGET_NAME = "Cedar-iOS Specs"

IOS_SPEC_BUNDLE_SCHEME_NAME = "Cedar-iOS SpecBundle"

CEDAR_FRAMEWORK_TARGET_NAME = "Cedar-OSX"
CEDAR_IOS_STATIC_FRAMEWORK_TARGET_NAME = "Cedar-iOS StaticFramework"
CEDAR_IOS_DYNAMIC_FRAMEWORK_TARGET_NAME = "Cedar-iOS"
TEMPLATE_IDENTIFIER_PREFIX = "com.pivotallabs.cedar."
TEMPLATE_SENTINEL_KEY = "isCedarTemplate"
SNIPPET_SENTINEL_VALUE = "isCedarSnippet"

XCODE_TEMPLATES_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/Templates"
XCODE_SNIPPETS_DIR = "#{ENV['HOME']}/Library/Developer/Xcode/UserData/CodeSnippets"

LATEST_SDK_VERSION = `xcodebuild -showsdks 2>/dev/null | grep iphonesimulator | cut -d ' ' -f 4`.chomp.split("\n").last
SDK_VERSION = ENV["CEDAR_SDK_VERSION"] || LATEST_SDK_VERSION
SDK_RUNTIME_VERSION = ENV["CEDAR_SDK_RUNTIME_VERSION"] || LATEST_SDK_VERSION

PROJECT_ROOT = File.dirname(__FILE__)
BUILD_DIR = File.join(PROJECT_ROOT, "build")
DERIVED_DATA_DIR = File.join(PROJECT_ROOT, "derivedData")
TEMPLATES_DIR = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "Templates")
SNIPPETS_DIR = File.join(PROJECT_ROOT, "CodeSnippetsAndTemplates", "CodeSnippets")
DIST_STAGING_DIR = "#{BUILD_DIR}/dist"
PLISTBUDDY = "/usr/libexec/PlistBuddy"

require 'tmpdir'
require 'tempfile'
require_relative 'scripts/rake/helpers'
require_relative 'scripts/rake/tasks'


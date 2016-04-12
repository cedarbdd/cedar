# tasks related to install, uninstall, reinstall, etc...

desc "Build frameworks and install templates and code snippets"
task :install => [:clean, :uninstall, "dist:prepare"] do
  puts ""
  puts "Installing templates..."
  puts ""

  AppCode.install_cedar_snippets

  Shell.run %{rsync -vcrlK "#{DIST_STAGING_DIR}/Library/" ~/Library}
end

task :reinstall => [:uninstall] do
  Dir.mkdir(DIST_STAGING_DIR) unless File.exists?(DIST_STAGING_DIR)

  Shell.run %{rm -rf "#{DIST_STAGING_DIR}"/*}
  Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode"}
  Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData"}


  Shell.run %{cp "#{PROJECT_ROOT}/README.markdown" "#{DIST_STAGING_DIR}/README-Cedar.markdown"}
  Shell.run %{cp "#{PROJECT_ROOT}/MIT.LICENSE.txt" "#{DIST_STAGING_DIR}/LICENSE-Cedar.txt"}

  Shell.run %{cp -R "#{TEMPLATES_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/"}
  Shell.run %{cp -R "#{SNIPPETS_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData/"}

  AppCode.install_cedar_snippets

  Shell.run %{rsync -vcrlK #{File.join(DIST_STAGING_DIR, "Library")} ~/Library}
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

  puts ""
  puts "Upgrading #{cedar_name} framework..."
  puts ""

  Shell.run %{rsync -vkcr --delete "#{BUILD_DIR}/#{cedar_path}/#{cedar_name}.framework/" "#{args.path_to_framework}/"}
end

desc "Remove code snippets and templates"
task :uninstall do
  puts ""
  puts "Removing old templates..."
  puts ""

  Xcode.template_directories.each do |template_dir|
    next unless File.directory?(template_dir)

    Dir.foreach(template_dir) do |template|
      next if template == '.' || template == '..'

      template_plist = "#{template_dir}/#{template}/TemplateInfo.plist"
      next unless File.exists?(template_plist)

      if `#{PLISTBUDDY} -c "Print :Identifier" "#{template_plist}"`.start_with?(TEMPLATE_IDENTIFIER_PREFIX) ||
          `#{PLISTBUDDY} -c "Print :#{TEMPLATE_SENTINEL_KEY}" "#{template_plist}"`.start_with?("true")
        Shell.run "rm -rf \"#{template_dir}/#{template}\""
      end
    end
  end

  AppCode.remove_installed_cedar_snippets
  Shell.run "grep -Rl #{SNIPPET_SENTINEL_VALUE} #{XCODE_SNIPPETS_DIR} | xargs -I{} rm -f \"{}\""
end

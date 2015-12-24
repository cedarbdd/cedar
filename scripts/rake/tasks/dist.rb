# tasks for building a distribution of Cedar

desc "Build a distribution of the templates and code snippets"
task :dist => ["dist:prepare", "dist:package"]

namespace :dist do
  task :prepare do
    Dir.mkdir(DIST_STAGING_DIR) unless File.exists?(DIST_STAGING_DIR)

    Shell.run %{rm -rf "#{DIST_STAGING_DIR}"/*}
    Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode"}
    Shell.run %{mkdir -p "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData"}

    Shell.run %{cp "#{PROJECT_ROOT}/README.markdown" "#{DIST_STAGING_DIR}/README-Cedar.markdown"}
    Shell.run %{cp "#{PROJECT_ROOT}/MIT.LICENSE.txt" "#{DIST_STAGING_DIR}/LICENSE-Cedar.txt"}

    Shell.run %{cp -R "#{TEMPLATES_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/"}
    Shell.run %{cp -R "#{SNIPPETS_DIR}" "#{DIST_STAGING_DIR}/Library/Developer/Xcode/UserData/"}

    AppCode.install_cedar_snippets(root_dir: DIST_STAGING_DIR)
  end

  task :package do
    package_file_path = "#{BUILD_DIR}/Cedar-#{`git rev-parse --short HEAD`.strip}.tar.gz"
    Shell.run %{cd #{DIST_STAGING_DIR} ; tar --exclude .DS_Store -zcf "#{package_file_path}" * ; cd -}

    puts ""
    puts "*** Built tarball is in #{package_file_path} ***"
    puts ""
  end
end

require_relative 'shell'

class AppCode
  def self.install_cedar_snippets(root_dir: ENV['HOME'])
    possible_appcode_directories(root_dir: root_dir).each do |full_snippets_dir|
      full_snippets_filepath = File.join(full_snippets_dir, APPCODE_SNIPPETS_FILENAME)

      Shell.run %{cp "#{APPCODE_SNIPPETS_FILE}" "#{full_snippets_filepath}"}
    end
  end

  def self.remove_installed_cedar_snippets
    possible_appcode_directories(root_dir: ENV['HOME']).each do |dir|
      Shell.run %{rm -f "#{File.join(dir, APPCODE_SNIPPETS_FILENAME)}"}
    end
  end

  private

  def self.possible_appcode_directories(root_dir: ENV['HOME'])
    appcode_pref_path = File.join(root_dir, 'Library', 'Preferences', 'appCode*')
    Dir.glob(appcode_pref_path, File::FNM_CASEFOLD).map { |d| File.join(d, "templates") }
  end

  # constants
  APPCODE_SNIPPETS_FILENAME = "Cedar.xml"

  APPCODE_SNIPPETS_FILE = File.join(
    ::PROJECT_ROOT,
    "CodeSnippetsAndTemplates",
    "AppCodeSnippets",
    APPCODE_SNIPPETS_FILENAME,
  )
end

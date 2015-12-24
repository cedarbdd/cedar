require_relative 'shell'

class AppCode
  def self.install_cedar_snippets(root_dir: ENV['HOME'])
    full_snippets_dir = File.join(root_dir, APPCODE_SNIPPETS_PATH)
    full_snippets_filepath = File.join(full_snippets_dir, APPCODE_SNIPPETS_FILENAME)

    Shell.run %{mkdir -p "#{full_snippets_dir}"}
    Shell.run %{cp "#{APPCODE_SNIPPETS_FILE}" "#{full_snippets_filepath}"}
  end

  def self.remove_installed_cedar_snippets
    Shell.run "rm -f \"#{APPCODE_SNIPPETS_DIR}/#{APPCODE_SNIPPETS_FILENAME}\""
  end

  # constants
  APPCODE_SNIPPETS_PATH = "Library/Preferences/AppCode32/templates"
  APPCODE_SNIPPETS_DIR = "#{ENV['HOME']}/#{APPCODE_SNIPPETS_PATH}"
  APPCODE_SNIPPETS_FILENAME = "Cedar.xml"

  APPCODE_SNIPPETS_FILE = File.join(
    ::PROJECT_ROOT,
    "CodeSnippetsAndTemplates",
    "AppCodeSnippets",
    APPCODE_SNIPPETS_FILENAME,
  )
end

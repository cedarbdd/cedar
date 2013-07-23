Before do
  if !$plugins_installed
    puts "Installing latest templates, one moment..."
    `rake install`
    $plugins_installed = true
  end
end

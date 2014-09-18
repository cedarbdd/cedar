puts "Installing latest templates, one moment..."
`osascript -e 'tell application "Xcode"' -e 'quit' -e 'end tell'`
`rake install`

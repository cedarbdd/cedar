puts "Installing latest templates, one moment..."
`killall -9 Xcode`
`osascript -e 'tell application "iOS Simulator"' -e 'quit' -e 'end tell'`
`rake install 2>/dev/null`

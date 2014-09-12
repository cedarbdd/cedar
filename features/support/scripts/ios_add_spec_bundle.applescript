tell application "Xcode"
	activate
end tell

tell application "System Events" to tell application process "Xcode"
		click menu item 5 of menu 1 of menu item "New" of menu 1 of menu bar item "File" of menu bar 1
		
		set projectWindow to "UNKNOWN"
		repeat with windowCount from 0 to count of windows
			set theWindow to item windowCount of windows
			if title of theWindow contains "template-project" then
				set projectWindow to theWindow
			end if
		end repeat
		
		set focused of scroll area 1 of sheet 1 of projectWindow to true
		keystroke "iOS"
		delay 2
		keystroke "Cedar"
		click UI element "iOS Cedar Testing Bundle" of group 1 of scroll area 1 of group 1 of sheet 1 of projectWindow
		click UI element "Next" of sheet 1 of projectWindow
		keystroke "Specs	Pivotal	com.pivotal.cedar	template-project"
		delay 1
		click UI element "Finish" of sheet 1 of projectWindow
        delay 1
end tell

tell application "Xcode"
	quit
end tell

on run argv
	set template_category_name to item 1 of argv
	set the_command to "echo "
	
	tell application "Xcode"
		activate
	end tell
	
	tell application "System Events" to tell application process "Xcode"
		-- creating a new target
		delay 5
		keystroke "?" using command down
		delay 1
		keystroke "new target"
		delay 1
		key code 125
		keystroke return
		
		set projectWindow to "UNKNOWN"
		repeat with windowCount from 0 to count of windows
			set theWindow to item windowCount of windows
			if title of theWindow contains "template-project" then
				set projectWindow to theWindow
			end if
		end repeat
		
		-- pick the template from the sheet
		set focused of scroll area 1 of sheet 1 of projectWindow to true
		keystroke template_category_name
		delay 2
		keystroke "Cedar"
		
		delay 2
		set templates to UI elements of group 1 of scroll area 1 of group 1 of sheet 1 of projectWindow
		
		repeat with template in templates
			set template_name to title of template
			set the_command to the_command & quoted form of template_name & ","
		end repeat
		
		click UI element "Cancel" of sheet 1 of projectWindow
	end tell
	
	tell application "Xcode"
		quit
	end tell
	
	do shell script the_command
end run

on run argv 
    set template_category_name to item 1 of argv
    set template_name to item 2 of argv
    tell application "Xcode"
        activate
    end tell

    tell application "System Events" to tell application process "Xcode"
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

        set focused of scroll area 1 of sheet 1 of projectWindow to true
        keystroke template_category_name
        delay 2
        keystroke "Cedar"
        click UI element template_name of group 1 of scroll area 1 of group 1 of sheet 1 of projectWindow
        click UI element "Next" of sheet 1 of projectWindow

        set form to group 1 of sheet 1 of projectWindow

        keystroke "Specs"
        keystroke tab
        keystroke "Pivotal"
        keystroke tab
        keystroke "com.pivotallabs.cedar"
        keystroke tab
        -- Xcode 6 has the "Languages:" option before the test scheme text field
        if exists pop up button "Language:" of form
            keystroke tab
        end if

        -- Test Bundles require a scheme to be specified
        if exists text field "Test Scheme" of form
            keystroke "template-project"
        end if
        delay 1
        click UI element "Finish" of sheet 1 of projectWindow
        delay 1

        -- check box to allow bundles to run app code. Not accessible to templates
        keystroke "1" using command down
        keystroke up

        set contentPane to group 2 of splitter group 1 of group 1 of projectWindow
        set checkboxContainer to scroll area 2 of splitter group 1 of group 1 of splitter group 1 of contentPane
        if exists checkbox "Allow testing Host Application APIs" of checkboxContainer then
            click checkbox "Allow testing Host Application APIs" of checkboxContainer
            delay 1
        end if
    end tell

    tell application "Xcode"
        quit
    end tell
end run

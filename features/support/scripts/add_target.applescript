on focusElementNamed(title_name, element_search_space)
    tell application "System Events" to tell application process "Xcode"
          set elements to entire contents of element_search_space
          repeat with element in elements
            if title of element is title_name then
              set element's focused to true
              exit repeat
            end if
          end repeat
    end tell
end focusedElementNamed

on run argv
    set template_category_name to item 1 of argv
    set template_name to item 2 of argv

    repeat until application "Xcode" is running
    end repeat

    tell application "Xcode"
        activate
    end tell

    tell application "System Events" to tell application process "Xcode"
        -- find the window and save it for future use
        set projectWindow to "UNKNOWN"
        repeat
            repeat with theWindow in windows
                if title of theWindow contains "template-project" then
                    set projectWindow to theWindow
                end if
            end repeat

            if projectWindow is not "UNKNOWN" then
                exit repeat
            end if
        end repeat

        -- Wait for Xcode to finish loading the project
        repeat until exists group 2 of projectWindow
        end repeat
        repeat until (value of static text 1 of group 2 of projectWindow) contains "template-project: Ready"
        end repeat

        -- creating a new target
        keystroke "?" using command down
        delay 1
        keystroke "new target"
        delay 5
        key code 125
        delay 1
        keystroke return

        -- pick the template from the sheet
        repeat until sheet 1 of projectWindow
        end repeat

        repeat until (exists sheet 1 of projectWindow)
        end repeat
        repeat until (exists scroll area 1 of sheet 1 of projectWindow)
        end repeat

        set focused of scroll area 1 of sheet 1 of projectWindow to true
        keystroke template_category_name
        delay 2
        keystroke "Cedar"
        click UI element template_name of group 1 of scroll area 1 of group 1 of sheet 1 of projectWindow
        click UI element "Next" of sheet 1 of projectWindow
        delay 1

        -- fill out the form of the template
        set form to group 1 of sheet 1 of projectWindow

        keystroke "Specs"
        keystroke tab
        keystroke "Pivotal"
        keystroke tab
        keystroke "com.pivotallabs.cedar"
        keystroke tab

        if exists text field "Test Scheme" of form
          -- change focus to element labeled 'Test Scheme'
          -- reminder : non-textfield controls can optionally receive focus on OS X
          my focusElementNamed("Test Scheme", form)
          keystroke "template-project"
          delay 1
        end if

        click UI element "Finish" of sheet 1 of projectWindow
        delay 2

        -- Xcode 6: check box to allow bundles to run app code. Not accessible to templates
        keystroke "O" using command down
        repeat until exists window "Open Quickly"
        end repeat

        keystroke "template-project.xcodeproj"
        delay 5
        keystroke return

        repeat while exists window "Open Quickly"
        end repeat
        delay 1

        set contentPane to group 2 of splitter group 1 of group 1 of projectWindow
        set specsTarget to row 5 of outline 1 of scroll area 1 of splitter group 1 of group 1 of splitter group 1 of contentPane
        select specsTarget

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

#Requires Autohotkey v2
#Include libs\Winter\Namek\lobby.ahk
#Include libs\webhook.ahk
global ActivityLogText
global isPaused := false
myGui := Gui("+AlwaysOnTop -Caption", "Mango") ; Remove caption and keep on top
myGui.BackColor := "0x111113"

; Updated GUI layout based on new specifications
ui := myGui.Add("Progress", "x256 y32 w800 h602 -Smooth c0x7e4141", 100)
WinSetTransColor("0x7e4141 255", myGui)
myGui.SetFont(, "Segoe UI")
myGui.Add("GroupBox", "x1068 y40 w210 h50 cFFFFFF", "Version")
VersionText := myGui.Add("Text", "x1075 y62 w180 h25 +Center cFFFFFF", "v1.0.0")
myGui.Add("GroupBox", "x1068 y40 w210 h50 cFFFFFF", "Version")
VersionText := myGui.Add("Text", "x1075 y62 w180 h25 +Center cFFFFFF", "v1.0.0")

; Move Activity Log to the right side
myGui.Add("GroupBox", "x1068 y100 w210 h160 cFFFFFF", "Activity Log")
ActivityLogText := myGui.Add("Edit", "x1075 y116 w195 h141 +Multi +ReadOnly -E0x200 -Border -VScroll", "Macro Launched")
ActivityLogText.SetFont("s9", "Segoe UI")
ActivityLogText.Opt("+Background" . "0x111113" . " c" . "FFFFFF")
; Move Statistics to the right side
myGui.Add("GroupBox", "x1068 y270 w210 h45 cFFFFFF", "Statistics")
WLText := myGui.Add("Text", "x1075 y289 w195 h25 +Center cFFFFFF", "W/L: 0/0")

; Move Keybinds to the right side
myGui.Add("GroupBox", "x1068 y325 w210 h80 cFFFFFF", "Keybinds")
myGui.Add("Text", "x1075 y340 w195 h50  cFFFFFF", " F1 - Fix Roblox Position `n F2 - Start Macro `n F3 - Stop Macro `n F4 - Pause/Unpause")

; Move Boss Rush to the right side
myGui.Add("GroupBox", "x1068 y415 w210 h50 cFFFFFF", "Winter Maps")
DropDownList2 := myGui.Add("DropDownList", "x1075 y431 w195 cFFFFFF -E0x200 +Theme", ["Namek", "Shibuya (WIP)"])
DropDownList2.OnEvent("Change", SaveSelection)

SaveSelection(*) {
    global DropDownList2
    FileOpen(A_ScriptDir . "\libs\settings\Map.txt", "w", "UTF-8").Write(DropDownList2.Text) ; Overwrite the file with the new selection
}

DropDownList2.SetFont("s10 Bold", "Segoe UI")
DropDownList2.Opt("+Background0x222222")
myGui.Add("GroupBox", "x1068 y540 w210 h50 cFFFFFF", "Positions")
Positions := myGui.Add("DropDownList", "x1075 y555 w195 cFFFFFF", ["start", "middle", "end"])
Positions.OnEvent("Change", SaveSelection2)
SaveSelection2(*) {
    global Positions
    FileOpen(A_ScriptDir . "\libs\settings\Position.txt", "w", "UTF-8").Write(Positions.Text) ; Overwrite the file with the new selection
}
Positions.SetFont("s10 Bold", "Segoe UI")
myGui.Add("GroupBox", "x1068 y475 w210 h50 cFFFFFF", "Present Multiplier")
PresentMultiplierInput := myGui.Add("Edit", "x1075 y491 w145 h25 c000000 -E0x200 +Center", "60")
myGui.Add("Text", "x1225 y491 w20 h25 c000000 +Center", "%")
PresentMultiplierInput.SetFont("s10 Bold", "Segoe UI")
HelpButton := myGui.Add("Button", "x1250 y491 w25 h25 -E0x200", "?")
HelpButton.OnEvent("Click", ShowPresentMultiplierHelp)
PresentMultiplierInput.OnEvent("Change", UpdatePresentMultiplier)

UpdatePresentMultiplier(*) {
    global PresentMultiplierInput, PresentMultiplier
    inputValue := PresentMultiplierInput.Value
    ; Only accept numeric input
    if (inputValue ~= "^\d+$") {
        PresentMultiplier := Integer(inputValue)
    } else if (inputValue = "") {
        PresentMultiplier := 0
    } else {
        ; Revert to previous valid value if input is not numeric
        PresentMultiplierInput.Value := PresentMultiplier
    }
}

ShowPresentMultiplierHelp(*) {
    helpGui := Gui("+AlwaysOnTop +Owner" myGui.Hwnd, "Present Multiplier Help")
    helpGui.BackColor := "0x111113"
    helpGui.SetFont("s10", "Segoe UI")
    helpGui.Add("Text", "x10 y10 w300 cFFFFFF", "Present Multiplier increases the number of presents")
  
    
    ; Add picture in the middle
    helpPic := helpGui.Add("Picture", "x60 y60 w200 h100", A_ScriptDir . "\libs\Winter\Images\PresentMulti.png")
    
    helpGui.Add("Text", "x10 y170 w300 cFFFFFF", "Input your present multiplier:")
    helpGui.Add("Text", "x10 y190 w300 cFFFFFF", "(don't use the one from the picture)")
    
    closeButton := helpGui.Add("Button", "x110 y230 w80 h30 cFFFFFF", "Close")
    closeButton.OnEvent("Click", (*) => helpGui.Destroy())
    
    helpGui.Show("w320 h270")
}



; Move Settings button to the right side
ButtonSettings := myGui.Add("Button", "x1068 y600 w210 h30 cFFFFFF", "Settings")
BACKGROND := myGui.Add("Text", "x-16 y0 w1256 h25 Background1a1a1a", "") ; Make width shorter to not overlap with close button
fakebackground := myGui.Add("Text", "x-16 y0 w2000 h25 Background1a1a1a", "") ; Make width shorter to not overlap with close button
; topbar ----------------------------------
minimizeButton := myGui.Add("Picture", "x1230 y3 w20 h20 0x6 +BackgroundTrans", A_ScriptDir . "\mini.png")
minimizeButton.OnEvent("Click", (*) => myGui.Minimize()) ; Minimize the GUI
closeButton := myGui.Add("Picture", "x1260 y3 w20 h20 0x6 +BackgroundTrans", A_ScriptDir . "\close.png")
closeButton.OnEvent("Click", ExitHandler)


; Add a proper exit handler function
ExitHandler(*) {
    LogMessage("Application closing...")
    Sleep(200)  ; Give a moment for the log to update
    ExitApp()   ; Completely terminate the script
}
MangoLogo := myGui.Add("Picture", "x584 y-2 w29 h25 0x6 +BackgroundTrans", A_ScriptDir . "\mango.png")
BACKGROND_TEXT := myGui.Add("Text", "x616 y2 w91 h20  +BackgroundTrans +Center cFFFFFF", "MangoGuards")
BACKGROND_TEXT.SetFont("s10 Bold", "Karla")
BACKGROND.OnEvent("Click", DragWindow)
MangoLogo.OnEvent("Click", DragWindow)
BACKGROND_TEXT.OnEvent("Click", DragWindow)
DragWindow(*) {
    PostMessage(0xA1, 2,,, myGui)  
}
; ----------------------------------

myGui.Add("GroupBox", "x8 y40 w238 h50 cFFFFFF", "Party")
PartyText := myGui.Add("Text", "x20 y64 w210 h25 +Center cFFFFFF", "Not Connected")
myGui.Add("Text", "x0 y648 w1308 h70 +Center cFFFFFF", "Winter Portal v1.0 - Made by Mango")
ButtonSettings.OnEvent("Click", OpenSettings)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Mango"
myGui.Show("w1290 h681")  ; Updated window size

; --- rewards ---
myGui.Add("GroupBox", "x8 y100 w238 h200 cFFFFFF", "Collected Rewards")
Presents := myGui.Add("Text", "x20 y120 w210 h25 cFFFFFF", "Presents: 0")

Presents.SetFont("s10 Bold", "Segoe UI")



; New functions for script FPS tracking


; Define the PresentMultiplier and prensentprize variables at the top of the script with other globals
global PresentMultiplier := 0
global prensentprize := 0

updatePresentCount() {
    global Presents, prensentprize
    ; Simulate a random number of presents collected for demonstration purposes
    prensentprize += Round(1500+1500*(Integer(PresentMultiplier)/100))
    Presents.Value := "Presents: " prensentprize
    
}


UpdateWLDisplay() {
    global Wins, Losses, WLText
    WLText.Value := "W/L: " Wins "/" Losses
}

LogMessage(message, type := "info") {
    global ActivityLogText
    prefix := "[" . StrUpper(type) . "] "  ; Add a prefix based on the type (e.g., [INFO], [WARNING])
    formattedMessage := prefix . message  ; Combine prefix and message
    ActivityLogText.Value := formattedMessage "`n" ActivityLogText.Value
}
OpenSettings(*) {
    Settingsui := Gui("+AlwaysOnTop") 
    Settingsui.Title := "Settings"
    Settingsui.BackColor := "0x111113"  ; Match main GUI background
    
    ; Add buttons side by side
    ButtonChangeHotkey := Settingsui.Add("Button", "x10 y20 w110 h30 cFFFFFF", "Change Hotkey")
    DiscordWebhook := Settingsui.Add("Button", "x130 y20 w110 h30 cFFFFFF", "Webhook")
    DiscordWebhook.OnEvent("Click", OpenWebhookSettings)

OpenWebhookSettings(*) {
    WebhookUI := Gui("+AlwaysOnTop")
    WebhookUI.Title := "Discord Webhook Settings"
    WebhookUI.BackColor := "0x111113"
    
    WebhookUI.SetFont("s10", "Segoe UI")
    WebhookUI.Add("Text", "x10 y10 w300 cFFFFFF", "Enter Discord Webhook URL:")
    
    ; Load existing webhook if available
    webhookFile := A_ScriptDir . "\libs\settings\webhook.txt"
    existingWebhook := ""
    if (FileExist(webhookFile)) {
        existingWebhook := FileRead(webhookFile)
    }
    
    webhookInput := WebhookUI.Add("Edit", "x10 y40 w280 h25", existingWebhook)
    
    saveButton := WebhookUI.Add("Button", "x10 y80 w130 h30 cFFFFFF", "Save")
    test := WebhookUI.Add("Button", "x160 y80 w130 h30 cFFFFFF", "Test")
    
    saveButton.OnEvent("Click", SaveWebhook)
    test.OnEvent("Click", (*) => TestWebhook())
    
    WebhookUI.Show("w300 h120")
    
    SaveWebhook(*) {
        webhookUrl := webhookInput.Value
        if (webhookUrl != "") {
            FileOpen(A_ScriptDir . "\libs\settings\webhook.txt", "w", "UTF-8").Write(webhookUrl)
            LogMessage("Discord webhook saved successfully")
        }
        WebhookUI.Destroy()
    }
    TestWebhook(*) {
        SendWebhook()
    }
    
}
    SlotMaker := Settingsui.Add("Button", "x10 y60 w110 h30 cFFFFFF", "Placement")
    SlotMaker.OnEvent("Click", OpenUnitManager)

    
    ; Add a close button with more space at the bottom
    CloseButton := Settingsui.Add("Button", "x85 y110 w80 h30 cFFFFFF", "Close")
    CloseButton.OnEvent("Click", (*) => Settingsui.Destroy())
    
    ; Show the settings GUI
    Settingsui.Show("w250 h150")  ; Increased height to make space for the close button
}

OpenUnitManager(*) {
    try {
        ; First check if UnitManager is already running
        if WinExist("Vanguards Unit Customizer") {
            WinActivate("Vanguards Unit Customizer")
            return
        }
        
        ; Run the unit manager AHK file
        unitManagerPath := A_ScriptDir . "\libs\UIPARTS\unitmanager.ahk"
        
        ; Log that we're launching the unit manager
        LogMessage("Opening Unit Placement Manager...", "info")
        
        ; Check if the file exists
        if (!FileExist(unitManagerPath)) {
            LogMessage("Unit Manager file not found: " . unitManagerPath, "error")
            MsgBox("Error: Unit Manager file not found at: " . unitManagerPath)
            return
        }
        
        ; Run the unit manager
        Run(unitManagerPath)
    } catch as err {
        LogMessage("Error opening Unit Manager: " . err.Message, "error")
        MsgBox("Error opening Unit Manager: " . err.Message)
    }

}

F2:: {
    start()
}
F3::Reload
F1::FixPositions()
F4::PauseMacro()
PauseMacro() {
    global isPaused
    isPaused := !isPaused  ; Toggle the pause state
    if (isPaused) {
        Pause(true)  ; Pause the script
        LogMessage("Macro paused.")
    } else {
        Pause(false)  ; Resume the script
        LogMessage("Macro unpaused.")
    }
}

FixPositions() {
    myGui.Show("x50 y50") 

    RobloxWindow := "ahk_exe RobloxPlayerBeta.exe"
    
    ; First activate our GUI
    if WinExist("Mango") {
        Sleep(50)
        WinActivate("Mango")
        Sleep(100)
        
        ; Get position of our UI progress control
        ui.GetPos(&MainX, &MainY, &MainWidth, &MainHeight)
        WinGetPos(&GuiX, &GuiY, , , "Mango")
        
        ; Calculate absolute position
        AbsX := GuiX + MainX
        AbsY := GuiY + MainY
    }

    ; Now position Roblox directly
    if WinExist(RobloxWindow) {
        WinActivate(RobloxWindow)
        Sleep(50)
        ; Use fixed offset and size that matches the progress control
        WinMove(298, 52, 816, 642, RobloxWindow)
        LogMessage("Roblox window repositioned.", "info")
        Sleep(50)
    } else {
        LogMessage("Roblox window not found!")
    }
}
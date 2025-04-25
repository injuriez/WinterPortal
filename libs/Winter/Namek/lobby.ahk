#Requires AutoHotkey v2.0
#Include ..\..\FindText.ahk
#Include ingame\main.ahk
global Wins := 0, Losses := 0 
global Maps := ""
global PlayerPos := ""
Use:="|<>*142$31.0ss000yy000PvkM0Atzz06Qzzk7C0kQzb1t7znY8bztn6Dzy331zzXVkzzzzzzzzzzzk"
Failed:="|<>*44$89.zVzzk7wADz3zsS1z3zzU7sMTy7zky3y7zy0DkkzwDzVy7w0Dw8DVVzs0T3wDs0DkMT33zk0S7wTk0zVkS67zU1wDkzU3z00wADz07sTVz3zw00sMTy7zky3y7zs01kkzwDzVs7wDzUz1VVzs0300TsTz3z3300k0601zkzw7y6601U0A07zVzwTyQA0300M0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw"
Namek:="|<>*79$27.zzzzzzzzzzzzzw9zzvUDzzQVU60V920Qt0E9bgGlDzzzzzzzzzzzzzzzzzw"
Tier10:="|<>*76$13.zzzzytyMS9joruPxVylzzzzz"
ThreeRewards:="|<>*109$33.zzzzzzzzzzzzzzzzzMzzzzn7zzzy8zzzzU0UUkQ00421n6300C8kM43k63UkT4mQ63zzzzzzzzzzzU"
CoordMode "Mouse", "Window"
UpdateWinsAndLosses(NewWins, NewLosses) {
    global Wins, Losses, WLText
    Wins := NewWins
    Losses := NewLosses
    UpdateWLDisplay() 
}


Rewards() {
    portalData := [
        {portal: {x: 299, y: 312}, select: {x: 302, y: 369}},
        {portal: {x: 407, y: 313}, select: {x: 401, y: 367}},
        {portal: {x: 513, y: 311}, select: {x: 515, y: 369}}
    ]
    
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642
    
    NamekRewards:="|<>*78$28.zzzzzzzzzzzzzzzzzzyPzzwsbzznWE0k20E8EN82U0al+l/zzzzzzzzzzzzzzzzzzzzzzzzzzzy"
    ShibuyaRewards:="|<>*76$35.zzzzzzzzzzzzzzzzzzzzzzzy9kzzzsHtzzzlV0Y93t8494b+E228D4U66szzzztzzzzzrzzzzzzz"
    SpiderRewards:="|<>*77$27.zzzzzzzzzzzzzyDnbzVzwzwMG4Et+42QcE0Hl2FWTtzzzzDzzzzzzzU"
    Use:="|<>*142$31.0ss000yy000PvkM0Atzz06Qzzk7C0kQzb1t7znY8bztn6Dzy331zzXVkzzzzzzzzzzzk"
    
    namekFound := false
    shiburyaFound := false
    spiderFound := false
    
    LogMessage("Searching for Namek portal...")
    for portalPos in portalData {
        SmoothMouseMoveAndClick(portalPos.portal.x, portalPos.portal.y, 0, false)
        Sleep(500)

        if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, NamekRewards)) {
            LogMessage("Namek portal found!")
            
            SmoothMouseMoveAndClick(portalPos.select.x, portalPos.select.y, 0, true)
            Sleep(1000)
            SmoothMouseMoveAndClick(355, 341, 0, true) ; Click the yes button
            Sleep(1000)
            SmoothMouseMoveAndClick(405, 345, 0, true) ; press cancel button
            Sleep(1000)
            loop 5 {
                SmoothMouseMoveAndClick(408, 280, 0, true) ; Click the yes button
            }

            PurposeFailed(false)
            
            namekFound := true
            break
        }
    }
    
    if (!namekFound) {
        LogMessage("No Namek portal found. Searching for Shibuya portal...")
        for portalPos in portalData {
            SmoothMouseMoveAndClick(portalPos.portal.x, portalPos.portal.y, 0, false)
            Sleep(500)
    
            if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, ShibuyaRewards)) {
                LogMessage("Shibuya portal found!")
                
                SmoothMouseMoveAndClick(portalPos.select.x, portalPos.select.y, 0, true)
                Sleep(1000)
                SmoothMouseMoveAndClick(355, 341, 0, true) ; Click the yes button
                Sleep(1000)
                SmoothMouseMoveAndClick(405, 345, 0, true) ; press cancel button
                Sleep(1000)
         
                loop 5 {
                    SmoothMouseMoveAndClick(408, 280, 0, true) ; Click the yes button
                }
                
                
                PurposeFailed(false)
                
                
                
                shiburyaFound := true
                break
            }
        }
    }
    
    if (!namekFound && !shiburyaFound) {
        LogMessage("No Namek or Shibuya portal found. Searching for Spider portal...")
        for portalPos in portalData {
            SmoothMouseMoveAndClick(portalPos.portal.x, portalPos.portal.y, 0, false)
            Sleep(500)
    
            if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, SpiderRewards)) {
                LogMessage("Spider portal found!")
                
                SmoothMouseMoveAndClick(portalPos.select.x, portalPos.select.y, 0, true)
                Sleep(1000)
                SmoothMouseMoveAndClick(355, 341, 0, true) ; Click the yes button
                Sleep(1000)
                SmoothMouseMoveAndClick(405, 345, 0, true) ; press cancel button
                Sleep(1000)
                loop 5 {
                    SmoothMouseMoveAndClick(408, 280, 0, true) ; Click the yes button
                }
                PurposeFailed(false)
                
                
                spiderFound := true
                break
            }
        }
    }
    

    LogMessage("No usable portals found. Refreshing...")
    Sleep(1000) ; Wait before trying again
}
start() {

  
    global Maps  
    global PlayerPos  

    Maps := FileRead(A_ScriptDir . "\libs\settings\Map.txt") 
    LogMessage("Maps: " Maps) 
    PlayerPos := FileRead(A_ScriptDir . "\libs\settings\Position.txt") 
    LogMessage("PlayerPos: " PlayerPos)

    ; closes chat
    if ImageSearchWrapper(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\libs\Winter\Images\chatopen.png", 20) {
        SmoothMouseMoveAndClick(145, 61, 1, true) 
        LogMessage("Closing chat...") 
    } else {
        LogMessage("Chat Already Closed.")
    }



    SmoothMouseMoveAndClick(35, 299, 1, true) 
    Sleep(1000) 
    SearchBar()
}

SearchBar() {
    SmoothMouseMoveAndClick(252, 252, 1, true) 
    Sleep(500)
    Send("winter portal") 
    Sleep(500) 
    FindPortal()
}

FindPortal() {
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642  

    WholeSection := [{x: 244, y: 292}, {x: 309, y: 300}, {x: 374, y: 295}, {x: 439, y: 295}, {x: 503, y: 295}, {x: 571, y: 295}, {x: 245, y: 354}, {x: 311, y: 352}, {x: 374, y: 353}, {x: 441, y: 355}, {x: 501, y: 352}, {x: 567, y: 352}, {x: 247, y: 407}, {x: 311, y: 411}, {x: 375, y: 412}, {x: 440, y: 410}, {x: 504, y: 411}, {x: 569, y: 409}]

    while true {
        for section in WholeSection {
            SmoothMouseMoveAndClick(section.x, section.y, 0, false) 
            Sleep(500) 
    
         
            if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Tier10)) {
                LogMessage("Tier 10 portal detected")
                
                switch Maps {
                    case "Namek":
                        if ImageSearchWrapper(&FoundX, &FoundY, X1, Y1, X2, Y2, A_ScriptDir . "\libs\Winter\Images\PLANET.png", 30) {
                            LogMessage("Found A Namek Tier 10 Portal")

                            BetterClick(section.x, section.y) ; Click the portal
                            Sleep(1000) ; Wait for the click to register
                            if ImageSearchWrapper(&FoundX, &FoundY, X1, Y1, X2, Y2, A_ScriptDir . "\libs\Winter\Images\Use.png", 10) {
                                SmoothMouseMoveAndClick(FoundX + 20, FoundY, true) ; clicks use button
                                SmoothMouseMoveAndClick(FoundX + 5, FoundY, true) ; Click the use button
                                BetterClick(FoundX + 5, FoundY) ; Click the use button again
                                Sleep(500)
                                SmoothMouseMoveAndClick(384, 330, 1, true) ; Click the use button again
                                ; clicks cancel
                                Sleep(500)
                                SmoothMouseMoveAndClick(409, 336, 1, true) ; Click the use button again
                                LogMessage("Namek Tier 10 Portal Placed")

                                VotingUI()
                                return
                            } else {
                                LogMessage("Use button not found.")
                            }
                        }
                
                    case "Shibuya":
                        if ImageSearchWrapper(&FoundX, &FoundY, X1, Y1, X2, Y2, A_ScriptDir . "\libs\Winter\Images\SHIBUYA.png", 30) {                     
                            LogMessage("Found A Shibuya Tier 10 Portal")

                            BetterClick(section.x, section.y) ; Click the portal
                            Sleep(1000) ; Wait for the click to register
                            if ImageSearchWrapper(&FoundX, &FoundY, X1, Y1, X2, Y2, A_ScriptDir . "\libs\Winter\Images\Use.png", 10) {
                                SmoothMouseMoveAndClick(FoundX + 20, FoundY, true) ; clicks use button
                                SmoothMouseMoveAndClick(FoundX + 5, FoundY, true) ; Click the use button
                                BetterClick(FoundX + 5, FoundY) ; Click the use button again
                                Sleep(500)
                                SmoothMouseMoveAndClick(384, 330, 1, true) ; Click the use button again
                                ; clicks cancel
                                Sleep(500)
                                SmoothMouseMoveAndClick(409, 336, 1, true) ; Click the use button again
                                LogMessage("Shibuya Tier 10 Portal Placed")
                                VotingUI()
                                return
                            } else {
                                LogMessage("Use button not found.")
                            }
                        }
                }
            } else {
                LogMessage("Not a Tier 10 portal, skipping")
            }
        }
        
        LogMessage("No Tier 10 portals found on this page, scrolling down...")
        scrolling(150) 
    }
}

VotingUI() {
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642 
    LogMessage("Awaiting Voting UI....")

    loop {
        if ImageSearchWrapper(&FoundX, &FoundY, X1, Y1, X2, Y2, A_ScriptDir . "\libs\Winter\Images\Voting.png", 30) {
            Sleep(1000) ; Wait for the click to register
            BetterClick(377, 155) ; Click the voting UI
            ;------------------ close chat ------------------
            if ImageSearchWrapper(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\libs\Winter\Images\chatopen.png", 20) {
                SmoothMouseMoveAndClick(145, 61, 1, true) ; Adjust the coordinates as needed
                LogMessage("Closing chat...")  ; Log the action
            } else {
                LogMessage("Chat Already Closed.")
            }
            Sleep(4000) ; Wait for the click to register
            BetterClick(572, 102) ; close LEADERBOARD
            Sleep(1000) ; Wait for the click to register
            PositionMethod()
            break
        } 
    }

}
AwaitFailed() {
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642 
    LogMessage("Awaiting Failed UI....")

    loop {
        if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Failed)) {
            {
              LogMessage("Failed UI detected.")
              BetterClick(409, 85) ; close the failed UI

              return
            }
            
        }
    }
}
PurposeFailed(openfailedui := true) { ; this is for the purpose failed UI
    global Maps := "Namek" ; Set the map name here
    if openfailedui {
        LogMessage("Opening Failed UI...")
        BetterClick(409, 85) ; open the failed ui
        Sleep(1000) ; Wait for the click to register
    } else {
        LogMessage("Failed UI detected.")
    }
    SmoothMouseMoveAndClick(157, 455, 3, true) ; Click the yes button
  
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642  
  
    WholeSection := [
        {x: 209, y: 277}, {x: 291, y: 290}, {x: 369, y: 282}, {x: 447, y: 280}, {x: 525, y: 279}, {x: 605, y: 282},
        {x: 209, y: 352}, {x: 286, y: 354}, {x: 365, y: 354}, {x: 448, y: 351}, {x: 526, y: 353}, {x: 696, y: 353},
        {x: 209, y: 423}, {x: 287, y: 424}, {x: 368, y: 424}, {x: 448, y: 422}, {x: 524, y: 422}, {x: 605, y: 424}
    ]
  
    while true {
        for section in WholeSection {
            SmoothMouseMoveAndClick(section.x, section.y, 0, false) ; Move to the portal location
            Sleep(500) ; Adjust the delay as needed
    
            switch Maps {
                case "Namek":
                    if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Namek)) {
                      
  
                        BetterClick(section.x, section.y) ; Click the portal
                        Sleep(1000) ; Wait for the click to register
                        SmoothMouseMoveAndClick(351, 343, 1, true) ; presses yes
                        PurposeVotingUI()
  
                       
                    }
            
                case "Shibuya":
                    if ImageSearchWrapper(&FoundX, &FoundY, X1, Y1, X2, Y2, A_ScriptDir . "\libs\Winter\Images\shibuyasmall.png", 30) {                     
                       
                        ; LogMessage("Found A Shibuya Portal ")
  
                        BetterClick(section.x, section.y) ; Click the portal
                        Sleep(1000) ; Wait for the click to register
             
                        SmoothMouseMoveAndClick(351, 343, 1, true) ; presses yes
                        PurposeVotingUI()
                    }
            }
        }
        
        scrolling(150) ; Scroll down after processing the whole section
    }
    
  }
PurposeVotingUI() {
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642 
    LogMessage("Awaiting Voting UI....")

    loop {
        if ImageSearchWrapper(&FoundX, &FoundY, X1, Y1, X2, Y2, A_ScriptDir . "\libs\Winter\Images\Voting.png", 30) {
            Sleep(1000) ; Wait for the click to register
            BetterClick(377, 155) ; Click the voting UI
            Sleep(4000) ; Wait for the click to register
            BetterClick(572, 102) ; close LEADERBOARD
            Sleep(1000) ; Wait for the click to register
            StartVanguards() ; starts the unit manager
            
            break
        } 
    }
}
PositionMethod() {
    upgrade:="|<>*84$19.zzzzzzwAMSA6DCFbaAnnCNtXAwt6SQ7DD3brznszVwTtzzzw"

    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642


    LookDown() ; makes you look down
    ; -------- place down sprint --------
   
        loop {
            BetterClick(489, 576) ; clicks last slot
            Sleep(500) ; Wait for the click to register
            BetterClick(411, 340) ; Places down sprint
            
            if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, upgrade)) {
                LogMessage("Sprint placed successfully.")
                LogMessage("Now awaiting fail", "WARNING")
                AwaitFailed()

                break
            } else {
              
                Sleep(1000) ; Wait before retrying
            }
        }
        
        
        ; press spectator button
        Sleep(500) ; Wait for the click to register
        BetterClick(234, 445)
        Sleep(500) ; Wait for the click to register
        BetterClick(336, 548) ; press the left button
        Sleep(500) ; Wait for the click to register
        BetterClick(535, 423) ; clicks off the UI
        ; clicks leave spectator
        BetterClick(408, 610) 

        
        ; ---------PIXEL SEARCH FOR THE POSITIONS ---------
        if (Maps = "Namek") {
            if PlayerPos = "start" {
                LogMessage("Checking for Namek start position...")
                loop {
                    Sleep(1000)
                    if (CheckPixelPosition("Namek_start")) {
                        LogMessage("Namek Start Position detected!", "info")
                        ; Add your actions for Namek start position
                        PurposeFailed(true)
                        break
                    } else {
                        LogMessage("Namek Start Position not found.")
                        respawn()
                    }
                }
                
            } else if PlayerPos = "middle" {
                loop {
                    Sleep(1000) 
                    if (CheckPixelPosition("Namek_middle")) {
                        LogMessage("Namek Start Position detected!", "info")
                        PurposeFailed(true)
                        break
                    } else {
                        LogMessage("Namek middle Position not found.")
                        respawn()
                    }
                }
            } else if PlayerPos = "end" {
                loop {
                    Sleep(1000) 
                    if (CheckPixelPosition("Namek_end")) {
                        MsgBox("Namek End Position detected!")
                        PurposeFailed(true)
                        break
                    } else {
                        LogMessage("Namek end Position not found.")
                        respawn()
                    }
                }
            } else {
                MsgBox("Invalid Player Position specified.")
            }
            
        } 
        else if (Maps = "Shibuya") {
            ; Check three different positions in Shibuya
            if (CheckPixelPosition("Shibuya1")) {
                MsgBox("Shibuya Position 1 detected!")
                ; Add your actions for Shibuya position 1
                
            }
            else if (CheckPixelPosition("Shibuya2")) {
                MsgBox("Shibuya Position 2 detected!")
                ; Add your actions for Shibuya position 2
                
            }
            else if (CheckPixelPosition("Shibuya3")) {
                MsgBox("Shibuya Position 3 detected!")
                ; Add your actions for Shibuya position 3
                
            }
            else {
                ; If not in any desired position, restart the loop
                MsgBox("Undesired spawn position in Shibuya. Respawning...")
                Sleep(1000)
                
            }
        }
    
}

respawn() {
    BetterClick(32, 609) ; Clicks Settings
    Sleep(300) ; Wait for the click to register
    BetterClick(525, 242) ; Clicks respawn
    Sleep(300) ; Wait for the click to register
    BetterClick(577, 159) ; Closes Settings UI (rushi)
    ; ------- check sprint again -------
    SendInput("{f}") ; Press f to open unit manager
    Sleep(500) ; Wait for the click to register
    BetterClick(618, 195) ; press on the unit in the unit manager
    ; close unit manager 
    BetterClick(556, 593) 
    Sleep(500) ; Wait for the click to register
    BetterClick(234, 445)
    Sleep(500) ; Wait for the click to register
    BetterClick(336, 548) ; press the left button
    Sleep(500) ; Wait for the click to register
    BetterClick(535, 423) ; clicks off the UI
    ; clicks leave spectator
    BetterClick(408, 610) 


}

CheckPixelPosition(positionName) {
    ; Define pixel check data for each position
    positions := Map(
        "Namek_start", [
            [38, 426, 78, 118, 142],
            [56, 327, 70, 110, 137],
        ],
        "Namek_middle", [
            [700, 153, 17, 124, 118],
            [704, 185, 141, 189, 238],
        ],
        "Namek_end", [
            [77, 272, 63, 41, 50],
        ],
        "Shibuya1", [
            [180, 370, 120, 125, 130],
            [220, 330, 110, 115, 120]
        ],
        "Shibuya2", [
            [240, 410, 100, 105, 110],
            [190, 380, 105, 110, 115]
        ],
        "Shibuya3", [
            [310, 350, 130, 135, 140],
            [270, 400, 125, 130, 135]
        ]
    )
    
    ; Get the pixel data for the requested position
    pixelArray := positions[positionName]
    if (!pixelArray) {
        MsgBox("Position data not found for: " positionName)
        return false
    }
    
    tolerance := 20  ; Adjust tolerance as needed
    
    ; Check each pixel in the array
    Loop pixelArray.Length {
        pixel := pixelArray[A_Index]
        x := pixel[1]
        y := pixel[2]
        expectedR := pixel[3]
        expectedG := pixel[4]
        expectedB := pixel[5]
        
        ; Get actual color
        color := PixelGetColor(x, y)
        actualR := (color >> 16) & 0xFF
        actualG := (color >> 8) & 0xFF
        actualB := color & 0xFF
        
        ; Check if pixel matches within tolerance
        if (Abs(actualR - expectedR) <= tolerance 
            && Abs(actualG - expectedG) <= tolerance 
            && Abs(actualB - expectedB) <= tolerance) {
            ; MsgBox("Found position: " positionName " (matched pixel at " x ", " y ")")
            return true
        }
    }
    
    ; MsgBox("Position not matched: " positionName " (no pixels matched)")
    return false
}

scrolling(time) {
    SendInput("{WheelDown Down}")
    Sleep time
}


BetterClick(x, y) {

    MouseMove(x, y)
    Sleep(10)
    MouseMove(1, 0, , "R")
    Sleep(20)
    MouseClick("Left", -1, 0, , , , "R")
    Sleep(50)
}



SmoothMouseMoveAndClick(TargetX, TargetY, Speed := 0, Click := false) {
    CoordMode "Mouse", "Window" ; Set coordinate mode to window
    ; Get the current mouse position
    MouseGetPos(&CurrentX, &CurrentY)

    ; Calculate the distance to move
    DeltaX := TargetX - CurrentX
    DeltaY := TargetY - CurrentY

    ; Gradually move the mouse
    Steps := 10  ; Reduced number of steps for faster movement
    Loop Steps {
        ; Calculate the next position
        StepX := CurrentX + (DeltaX * (A_Index / Steps))
        StepY := CurrentY + (DeltaY * (A_Index / Steps))

        ; Move the mouse to the next position
        MouseMove(StepX, StepY)

        ; Add a minimal delay for smoothness
        Sleep(Speed)
    }

    ; Ensure the mouse is at the exact target position
    MouseMove(TargetX, TargetY)

    ; Perform the click if requested
    if (Click) {
        Sleep(500)
        BetterClick(TargetX, TargetY)
    }
}


ImageSearchWrapper(&FoundX, &FoundY, X1, Y1, X2, Y2, ImagePath, Tolerance := 30) {
    try {
        ; Store the previous CoordMode and set to Screen
        prevCoordMode := A_CoordModePixel
        CoordMode "Pixel", "Window"


        ; Perform the image search with specified tolerance
        result := ImageSearch(&FoundX, &FoundY, X1, Y1, X2, Y2, "*" Tolerance " " ImagePath)

        ; Restore previous CoordMode if needed
        if (prevCoordMode != "Screen")
            CoordMode "Pixel", prevCoordMode

        ; Return and log results
        if (result) {
            return true
        } else {
            return false
        }
    } catch as e {
        MsgBox("Error in ImageSearchWrapper: " e.Message . " " . ImagePath)

        return false
    }
}


LookDown() 
{
    BetterClick(700, 299)  
    
    loop 40 
    {
        SendInput("{WheelUp}")
        Sleep 50
    }
    Sleep 1000
    
    SendInput(Format("{Click {} {} Left}", 949, 929))
    Sleep 1000
    
    loop 100 
    {
        SendInput("{WheelDown}")
        Sleep 50
    }
}

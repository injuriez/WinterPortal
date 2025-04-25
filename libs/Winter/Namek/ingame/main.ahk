#Requires AutoHotkey v2.0
#Include ..\..\..\FindText.ahk
one:="|<>*75$20.zzzzzzzzzzzzzy6EzX2DsUny8AzXXDstnySQzbbDttnyTwzVwDwTbzzzzzzzU"
two:="|<>*80$21.zzzzzzzzzzzzzzsMkz637sWAz4lbtyAzD3btkwzA1btkAzDzbwTkzXzDzzzzzzzU"
three:="|<>*84$17.zzzzzzzzzzzsMklUlb8nDVaT7Az6NXAnUNbVnjzb7wCDwzzzk"
four:="|<>*76$19.zzzzzzzzzy4oD6F7X8nl4NsUAwE6SQ3DDlbbxnnztsTkyDwzzzzzzz"
five:="|<>*81$16.zzzzzzzzV06A4Mnta7aM6NkNbNaM6Nktbzb7sQTnzzzzzzzzU"
six:="|<>*80$20.zzzzzzzzzzzzzwC8T737lVtwNyTA3bn0twlCTC3bnltwzyTXy7sznzzzzzzzzzzs"
seven:="|<>*80$17.zzzzzzzzzzzs0El0FXln7XaTDAwSNtwnXtbjnDzb7wCDwzzzzzzzzz"
eight:="|<>*84$19.zzzzzzwAMSA6DCHbb1nnUttWAwl6SQ7DD7brznszVwTtzzzzzzy"
nine:="|<>*83$19.zzzzzzwAMSA6DAHba1nnUttwQwyCSQDDCDbrznszVwTtzzzzzzy"
ten:="|<>*85$22.zzzzzzzzzzzVr66AMANVYNa4NaSHaNt6NbaFaSMCRtktrzzb7zsQTznzzzy"
maxlevel :="|<>*85$41.zzzzzzzzzzzzzzzzzzzzy5ySyyVwFssssXtVVlsXbn131sDDa06HsyTAF83UwyMqE68twlw70tnxrsT/vbvzzzzzDlzzzzsTXzzzztzzzzzzzs"
global wins := 0, losses := 0
global slot1Coords := Map()
global slot2Coords := Map()
global slot3Coords := Map()
global slot4Coords := Map()
global slot5Coords := Map()
global slot6Coords := Map()

global slot1UpgradeLevels := Map()
global slot2UpgradeLevels := Map()
global slot3UpgradeLevels := Map()
global slot4UpgradeLevels := Map()
global slot5UpgradeLevels := Map()
global slot6UpgradeLevels := Map()
CoordMode "Mouse", "Window"
global slotConfigsWithPriority := [] 

UnitManager() {
    configFile := A_ScriptDir "\libs\UIPARTS\vanguards_config.txt"    
    if (!FileExist(configFile)) {
        MsgBox("Configuration file not found: " configFile)
        return
    }
    
    Try {
        fileContent := FileRead(configFile, "UTF-8")
    } Catch as err {
        MsgBox("Error reading configuration file: " err.Message)
        return
    }
    
    slotConfigs := StrSplit(fileContent, "`n", "`r")
    
    global slotConfigsWithPriority := []
    
    for slotConfig in slotConfigs {
        if (Trim(slotConfig) = "")
            continue
            
        parts := StrSplit(slotConfig, ":")
        if (parts.Length < 6)
            continue
            
        slotName := parts[1]
        upgrades := parts[2]
        placements := Integer(parts[3])
        skillType := parts[4]
        priority := Integer(parts[5])
        coordsStr := parts[6]
        
        coordsList := StrSplit(coordsStr, ";")
        
        slotConfigsWithPriority.Push({
            slotName: slotName,
            upgrades: upgrades,
            placements: placements,
            skillType: skillType,
            priority: priority,
            coordsList: coordsList
        })
    }
    
    slotConfigsWithPriority := SortByPriority(slotConfigsWithPriority)
    
    LogMessage("PHASE 1: Placing all units...")
    for _, config in slotConfigsWithPriority {
        PlaceUnitsWithVerification(config.slotName, config.placements, config.coordsList)
    }
    
    LogMessage("PHASE 2: Upgrading all units...")
    for _, config in slotConfigsWithPriority {
        UpgradeUnitsWithFindText(config.slotName, config.upgrades, config.coordsList)
    }
    
    LogMessage("PHASE 3: Activating skills...")
    for _, config in slotConfigsWithPriority {
        if (config.skillType != "None")
            CustomAutoSkill(config.slotName, config.skillType)
    }
}


SortByPriority(configArray) {
    n := configArray.Length
    
    loop n-1 {
        outer := A_Index
        loop n-outer {
            inner := A_Index
            if (configArray[inner].priority > configArray[inner+1].priority) {
                temp := configArray[inner]
                configArray[inner] := configArray[inner+1]
                configArray[inner+1] := temp
            }
        }
    }
    
    return configArray
}

PlaceUnitsWithVerification(slotName, placements, coordsList) {
    slotNum := SubStr(slotName, 5)
    global slot1Coords, slot2Coords, slot3Coords, slot4Coords, slot5Coords, slot6Coords

    LogMessage("Processing " slotName " with " coordsList.Length " coordinate sets")
    for idx, coordSet in coordsList {
        LogMessage("  Coordinate " idx ": " coordSet)
    }
    
    skillType := ""
    for _, config in slotConfigsWithPriority {
        if (config.slotName = slotName) {
            skillType := config.skillType
            break
        }
    }
    
    if (coordsList.Length = 1 && coordsList[1] = "0,0") {
        OutputDebug("Skipping " slotName " placement: Default coordinates (0,0) detected")
        return
    }
    
    successfulCoords := Map()
    
    placedCount := 0
    i := 1
    
    while (placedCount < placements && i <= coordsList.Length) {
        coordStr := coordsList[i]
        
        coordParts := StrSplit(coordStr, "|")
        coords := coordParts[1]
        upgradeInfo := coordParts.Length > 1 ? coordParts[2] : ""
        
        xyParts := StrSplit(coords, ",")
        if (xyParts.Length < 2 || (xyParts[1] = "0" && xyParts[2] = "0")) {
            i++
            continue
        }
            
        originalX := Integer(xyParts[1])
        originalY := Integer(xyParts[2])
        
        Send(slotNum)
        Sleep(700)
        
        placed := false
        
        currentX := originalX
        currentY := originalY
        
        totalAttempts := 0
        verticalOffset := 0
        horizontalOffset := 0
        
        while (!placed) {
            totalAttempts++
            
            LogMessage("Placement attempt #" totalAttempts " for " slotName " unit " i " at " currentX "," currentY)
            
            SmoothMouseMoveAndClick(currentX, currentY, 4, true)
            Sleep(700)
            
            if (VerifyUnitPlaced()) {
                placedCount++
                placed := true
                successfulCoords[i] := currentX . "," . currentY . (upgradeInfo ? "|" . upgradeInfo : "")
                LogMessage("Unit " i " placed successfully after " totalAttempts " attempts at " currentX "," currentY)
                
                if (skillType = "SJW Arise") {
                    LogMessage("Activating SJW Arise skill immediately for unit at " currentX "," currentY)
                    
                    Sleep(300)
                    
                    SmoothMouseMoveAndClick(318, 292, 4, true)
                    Sleep(400)
                    SmoothMouseMoveAndClick(374, 286, 4, true)
                    Sleep(400)
                    SmoothMouseMoveAndClick(214, 453, 4, true)
                    Sleep(400)
                    SmoothMouseMoveAndClick(716, 171, 4, true)
                    Sleep(500)
                }
            } else {
                if (Mod(totalAttempts, 5) = 0) {
                    LogMessage("Checking game status after " totalAttempts " failed attempts")
                    CheckGameStatus()
                    
                    Send(slotNum)
                    Sleep(700)
                }
                
                if (Mod(totalAttempts, 4) = 1) {
                    verticalOffset += 30
                    currentY := originalY + verticalOffset
                    currentX := originalX
                } else if (Mod(totalAttempts, 4) = 2) {
                    horizontalOffset += 30
                    currentX := originalX + horizontalOffset
                    currentY := originalY
                } else if (Mod(totalAttempts, 4) = 3) {
                    currentX := originalX + horizontalOffset
                    currentY := originalY + verticalOffset
                } else {
                    currentX := originalX + Random(-50, 50)
                    currentY := originalY + Random(-50, 50)
                }
                
                Sleep(500)
            }
        }
        
        i++
        Sleep(700)
    }
    
    slotNumber := Integer(SubStr(slotName, 5))
    
    if (slotNumber = 1)
        coordsMap := slot1Coords
    else if (slotNumber = 2)
        coordsMap := slot2Coords
    else if (slotNumber = 3)
        coordsMap := slot3Coords
    else if (slotNumber = 4)
        coordsMap := slot4Coords
    else if (slotNumber = 5)
        coordsMap := slot5Coords
    else if (slotNumber = 6)
        coordsMap := slot6Coords
    
    for index, newCoords in successfulCoords {
        if (slotNumber = 1)
            slot1Coords[index] := newCoords
        else if (slotNumber = 2)
            slot2Coords[index] := newCoords
        else if (slotNumber = 3)
            slot3Coords[index] := newCoords
        else if (slotNumber = 4)
            slot4Coords[index] := newCoords
        else if (slotNumber = 5)
            slot5Coords[index] := newCoords
        else if (slotNumber = 6)
            slot6Coords[index] := newCoords
    }
    
    if (placedCount < placements) {
        if (placedCount > 0)
            MsgBox("Warning: Only placed " placedCount " out of " placements " units for " slotName)
        else
            MsgBox("Failed to place any units for " slotName)
    } else {
        LogMessage("Successfully placed all " placedCount " units for " slotName)
    }
}

VerifiedPlacement(slotNum, x, y) {
    
    Loop  {
        Sleep(700)
        
        MouseMove(x, y)
        Sleep(250)
        Click
        Sleep(700)
        
        if (VerifyUnitPlaced()) {
            LogMessage("Unit placement verified for slot " slotNum)
            return true
        } else {
            MsgBox("Attempt " A_Index " failed for slot " slotNum)
            CheckGameStatus()
            Sleep(700)
        }
    }
    
    return false
}

VerifyUnitPlaced() {
    upgrade := "|<>*84$19.zzzzzzwAMSA6DCFbaAnnCNtXAwt6SQ7DD3brznszVwTtzzzw"

    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642
    
    Sleep(700)
    
    if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, upgrade)) {
        LogMessage("Upgrade button found, unit placement verified!")
        return true
    }
    
    return false
}

CheckGameStatus() {
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642 

    if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Failed)) {
        {
          LogMessage("Failed UI detected.")
          BetterClick(409, 85)
          UpdateWinsAndLosses(wins, losses + 1)
          PurposeFailed(false)

          return
        }
                
    }

    if (ok:=FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, ThreeRewards)) {
        {
          LogMessage("Three rewards UI detected.")
          UpdateWinsAndLosses(wins + 1, losses)
          Rewards()
          
          return
        }
    }
}
        
autohotkeyPlaceUnitsWithVerification(slotName, placements, coordsList) {
    slotNum := SubStr(slotName, 5)
    
    if (coordsList.Length = 1 && coordsList[1] = "0,0") {
        OutputDebug("Skipping " slotName " placement: Default coordinates (0,0) detected")
        return
    }
    
    placedCount := 0
    i := 1
    
    while (placedCount < placements && i <= coordsList.Length) {
        coordStr := coordsList[i]
        
        coordParts := StrSplit(coordStr, "|")
        coords := coordParts[1]
        
        xyParts := StrSplit(coords, ",")
        if (xyParts.Length < 2 || (xyParts[1] = "0" && xyParts[2] = "0")) {
            i++
            continue
        }
            
        x := Integer(xyParts[1])
        y := Integer(xyParts[2])
        
        Send(slotNum)
        Sleep(700)
        
        SmoothMouseMoveAndClick(x, y, 4, true)
        
        if (VerifyUnitPlaced()) {
            placedCount++
        } else {
            CheckGameStatus()
        }
        
        i++
        Sleep(700)
    }
    
    if (placedCount < placements && placedCount > 0)
        MsgBox("Warning: Only placed " placedCount " out of " placements " units for " slotName)
}

UpgradeUnitsWithFindText(slotName, defaultUpgrade, coordsList) {
    slotNumber := Integer(SubStr(slotName, 5))
    
    global slot1Coords, slot2Coords, slot3Coords, slot4Coords, slot5Coords, slot6Coords
    global lastUnitX, lastUnitY
    
    LogMessage("====================================================")
    LogMessage("UPGRADING UNITS FOR " slotName)
    LogMessage("Default upgrade level: " defaultUpgrade)
    
    if (slotNumber = 1)
        updatedCoords := slot1Coords
    else if (slotNumber = 2)
        updatedCoords := slot2Coords
    else if (slotNumber = 3)
        updatedCoords := slot3Coords
    else if (slotNumber = 4)
        updatedCoords := slot4Coords
    else if (slotNumber = 5)
        updatedCoords := slot5Coords
    else if (slotNumber = 6)
        updatedCoords := slot6Coords
    else
        updatedCoords := Map()
    
    if (updatedCoords.Count = 0) {
        return
    }
    
    
    for unitIndex, coordStr in updatedCoords {
        LogMessage("Processing unit " unitIndex " with data: " coordStr)
        
        if (coordStr = "0,0") {
            continue
        }
        
        parts := StrSplit(coordStr, "|")
        coords := parts[1]
        
        targetUpgrade := defaultUpgrade
        if (parts.Length > 1 && parts[2] != "") {
            targetUpgrade := parts[2]
        }
        
        xyParts := StrSplit(coords, ",")
        if (xyParts.Length < 2) {
            continue
        }
        
        x := Integer(xyParts[1])
        y := Integer(xyParts[2])
        
        if (x = 0 && y = 0) {
            continue
        }
        
        
        SmoothMouseMoveAndClick(x, y, 4, true)
        lastUnitX := x
        lastUnitY := y
        Sleep(800)
        
        upgradeUnit(targetUpgrade)
        
        Sleep(800)
    }
    
 
}

upgradeUnit(targetUpgrade) {
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642
    
    if (targetUpgrade = "MAX")
        targetUpgrade := 11
    else
        targetUpgrade := Integer(targetUpgrade)
    
    currentLevel := getCurrentUpgradeLevel()
    
    if (currentLevel >= targetUpgrade) {
        return
    }
    
    global lastUnitX, lastUnitY
    MouseGetPos(&lastUnitX, &lastUnitY)
    
    attemptCount := 0
    
    lastLevel := currentLevel
    stuckCounter := 0
    totalStuckCounter := 0
    
    while (true) {
        attemptCount++
        
        Send("t")
        Sleep(700)
        
        newLevel := getCurrentUpgradeLevel()
        
        if (newLevel >= targetUpgrade) {
            break
        }
        
        if (newLevel = lastLevel) {
            stuckCounter++
            
            if (stuckCounter >= 3) {
                totalStuckCounter++
                
                SmoothMouseMoveAndClick(lastUnitX, lastUnitY, 4, true)
                Sleep(800)
                
                if (totalStuckCounter >= 3) {
                    break
                }
                
                stuckCounter := 0
            }
        } else {
            stuckCounter := 0
            totalStuckCounter := 0
        }
        
        lastLevel := newLevel
        
        Sleep(500)
    }
    
    LogMessage("Upgrade complete after " attemptCount " attempts. Final level: " getCurrentUpgradeLevel())
}

getCurrentUpgradeLevel() {
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642
    global one, two, three, four, five, six, seven, eight, nine, ten, maxlevel
    
    Sleep(300)
    
    if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, maxlevel)) {
        LogMessage("MAX level detected")
        return 11
    }
    
    if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, ten)) {
        LogMessage("Level 10 detected")
        return 10
    }
    
    if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, nine)) {
        LogMessage("Level 9 detected")
        return 9
    }
    else if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, eight)) {
        LogMessage("Level 8 detected")
        return 8
    }
    else if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, seven)) {
        LogMessage("Level 7 detected")
        return 7
    }
    else if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, six)) {
        LogMessage("Level 6 detected")
        return 6
    }
    else if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, five)) {
        LogMessage("Level 5 detected")
        return 5
    }
    else if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, four)) {
        LogMessage("Level 4 detected")
        return 4
    }
    else if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, three)) {
        LogMessage("Level 3 detected")
        return 3
    }
    else if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, two)) {
        LogMessage("Level 2 detected")
        return 2
    }
    else if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, one)) {
        LogMessage("Level 1 detected")
        return 1
    }
    
    LogMessage("No level detected, assuming level 0")
    return 0
}

CustomAutoSkill(slotName, skillType) {
    slotNum := SubStr(slotName, 5)
    
    if (skillType = "None") {
        return
    }
    
    global slot1Coords, slot2Coords, slot3Coords, slot4Coords, slot5Coords, slot6Coords
    
    if (slotNum = "1")
        coordsMap := slot1Coords
    else if (slotNum = "2")
        coordsMap := slot2Coords
    else if (slotNum = "3")
        coordsMap := slot3Coords
    else if (slotNum = "4")
        coordsMap := slot4Coords
    else if (slotNum = "5")
        coordsMap := slot5Coords
    else if (slotNum = "6")
        coordsMap := slot6Coords
    else {
        return
    }
    
    if (coordsMap.Count = 0) {
        return
    }
    
    firstUnitCoords := coordsMap[1]
    
    if (InStr(firstUnitCoords, "|")) {
        coordParts := StrSplit(firstUnitCoords, "|")
        firstUnitCoords := coordParts[1]
    }
    
    xyParts := StrSplit(firstUnitCoords, ",")
    if (xyParts.Length < 2) {
        return
    }
    
    x := Integer(xyParts[1])
    y := Integer(xyParts[2])
    
    if (x = 0 && y = 0) {
        return
    }
    
    
    SmoothMouseMoveAndClick(x, y, 4, true)
    Sleep(700)
    
    if (skillType = "Basic") {
        SmoothMouseMoveAndClick(317, 255, 4, true)
        Sleep(600)
        SmoothMouseMoveAndClick(317, 255, 4, true)
        Sleep(600)
    }
    
    LogMessage("Skill activation completed for slot " slotNum)
}


StartVanguards() {
    Sleep(1000)
    LogMessage("Starting unit placement and upgrades...")
    
    UnitManager()
    
    LogMessage("All units placed..")
    After()
}

After() {
    global X1 := 298, Y1 := 52, X2 := 298 + 816, Y2 := 52 + 642 
    
    LogMessage("Starting post-game monitoring...")
    
    while (true) {
        if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, Failed)) {
            LogMessage("Failed UI detected.")
            UpdateWinsAndLosses(wins, losses + 1)
            PurposeFailed(false)
            
            break
        } 
        
        if (ok := FindText(&X, &Y, X1, Y1, X2, Y2, 0, 0, ThreeRewards)) {
            LogMessage("Three rewards UI detected.")
            UpdateWinsAndLosses(wins + 1, losses)
            updatePresentCount()
            SendWebhook()
            Rewards()
            break
        }
        
        Sleep(1000)
        
        LogMessage("Still monitoring for game completion...")
    }
    
    LogMessage("Game finished monitoring.")
}
#Requires AutoHotkey v2.0
#Include AHKv2-Gdip-master\Gdip_All.ahk
#Include Discord-Webhook-master\lib\WEBHOOK.ahk
#SingleInstance Force
global webhook := ""

SendWebhook() {
    pToken := Gdip_Startup()
    if !pToken {
        MsgBox("Failed to initialize GDI+")
        return
    }

    ; Find the Roblox window and your UI
    RobloxWindow := "ahk_exe RobloxPlayerBeta.exe"
    UIWindow := "Mango"
    
    ; Check if Roblox is running
    if !WinExist(RobloxWindow) {
        MsgBox("Roblox window not found")
        Gdip_Shutdown(pToken)
        return
    }
    
    ; Get the position and size of the UI window
    WinGetPos(&UIX, &UIY, &UIWidth, &UIHeight, UIWindow)
    
    ; Capture the UI area
    pBitmap := Gdip_BitmapFromScreen(UIX . "|" . UIY . "|" . UIWidth . "|" . UIHeight)
    
    if !pBitmap {
        MsgBox("Failed to capture the screen")
        Gdip_Shutdown(pToken)
        return
    }

    ; Read stats from the text files


    ; Default values
    wins := 0
    losses := 0

  


    ; Read total time usage and convert to HH:MM:SS
   

    ; Prepare the attachment and embed
    attachment := AttachmentBuilder(pBitmap)
    myEmbed := EmbedBuilder()
        .setAuthor({ name: "MangoGuards", icon_url: "https://cdn.discordapp.com/attachments/1342045511175376962/1342714291089969202/mango.png?ex=67c28ca1&is=67c13b21&hm=d0cbfa9458dcb435d4d9256446f70a22bccbf61bf2ae700237dabaac8a0841b8&"})
        .setTitle("Completed Map")
        .setDescription("**Wins:** " wins " | **Losses:** " losses "")
        .setColor(0xFFBF34)
        .setImage(attachment)
        .setFooter({ text: "MangoGuards" })
        .setTimeStamp()

    ; Assign a value to UserIDSent
    UserIDSent := ""

    ; Send the webhook
    webhook.send({
        content: UserIDSent,
        embeds: [myEmbed],
        files: [attachment]
    })

    ; Clean up resources
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
}



CropImage(pBitmap, x, y, width, height) {
    croppedBitmap := Gdip_CreateBitmap(width, height)
    if !croppedBitmap
        return 0
    g := Gdip_GraphicsFromImage(croppedBitmap)
    Gdip_DrawImage(g, pBitmap, 0, 0, width, height, x, y, width, height)
    Gdip_DeleteGraphics(g)
    return croppedBitmap
}

InitiateWebhook() {
    ; Get the correct path - remove the duplicate "libs\"
    filePath := A_ScriptDir . "\libs\settings\webhook.txt"
    
    ; Check if directory exists, create if it doesn't
    fileDir := A_ScriptDir . "\libs\settings"
    if !DirExist(fileDir)
        DirCreate(fileDir)
    
    ; Use try/catch to handle file errors
    try {
        global WebhookURL := FileRead(filePath, "UTF-8")
    } catch as err {
        MsgBox("Error reading webhook file: " . err.Message . "`n`nCreating empty file at:`n" . filePath)
        ; Create the file if it doesn't exist
        try {
            FileAppend("", filePath)
            global WebhookURL := ""
        } catch as writeErr {
            MsgBox("Failed to create webhook file: " . writeErr.Message)
            return
        }
    }
    
    if (WebhookURL = "") {
        return
    }

    ; Updated regex to be more flexible with webhook URLs
    if (WebhookURL ~= 'i)https?:\/\/discord\.com\/api\/webhooks\/\d{17,19}\/[\w-]+') {
        global webhook := WebHookBuilder(WebhookURL)
    } else {
        MsgBox("Invalid webhook URL format")
    }
}

InitiateWebhook()


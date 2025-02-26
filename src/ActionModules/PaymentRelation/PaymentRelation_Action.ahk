class PaymentRelation_Action {
    static isRunning := false

    static start() {
        this.isRunning := true
        HotIf (*) => this.isRunning
        Hotkey("F12", (*) => this.end(), "On")

        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"
        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true
    }
    
    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
    }

    static USE(formData := "") {
        if (!formData) {
            this.pasteInfo()
            return
        }
        
        form := JSON.parse(JSON.stringify(formData))
        if (!form["pfRoom"] || !form["pfName"]) {
            return
        }

        ; pf <-> pb 2-room pair
        if (!form["party"]) {
            this.start() 
            ; pf
            res := this.search(form["pfRoom"])
            if (res != "not found") {
                A_Clipboard := Format("P/F Rm{1} {2}  ", form["pbRoom"], IsNumber(form["pbName"]) ? "#" . form["pbName"] : form["pbName"])
                this.pasteInfo(true)
                utils.waitLoading()
                if (!this.isRunning) {
                    msgbox("脚本已终止", popupTitle, "4096 T1")
                    return
                }
            }

            ; pb
            res := this.search(form["pbRoom"])
            if (res != "not found") {
                utils.waitLoading(true)
                A_Clipboard := Format("P/B Rm{1} {2}  ", form["pfRoom"], IsNumber(form["pfName"]) ? "#" . form["pfName"] : form["pfName"])
                this.pasteInfo()
            }

            this.end()
            return
        }

        ; party, pf -> multiple pb rooms
        if (form["party"]) {
            this.start()
            ; pf
            res := this.search(form["pfRoom"])
            if (res == "not found") {
                this.end()
                return
            }

            pfMessage := Format("P/F Party#{1}, total {2}-rooms  ", form["party"], form["partyRoomQty"])
            pbMessage := Format("P/B Rm{1} {2}  ", form["pfRoom"], IsNumber(form["pfName"]) ? "#" . form["pfName"] : form["pfName"])
            A_Clipboard := pfMessage
            this.pasteInfo(true)
            if (!this.isRunning) {
                msgbox("脚本已终止", popupTitle, "4096 T1")
                return
            }



            ; pbs
            loop form["partyRoomQty"] {
                this.search(" ", form["party"])
                ; sort main folio rooms
                Click 838, 378, "Right" 
                Sleep 200
                Send "{Down}"
                Sleep 200
                Send "{Enter}"
                utils.waitLoading() 
                if (!this.isRunning) {
                    msgbox("脚本已终止", popupTitle, "4096 T1")
                    return
                }

                ; select target room sequencially
                loop (A_Index - 1) {
                    Send "{Down}"
                    utils.waitLoading()
                }

                this.pasteInfo(true, pfMessage, pbMessage)
                if (!this.isRunning) {
                    msgbox("脚本已终止", popupTitle, "4096 T1")
                    return
                }
            }

            this.end()
        }
    }

    static search(roomNum := "", party := "") {
        formattedRoom := StrLen(roomNum) == 3 ? "0" . roomNum : roomNum

        Send "!r" ; room number field
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        Send "{Text}" . formattedRoom
        utils.waitLoading()

        if (party) {
            loop 16 {
                Send "{Tab}"
                Sleep 10
            }
            Send "{Text}" . party
            utils.waitLoading()
        }

        Send "!h" ; alt+h => search
        utils.waitLoading()

        CoordMode "Pixel", "Screen"
        if (ImageSearch(&_, &_ ,0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\src\assets\info.PNG")) {
            Send "{Enter}"
            return "not found"
        }

        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        ; sort by Prs.
        if (!party) {
            Click 838, 378, "Right" 
            Sleep 200
            Send "{Down}"
            Sleep 200
            Send "{Enter}"
            utils.waitLoading() 
        }

        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }
    }

    static pasteInfo(keepGoing := false, pfMessage := "", pbMessage := "", initX := 759, initY := 266) {
        this.start()

        commentPos := (A_OSVersion = "6.1.7601")
            ? "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\QM2-for-FrontDesk-main\src\assets\commentWin7.PNG"
            : "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\QM2-for-FrontDesk-main\src\assets\comment.PNG"

        if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, commentPos)) {
            anchorX := FoundX
            anchorY := FoundY
            ; open comment
            MouseMove anchorX + 1, anchorY + 1
            Click
        } else {
            ; open reservation click
            Send "{Enter}"
            utils.waitLoading()
            
            ; check if alert is on top
            loop {
                ; if there is a alert box
                if (PixelGetColor(551, 421) != "0xFFFFFF") {
                    break
                }

                Send "{Enter}"
                Sleep 250
            }

            ; open comment
            MouseMove 949, 599
            utils.waitLoading()
            Click
            utils.waitLoading()
        }

        Sleep 100
        Send "!e"
        Sleep 200

        ; check if this is the pf room
        if (pfMessage) {
            MouseMove 581, 541
            Sleep 100
            Click 3
            Sleep 100
            Send "^c"
            Sleep 100

            if (A_Clipboard.includes(pfMessage)) {
                loop 2 {
                    Send "!c"
                    utils.waitLoading()
                }

                if (!IsSet(anchorX)) {
                    Send "!o"
                    utils.waitLoading()
                }

                A_Clipboard := ""
                return 
            }
        }

        if (pbMessage) {
            A_Clipboard := pbMessage
        }
        Send "{Up}"
        Sleep 150
        Send "^v"
        Sleep 150
        Send "!o"
        Sleep 100
        Send "!c"
        Sleep 100

        ; when ImageSearch of comment flag fails, hence, comment edited in reservation window
        if (!IsSet(anchorX)) {
            Send "!o"
            utils.waitLoading()
        }

        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        Send "!t"
        MouseMove initX, initY ; 759, 266
        Sleep 200
        Click
        Send "!n"
        Sleep 200
        Send "{Text}OTH"
        MouseMove initX - 242, initY + 133 ; 517, 399
        Sleep 100
        Click
        MouseMove initX - 280, initY + 169 ; 479, 435
        Sleep 100
        Click
        MouseMove initX - 70, initY + 211 ; 689, 477
        Sleep 100
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        Click "Down"
        MouseMove initX - 62, initY + 211 ; 697, 477
        Sleep 100
        Click "Up"
        Sleep 100
        Send "^v"
        Sleep 150
        Send "!o"
        Sleep 400
        Send "!c"
        Sleep 200
        Send "!c"
        Sleep 200
        BlockInput false

        ( !keepGoing && this.end() )
    }
}
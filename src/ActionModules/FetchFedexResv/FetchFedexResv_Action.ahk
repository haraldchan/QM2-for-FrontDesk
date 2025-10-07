class FetchFedexResv_Action {
    static isRunning := false

    static start() {
		this.isRunning := true
		HotIf (*) => this.isRunning
		Hotkey("F12", (*) => this.end(), "On")

        CoordMode "Pixel", "Screen"
        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true
    }

    static end() {
		this.isRunning := false
		Hotkey("F12", "Off")

		BlockInput false
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
    }

    static USE(roomNum, confNum) {
        this.start()

        crew := OrderedMap(
            "name", "",         ; profile
            "roomNum", roomNum, ; resv-room
            "confNum", confNum, ; input
            "trip", "",         ; TA Rec loc
            "roomQty", "",      ; nil
            "ibCode", "",       ; more fields
            "ibNum", "",        ; more fields
            "arr", "",          ; more fields
            "ETA", "",          ; more fields
            "stayHours", "",    ; more fields
            "dep", "",          ; more fields
            "ETD", "",          ; more fields
            "obCode", "",       ; more fields
            "obNum", ""         ; more fields
        )

        ; open reservation
        Send "!r"
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

        ; get crewname
        name := this.getCrewName()
        crew["name"] := name[1] . " " . name[2]
        utils.waitLoading()
		if (!this.isRunning) {
			msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
			return
		}    

        ; get trip number
        crew["trip"] := this.getTripNum()
        utils.waitLoading()
		if (!this.isRunning) {
			msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
			return
		}

        ; open More Fields panel
        Send "!i"
        utils.waitLoading()
		if (!this.isRunning) {
			msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
			return
		}

        ; inbound
        inbound := this.getMoreFieldsValue(6)
        crew["ibCode"] := SubStr(inbound, 1, 2)
        crew["ibNum"] := SubStr(inbound, 3)
        Sleep 100

        ; arr
        arr := StrSplit(this.getMoreFieldsValue(2), "-")
        crew["arr"] := arr[1] . "/" . arr[2]

        ; ETA
        crew["ETA"] := this.getMoreFieldsValue(1)

        ; outbound
        outbound := this.getMoreFieldsValue(4)
        crew["obCode"] := SubStr(outbound, 1, 2)
        crew["obNum"] := SubStr(outbound, 3)

        ; dep
        dep := StrSplit(this.getMoreFieldsValue(2), "-")
        crew["dep"] := dep[1] . "/" dep[2]

        ; ETD
        crew["ETD"] := this.getMoreFieldsValue(1)

        Send "!o"
        utils.waitLoading()
		if (!this.isRunning) {
			msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
			return
		}

        mins := DateDiff(
            "20" . dep[3] . dep[1] . dep[2] . StrReplace(crew["ETD"], ":", ""),
            "20" . arr[3] . arr[1] . arr[2] . StrReplace(crew["ETA"], ":", ""),
            "M"
        )

        h := Floor(mins / 60)
        m := mins - (60 * h)
        crew["stayHours"] := h . ":" . (m < 10 ? "0" . m : m)

        cell := ""
        for k, v in crew {
            cell .= v . "`t"
        }

        A_Clipboard := cell

        Send "!o"
        utils.waitLoading()

        this.end()
        MsgBox("已复制订单信息，请到 Sign-In Sheet FullName 处粘贴", , "4096 T1")
    }

    static getCrewName() {
        ; Send "!p"
        loop 10 {
            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-active-win.PNG"])) {
                anchorX := FoundX + 270
                anchorY := FoundY + 36
                break
            }
            Sleep 100
        }

        MouseMove anchorX, anchorY
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "^c"
        Sleep 100
        lastname := A_Clipboard

        Send "{Tab}"
        Send "^c"
        Sleep 100
        firstname := A_Clipboard

        Send "!o"
        utils.waitLoading()

        return [firstname, lastname]
    }

    static getTripNum() {
        loop 10 {
            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["opera-active-win.PNG"])) {
                anchorX := FoundX + 718
                anchorY := FoundY + 376
                break
            } else {
                loop 5 {
                    Send "{Enter}"
                }
                Send "!i"
                Send "!c"
                utils.waitLoading()
            }
            Sleep 100
        }

        MouseMove anchorX, anchorY
        Click 3
        Sleep 200
        Send "^c"
        Sleep 200

        recLocField := StrSplit(A_Clipboard, (InStr(A_Clipboard, "  ") ? "  " : " "))
        tripNum := recLocField.Length > 1 ? recLocField[2] : ""

        return tripNum
    }

    static getMoreFieldsValue(step) {
        loop step {
            Send "{Tab}"
        }
        Sleep 100
        Send "^c"
        Sleep 100

        return A_Clipboard
    }
}
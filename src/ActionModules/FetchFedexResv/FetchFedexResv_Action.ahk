class FetchFedexResv_Action {
    static AnchorImage := A_ScriptDir . "\src\Assets\AltNameAnchor.PNG"

    static USE(roomNum, confNum) {        
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

        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        CoordMode "Pixel", "Screen"

        ; open reservation
        Send "!r"
        utils.waitLoading()

        ; check if alert is on top
        loop {
            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.AnchorImage)) {
                break
            } 

            Send "{Enter}"
            Sleep 250
        }
        
        ; get crewname
        name := this.getCrewName()
        crew["name"] := name[1] . " " . name[2]
        utils.waitLoading()
        
        ; get trip number
        crew["trip"] := this.getTripNum()
        utils.waitLoading()

        ; open More Fields panel
        Send "!i"
        utils.waitLoading()

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

        MsgBox("已复制订单信息，请到 Sign-In Sheet FullName 处粘贴",,"4096 T1")
    }

    static getCrewName() {
        ; Send "!p"
        loop 10 {
            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.AnchorImage)) {
                anchorX := FoundX - 20
                anchorY := FoundY 
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
            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.AnchorImage)) {
                anchorX := FoundX + 441
                anchorY := FoundY + 345
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

        return Trim(StrSplit(A_Clipboard, (InStr(A_Clipboard, "  ") ? "  " : " "))[2])
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

class PsbBatchCheckout_Action {
    static USE(departedRooms) {
        if (!WinExist("ahk_class 360se6_Frame")) {
            MsgBox("请先打开 360 浏览器/ 旅业二期！", "批量上报", "4096 T2")
            return
        }

        this.checkoutBatch(departedRooms)
    }

    static saveDeps(frTime := "00:00", toTime := "23:59") {
        MouseMove 490, 363
        Sleep 100
        Click 3
        Sleep 100
        Send Format("{Text}{1}", frTime)
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", toTime)
        Sleep 100
        loop 7 {
            Send "{Tab}"
            Sleep 100
        }
        Send "{Space}"
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send "{Space}"

        return FormatTime(A_Now, "yyyyMMdd") . " - departure"
    }

    static getDepartedRooms(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)

        departedGuests := []
        roomElements := xmlDoc.getElementsByTagName("ROOM")
        nameElements := xmlDoc.getElementsByTagName("GUEST_NAME")

        loop roomElements.Length {
            roomNum := roomElements[A_Index - 1].ChildNodes[0].nodeValue
            name := nameElements[A_Index - 1].ChildNodes[0].nodeValue

            departedGuests.Push({ roomNum: Integer(roomNum), name: name })
        }

        xmlDoc := ""

        return departedGuests
    }


    static checkoutBatch(departedRooms) {
        deps := departedRooms.map(item => item["roomNum"])
        js := Format(FileRead(A_ScriptDir . "\src\ActionModules\PsbBatchCheckout\batch-checkout-snippets.js", "UTF-8"), JSON.stringify(deps))

        WinActivate("ahk_class 360se6_Frame")
        Send "^+j"
        Sleep 1000

        Send "允许粘贴"
        Send "{Enter}"
        Sleep 1000

        prevClb := A_Clipboard
        A_Clipboard := js
        Send "^v"
        Sleep 1000
        Send "{Enter}"

        A_Clipboard := prevClb
    }
}
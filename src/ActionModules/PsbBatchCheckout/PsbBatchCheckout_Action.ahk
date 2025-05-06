class PsbBatchCheckout_Action {
    static db := useFileDB({
        main: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow" . "\src\ActionModules\ProfileModifyNext\GuestProfiles",
        archive: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow" . "\src\ActionModules\ProfileModifyNext\GuestProfilesArchive",
    })

    static USE(departedRooms) {
        if (!WinExist("ahk_class 360se6_Frame")) {
            MsgBox("请先打开 360 浏览器/ 旅业二期！", "批量上报", "4096 T2")
            return
        }

        this.checkoutBatch(departedRooms)
    }

    static saveDeps(frTime := "00:00", toTime := "23:59") {
        loop 6 {
            Send "{Tab}"
            Sleep 100
        }
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

    static createLookup() {
        lookup := Map()

        loop 7 {
            for guest in this.db.load(, FormatTime(DateAdd(A_Now, 1 - A_Index, "Days"), "yyyyMMdd"), 60 * 24 * 30) {
                ; fmtName := guest["name"].replace("👤", "").replace(",", "").replace(" ", "").toLower()
                fmtName := guest["name"].replaceThese(["👤", ",", " "], "").toLower()
                lookup[fmtName] := guest["idNum"]
            }
        }

        return lookup
    }

    static getDepartedRooms(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)

        departedGuests := []
        matchFailedGuests := []
        regHanzi := "U)[\x{4E00}-\x{9FFF}]+" ; match hanzi name

        lookup := this.createLookup()
        roomElements := xmlDoc.getElementsByTagName("G_ROOM")

        loop roomElements.Length {
            thisGuest := {
                name: "",
                roomNum: "",
                idNum: ""
            }

            nameField := roomElements[A_Index - 1].selectSingleNode["GUEST_NAME"].text
            roomField := roomElements[A_Index - 1].selectSingleNode["ROOM"].text
            separator := nameField.includes(",Mr") ? ",Mr" : ",Ms"

            fullName := RegExMatch(nameField, regHanzi)
                ? nameField.substr(RegExMatch(nameField, regHanzi))
                : nameField.replace("*", "").split(separator)[1].replace(",", ", ")

            thisGuest.name := fullName
            thisGuest.roomNum := Integer(roomField)

            try {
                ; thisGuest.idNum := lookup[fullName.replace(",", "").replace(" ", "").toLower()]
                thisGuest.idNum := lookup[fullName.replaceThese([",", " "], "").toLower()]
                departedGuests.Push(thisGuest)
            } catch {
                if (!matchFailedGuests.find(guest => guest.name == thisGuest.name)) {
                    matchFailedGuests.Push(thisGuest)
                }
            }
        }

        xmlDoc := ""
        return [departedGuests, matchFailedGuests]
    }

    static saveActLog(userCode) {
        fileName := FormatTime(A_Now, "yyyyMMdd") . "-" . userCode

        loop 3 {
            Send "{Tab}"
            Sleep 100
        }

        ; select "Activity Type: Check Out"
        loop 27 {
            Send "{Left}"
        }
        utils.waitLoading()

        ; enter field "Acitivity By"
        ;TODO: check flow. find out how to input multiple user
        Send "{Tab}"
        utils.waitLoading()
        Send "{Text}" . userCode.replace(" ", ",")

        return fileName
    }

    static getDepartedRoomFromActLog(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)

        actElements := xmlDoc.getElementsByTagName("ACTION_DESCRIPTION")

        roomNums := []
        loop actElements.Length {
            room := Integer(actElements[A_Index - 1].text.split(" Room = ")[2].substr(1, 4))
            roomNums.Push(room)
        }

        return roomNums
    }


    static checkoutBatch(departedRooms) {
        deps := departedRooms
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
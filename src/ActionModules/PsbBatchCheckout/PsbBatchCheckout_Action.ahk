class PsbBatchCheckout_Action {
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

    static getDepartedRooms(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)

        departedGuests := []
        regHanzi := "U)[\x{4E00}-\x{9FFF}]+" ; match hanzi name
        db := useFileDB({
            main: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow" . "\src\ActionModules\ProfileModifyNext\GuestProfiles",
            archive: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow" . "\src\ActionModules\ProfileModifyNext\GuestProfilesArchive",
        })

        guestsArrivedToday := db.load(,, 60 * 24) ; pre-load on day data for faster loop
        roomElements := xmlDoc.getElementsByTagName("G_ROOM")

        loop roomElements.Length {
            thisGuest := {}

            ; nameField := nameElements[A_Index - 1].ChildNodes[0].nodeValue
            nameField := roomElements[A_Index - 1].selectSingleNode["GUEST_NAME"].value
            roomField := roomElements[A_Index - 1].selectSingleNode["ROOM"].value

            fullName := RegExMatch(nameField, regHanzi)
                ? SubStr(nameField, RegExMatch(nameField, regHanzi))
                : nameField.replace("*", "").split(",M")[1].replace(",", ", ")

            thisGuest.name := fullName
            thisGuest.roomNum := Integer(roomField)

            
            loop 7 { ; check previous 7-day archives
                guests := A_Index == 1 
                    ? guestsArrivedToday 
                    : db.load(, FormatTime(DateAdd("20250418", 1 - A_Index, "Days"), "yyyyMMdd"), 60 * 24 * 30)
                
                for guest in guests {
                    ; non-hanzi name
                    if (fullName.includes(", ")) {
                        fullNameSplitted := fullName.split(", ")
                        guestNameSplitted := guest["name"].split(", ")

                        if (
                            (fullNameSplitted[1].includes(guestNameSplitted[1]) || guestNameSplitted[1].includes(fullNameSplitted[1]))
                            && (fullNameSplitted[2].includes(guestNameSplitted[2]) || guestNameSplitted[2].includes(fullNameSplitted[2]))
                        ) {
                            thisGuest.idNum := guest["idNum"]
                            break
                        }

                    ; hanzi name
                    } else {
                        if (guest["name"] == fullName) {
                            thisGuest.idNum := guest["idNum"]
                            break
                        }
                    }
                }

                if (thisGuest.HasOwnProp("idNum")) {
                    departedGuests.Push(thisGuest)
                    break
                }
            }

        }

        xmlDoc := ""

        return departedGuests
    }

    static saveActLog(userCode) {
        fileName := FormatTime("20250125", "yyyyMMdd") . "-" . userCode

        Send "01252025"
        Send "{Tab}"
        Send "01252025"
        Send "{Tab}"

        ; select "Activity Type: Check Out"
        loop 1 {
            Send "{Tab}"
            utils.waitLoading()
        }
        loop 27 {
            Send "{Left}"
        }
        utils.waitLoading()

        ; enter field "user"
        ;TODO: check flow. find out how to input multiple user

        return fileName
    }

    static getDepartedRoomFromActLog(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)

        actElements := xmlDoc.getElementsByTagName("ACTION_DESCRIPTION")

        roomNums := []
        loop actElements.Length {
            actDesc := StrSplit(actElements[A_Index - 1].ChildNodes[0].nodeValue, " ")
            if (actDesc[1] == 1) {
                continue
            }

            room := Integer(actDesc[actDesc.findIndex(chunk => chunk == "room") + 1])
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
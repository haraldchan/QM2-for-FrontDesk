class PsbBatchCheckout_Action {
    static USE() {

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
        prevRoomNum := ""

        loop roomElements.Length {
            roomNum := roomElements[A_Index - 1].ChildNodes[0].nodeValue
            name := nameElements[A_Index - 1].ChildNodes[0].nodeValue
            if (roomNum == prevRoomNum) {
                continue
            }

            prevRoomNum := roomNum
            departedGuests.Push({ roomNum: Integer(roomNum), name: name })
        }

        xmlDoc := ""

        return departedGuests
    }

    static checkoutBatch() {

    }
}
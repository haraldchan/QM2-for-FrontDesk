class PsbBatchCheckout_Action {
    static USE() {

    }

    static saveDeps(reportMaster, frTime := "00:00", toTime := "23:59") {
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
    }

    static getDepartedRooms(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)

        departedGuests := []
        roomElements := xmlDoc.getElementsByTagName("ROOM")

        loop roomElements.Length {
            roomNum := roomElements[A_Index - 1].ChildNodes[0].nodeValue
            departedGuests.Push(roomNum)
        }

        xmlDoc := ""

        return departedGuests.unique()
    }

    static checkoutBatch() {

    }
}
class BatchKeysXl_Action {
    static isRunning := false

    static start() {
        this.isRunning := true
        HotIf (*) => this.isRunning
        Hotkey("F12", (*) => this.end(), "On")

        CoordMode "Mouse", "Window"
        WinActivate "ahk_exe vision.exe"
        BlockInput true
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        CoordMode "Mouse", "Screen"
        BlockInput false
    }

    static USE(xlPath, coDateTime, enable28f, useDeskTopXl := false) {
        if (useDeskTopXl) {
            if (FileExist(A_Desktop . "\GroupKeys.xls")) {
                path := A_Desktop . "\GroupKeys.xls"
            } else if (FileExist(A_Desktop . "\GroupKeys.xlsx")) {
                path := A_Desktop . "\GroupKeys.xlsx"
            } else {
                MsgBox("对应 Excel表：GroupKeys.xls并不存在！`n 请先创建或复制文件到桌面！", "Batch Keys")
                return
            }
        } else {
            path := xlPath
        }

        coDateTimeFromInput := [FormatTime(coDateTime, "ShortDate"), FormatTime(coDateTime, "HH:mm")]

        Xl := ComObject("Excel.Application")
        GroupKeysXl := Xl.Workbooks.Open(path)
        groupRooms := GroupKeysXl.Worksheets[1]
        lastRow := groupRooms.Cells(groupRooms.Rows.Count, "A").End(-4162).Row

        roomingList := this.getRoomingList(lastRow, groupRooms)
        co := this.getCheckoutDateTimeXls(lastRow, groupRooms)
        coDateXls := co[1]
        coTimeXls := co[2]

        GroupKeysXl.Close()
        Xl.Quit()

        loop lastRow {
            this.start() 

            room := roomingList[A_Index]

            coDate := !coDateXls[A_Index] ? coDateTimeFromInput[1] : coDateXls[A_Index]   
            etd := !coTimeXls[A_Index] ? coDateTimeFromInput[2] : coTimeXls[A_Index]

            this.makeKey(room, coDate, etd, enable28f)
            BlockInput false
            checkConf := MsgBox(Format("
                (
                    已做房卡：{1}
                    {2}
                    - 是(Y)制作下一个
                    - 否(N)退出制卡
                    {3}
                )",
                room,
                A_Index + 1 <= roomingList.Length ? Format("下一房号：{1}`n", roomingList[A_Index + 1]) : "",
                A_Index == roomingList.Length ? "`n房卡已全部制作完成，请再次核对确保无误" : ""
            ), "Batch Keys", "YesNo 4096")

            if (checkConf = "No") {
                return
            }
            BlockInput true

            this.end()
        }
    }

    /**
     * Returns two arrays: [coDateRead, coTimeRead]
     * @param lastRow - last row number
     * @param sheet - excel sheet object
     * @returns {[]Array} - [coDateRead, coTimeRead]
     */
    static getCheckoutDateTimeXls(lastRow, sheet) {
        coDateRead := []
        coTimeRead := []
        loop lastRow {
            coDateRead.Push(sheet.Cells(A_Index, 2).Text ? sheet.Cells(A_Index, 2).Text : "")
            coTimeRead.Push(sheet.Cells(A_Index, 3).Text ? sheet.Cells(A_Index, 3).Text : "")
        }

        return [coDateRead, coTimeRead]
    }

    /**
     * Returns an array of room numbers from the first column
     * @param lastRow - last row number
     * @param sheet - excel sheet object
     * @returns {Array} - room numbers array 
     */
    static getRoomingList(lastRow, sheet) {
        roomNums := []
        loop lastRow {
            roomNums.Push(sheet.Cells(A_Index, 1).Text)
        }

        return roomNums
    }

    static makeKey(room, coDate, etd, enable28f) {
        ; send room number
        A_Clipboard := room
        MouseMove 168, 196
        Click 3
        Sleep 150
        Send "^v" ; room num can only be pasted
        Sleep 150

        ; send check out date
        MouseMove 173, 363
        Sleep 150
        Click "Down"
        MouseMove 7, 363
        Sleep 150
        Click "Up"
        Sleep 100
        Send "{Text}" . coDate
        Sleep 150

        ; send check out time
        Send "{Tab}"
        Sleep 100
        Send "{Text}" . etd
        Sleep 150

        ; enable 28f
        if (enable28f != 0) {
            loop 2 {
                Send "{Tab}"
                Sleep 50
            }
            loop 2 {
                Send "{Down}"
                Sleep 50
            }
            Send "{Space}"
            Sleep 50
            Send "{Tab}"
            Sleep 150
        } else {
            loop 3 {
                Send "{Tab}"
                Sleep 50
            }
        }

        ; send number of cards
        Send "2"
        Sleep 150

        ; make
        Send "!e"
        Sleep 150
    }
}


class BatchKeysSq_Action {
    static isRunning := false

    static start() {
        this.isRunning := true
        HotIf (*) => this.isRunning
        Hotkey("F12", (*) => this.end(), "On")

        CoordMode "Mouse", "Window"
        WinActivate "ahk_exe vision.exe"
        BlockInput true
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        CoordMode "Mouse", "Screen"
        BlockInput false
    }

    static USE(formData) {
        this.start()
        
        for room in formData.rooms {
            this.makeKey(room, formData.coDate, formData.etd, formData.confNum, formData.enable28f)
            BlockInput false
            checkConf := MsgBox(Format("
                (
                    已做房卡：{1}
                    {2}
                    - 是(Y)制作下一个
                    - 否(N)退出制卡
                    {3}
                )",
                room,
                A_Index + 1 <= formData.rooms.Length ? Format("下一房号：{1}`n", formData.rooms[A_Index + 1]) : "",
                A_Index == formData.rooms.Length ? "`n房卡已全部制作完成，请再次核对确保无误" : ""
            ), "Batch Keys", "YesNo 4096")

            if (checkConf = "No") {
                return
            }
            BlockInput true
        }
        
        this.end()
    }

    static makeKey(room, coDate, etd, confNum, enable28f) {
        ; send confNum
        A_Clipboard := confNum
        Send "^{Tab}"
        Sleep 150
        Send "^v"
        Sleep 100
        loop 2 {
            Send "^{Tab}"
            Sleep 100
        }

        ; send room number
        A_Clipboard := room
        MouseMove 168, 196
        Click 3
        Sleep 150
        Send "^v" ; room num can only be pasted
        Sleep 150

        ; send check out date
        MouseMove 173, 363
        Sleep 150
        Click "Down"
        MouseMove 7, 363
        Sleep 150
        Click "Up"
        Sleep 100
        Send "{Text}" . coDate
        Sleep 150

        ; send check out time
        Send "{Tab}"
        Sleep 100
        Send "{Text}" . etd
        Sleep 150

        ; enable 28f
        if (enable28f != 0) {
            loop 2 {
                Send "{Tab}"
                Sleep 50
            }
            loop 2 {
                Send "{Down}"
                Sleep 50
            }
            Send "{Space}"
            Sleep 50
            Send "{Tab}"
            Sleep 150
        } else {
            loop 3 {
                Send "{Tab}"
                Sleep 50
            }
        }

        ; send number of cards
        Send "2"
        Sleep 150

        ; make
        Send "!e"
    }
}

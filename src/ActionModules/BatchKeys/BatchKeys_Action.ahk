class BatchKeysXl_Action {
    static USE(xlPath, useDeskTopXl := false) {
        if (useDeskTopXl = true) {
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

        infoFromInput := this.getCheckoutInput()
        if (infoFromInput = "") {
            return
        }

        Xl := ComObject("Excel.Application")
        GroupKeysXl := Xl.Workbooks.Open(path)
        groupRooms := GroupKeysXl.Worksheets[1]
        lastRow := groupRooms.Cells(groupRooms.Rows.Count, "A").End(-4162).Row

        roomingList := this.getRoomingList(lastRow, groupRooms)
        infoFromXls := this.getCheckoutXls(lastRow, groupRooms)

        GroupKeysXl.Close()
        Xl.Quit()

        this.makeKey(lastRow, roomingList, infoFromInput, infoFromXls)
    }

    static getCheckoutInput() {
        start := MsgBox("
        (
            即将进行批量团卡制作，启动前请先完成以下准备工作：

            1、请先保存需要制卡的团Rooming List；

            2、将Rooming List的房号录入“GroupKeys.xls”文件的第一列；

            - 如需单独修改某个房间的退房日期、时间，请分别填入GroupKeys.xls的第二、第三列
            - 日期格式：yyyyMMdd，如 “20240101”
            - 时间格式：HH:MM，如 “13:00”
        
            3、确保VingCard已经打开处于Check-in界面。
        )", "Batch Keys", "OKCancel 4096")

        if (start = "Cancel") {
            return
        }

        coDateInput := InputBox("请输入退房日期：`n(yyyymmdd，如20240101)", "Batch Keys", , FormatTime(DateAdd(A_Now, 1, "Days"), "yyyyMMdd")).Value
        coDateInputFormatted := FormatTime(coDateInput, "ShortDate")
        coTimeInput := InputBox("请输入退房时间：`n(格式为HH:MM)", "Batch Keys", , "13:00").Value

        infoConfirm := MsgBox(Format("
            (
            当前团队制卡信息：
            退房日期：{1}
            退房时间：{2}
            )", coDateInputFormatted, coTimeInput), "GroupKey", "OKCancel")
        if (infoConfirm = "Cancel") {
            utils.cleanReload(winGroup)
        }

        return [coDateInputFormatted, coTimeInput]
    }

    static getCheckoutXls(lastRow, sheet) {
        coDateRead := []
        coTimeRead := []
        loop lastRow {
            sheet.Cells(A_Index, 2).Text = ""
                ? coDateRead.Push("blank")
                : coDateRead.Push(sheet.Cells(A_Index, 2).Text)
            sheet.Cells(A_Index, 3).Text = ""
                ? coTimeRead.Push("blank")
                : coTimeRead.Push(sheet.Cells(A_Index, 3).Text)
        }

        return [coDateRead, coTimeRead]
    }

    static getRoomingList(lastRow, sheet) {
        roomNums := []
        loop lastRow {
            roomNums.Push(sheet.Cells(A_Index, 1).Text)
        }

        return roomNums
    }

    static makeKey(lastRow, roomingList, Input, Xls, initX := 387, initY := 409) {
        coDateXls := Xls[1]
        coTimeXls := Xls[2]
        coDateInput := Input[1]
        coTimeInput := Input[2]

        loop lastRow {
            A_Clipboard := roomingList[A_Index]
            coDateLoop := (coDateXls[A_Index] = "blank") ? coDateInput : coDateXls[A_Index]
            coTimeLoop := (coTimeXls[A_Index] = "blank") ? coTimeInput : coTimeXls[A_Index]
            finMsg := A_Index = lastRow ? "`n房卡已全部制作完成，请再次核对确保无误" : ""

            BlockInput true
            MouseMove initX, initY ; 387, 409
            Sleep 300
            Click "Down"
            MouseMove initX - 135, initY ; 252, 409
            Sleep 150
            Click "Up"
            Sleep 150
            Send "^v"
            Sleep 200
            MouseMove initX + 23, initY + 173 ; 410, 582
            Sleep 150
            Click "Down"
            MouseMove initX - 138, initY + 173 ; 249, 582
            Sleep 150
            Click "Up"
            Sleep 100
            Send "{Text}" . coDateLoop
            Sleep 100
            MouseMove initX + 141, initY + 169 ; 528, 578
            Sleep 150
            Click 2
            Sleep 200
            Send "{Text}" . coTimeLoop
            Sleep 100
            MouseMove initX + 112, initY + 333 ; 499, 742
            Sleep 100
            Click 2
            Sleep 100
            Send "{Text}2"
            Sleep 100
            Send "!e"
            Sleep 100
            BlockInput false
            checkConf := MsgBox(Format("
                (
                已做房卡：{1}
                - 是(Y)制作下一个
                - 否(N)退出制卡
                {2}
                )", roomingList[A_Index], finMsg), "Batch Keys", "OKCancel 4096")
            if (checkConf = "Cancel") {
                utils.cleanReload(winGroup)
            }
        }
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
        BlockInput "MouseMove"
    }

    static end() {
        this.isRunning := false
		Hotkey("F12", "Off")

        CoordMode "Mouse", "Screen"
        BlockInput "MouseMoveOff"
    }

    static USE(formData) {
        this.start()

        for room in formData.rooms {
            this.makeKey(room, formData.coDate, formData.etd, formData.confNum, formData.enable28f)
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
                this.end()
                return
            }
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
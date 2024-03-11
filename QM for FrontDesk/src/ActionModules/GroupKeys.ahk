#Include "../../../Lib/Classes/utils.ahk"

class GroupKeys {
    static name := "GroupKeys"
    static description := "团队房卡制作     - Excel表：GroupKeys.xls"
    static popupTitle := "Group Keys"
    static dateDash := "^\d{1,4}-\d{1,2}-\d{1,2}"
    static dateSlash := "\d{4}/\d{2}/\d{2}"
    static scriptHost := SubStr(A_ScriptDir, 1, InStr(A_ScriptDir, "\", , -1, -1) - 1)
    static path := IniRead(this.scriptHost . "\Lib\QM for FrontDesk\config.ini", "GroupKeys", "xlsPath")

    static USE(desktopMode := 0) {
        if (desktopMode = true) {
            if (FileExist(A_Desktop . "\GroupKeys.xls")) {
                path := A_Desktop . "\GroupKeys.xls"
            } else if (FileExist(A_Desktop . "\GroupKeys.xlsx")) {
                path := A_Desktop . "\GroupKeys.xlsx"
            } else {
                MsgBox("对应 Excel表：GroupKeys.xls并不存在！`n 请先创建或复制文件到桌面！", this.popupTitle)
                return
            }
        } else {
            path := this.path
        }

        infoFromInput := this.getCheckoutInput()

        Xl := ComObject("Excel.Application")
        GroupKeysXl := Xl.Workbooks.Open(path)
        groupRooms := GroupKeysXl.Worksheets("Sheet1")
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
            - 日期格式：yyyy-mm-dd 或 yyyy/mm/dd（具体请先查看VingCard中格式）
            - 时间格式：HH:MM
        
            3、确保VingCard已经打开处于Check-in界面。
        )", this.popupTitle, "OKCancel 4096")
        if (start = "Cancel") {
            utils.cleanReload(winGroup)
        }
        loop {
            coDateInput := InputBox("请输入退房日期：`n(格式为yyyy-mm-dd或yyyy/mm/dd)", this.popupTitle).Value
            if (RegExMatch(coDateInput, this.dateDash) > 0
                || RegExMatch(coDateInput, this.dateSlash)
                || coDateInput = "") {
                    break
            } else {
                MsgBox("输入格式必须为yyyy-mm-dd或yyyy/mm/dd，如2023-01-01或2023/01/01。")
                continue
            }
        }
        coTimeInput := InputBox("请输入退房时间：`n(格式为HH:MM)", this.popupTitle, , "13:00").Value

        infoConfirm := MsgBox(Format("
            (
            当前团队制卡信息：
            退房日期：{1}
            退房时间：{2}
            )", coDateInput, coTimeInput), "GroupKey", "OKCancel")
        if (infoConfirm = "Cancel") {
            utils.cleanReload(winGroup)
        }

        return [coDateInput, coTimeInput]
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

        return [coDateRead, coDateRead]
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
                )", roomingList[A_Index], finMsg), this.popupTitle, "OKCancel 4096")
            if (checkConf = "Cancel") {
                utils.cleanReload(winGroup)
            }
        }
    }
}
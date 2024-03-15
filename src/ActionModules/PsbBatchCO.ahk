class PsbBatchCO {
    static name := "PsbBatchCO"
    static description := "旅安系统批量退房 - Excel表：CheckOut.xls"
    static popupTitle := "PSB CheckOut(Batch)"
    static blockingPopups := ["来访提示", "数据验证"]
    static defaultPath := A_ScriptDir . "\Excel\CheckOut.xls"

    static USE(desktopMode := 0) {
        if (desktopMode = true) {
            if (FileExist(A_Desktop . "\CheckOut.xls")) {
                xlPath := A_Desktop . "\CheckOut.xls"
            } else if (FileExist(A_Desktop . "\CheckOut.xlsx")) {
                xlPath := A_Desktop . "\CheckOut.xlsx"
            } else {
                MsgBox("对应 Excel表：CheckOut.xls并不存在！`n 请先创建或复制文件到桌面！", this.popupTitle)
                return
            }
        } else {
            xlPath := this.defaultPath
        }

        textMsg := "
        (
        即将开始批量拍Out 脚本
    
        是(Y) = 保存FO03 - Departures数据文件后开始
        否(N) = 直接开始拍Out（已保存过房号Excel）
        取消 = 退出脚本
        )"
        selector := MsgBox(textMsg, this.popupTitle, "YesNoCancel")
        if (selector = "No") {
            this.batchOut(xlPath)
        } else if (selector = "Yes") {
            this.saveDep(xlPath)
            Sleep 500
            this.batchOut(xlPath)
        } else {
            utils.cleanReload(winGroup)
        }
    }

    static saveDep(path) {
        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        ; save Departures XML
        reportFiling(
        {
            searchStr: "FO03",
            name: "FO03 - Departures",
            saveFn: depForBatchOut
        }, "XML")
        xmlPath := Format(A_MyDocuments . "\{1} - Departures.XML", FormatTime(A_Now, "yyyyMMdd"))
        ; wait for file
        loop 10 {
            Sleep 500
            if (FileExist(xmlPath)) {
                this.xmlToSpreadSheet(xmlPath, path)
                Sleep 100
                Run path
                return
            }
            if (A_Index = 10) {
                MsgBox("保存失败，请重试！",this.popupTitle)
                return
            }
        }

        continueText := "
        (
        请打开蓝豆查看“续住工单”，剔除excel中续住的房间后，点击确定继续拍out。
        完成上述操作前请不要按掉此弹窗。
        )"
        MsgBox(continueText, this.popupTitle, "4096")
    }

    static batchOut(path) {
        autoOut := MsgBox("即将开始自动拍Out脚本`n请先打开PSB，进入“旅客退房”界面", PsbBatchCo.popupTitle, "OKCancel")
        if (autoOut = "Cancel") {
            utils.cleanReload(winGroup)
        }
        Xl := ComObject("Excel.Application")
        CheckOut := Xl.Workbooks.Open(path)
        depRooms := CheckOut.Worksheets("Sheet1")
        lastRow := depRooms.Cells(depRooms.Rows.Count, "A").End(-4162).Row
        depRoomNums := []
        TrayTip "读入房号中……"
        loop lastRow {
            depRoomNums.Push(Integer(depRooms.Cells(A_Index, 1).Text))
        }
        CheckOut.Close()
        Xl.Quit()
        TrayTip "读入完成"

        loop lastRow {
            A_Clipboard := depRoomNums[A_Index]
            MouseMove 282, 205
            Sleep 100
            Click "Right"
            Sleep 100
            Send "a"
            Sleep 100
            Send "^v"
            Sleep 100
            Send "^f"
            Sleep 300
            WinWait("系统确认", , 2)
            Sleep 100
            Send "{Enter}"
            Sleep 1000
            WinWait("提示", , 2)
            Sleep 100
            Send "{Esc}"
            Sleep 100
            if (!WinExist("ahk_class ThunderRT6FormDC")) {
                MsgBox(Format("错误退出！ 最后房号：{1}", A_Clipboard),,"4096")
                return
            }
        }

        Sleep 1000
        MsgBox("PSB 批量拍Out 已完成！", this.popupTitle)
    }

    static winDetectAndClose(targetWins) {
        for winTitle in targetWins {
            if (WinExist(Format("ahk_class {1}", winTitle))) {
                WinClose Format("ahk_class {1}", winTitle)
            }
        }
    }

    static xmlToSpreadSheet(xmlPath, xlPath){
        roomNumbersRead := []
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)
        roomElements := xmlDoc.getElementsByTagName("ROOM")

        for element in roomElements {
            roomNumbersRead.Push(element.ChildNodes[0].nodeValue)
        }
        uniqueRooms := this.getUniqueRoomNums(roomNumbersRead)

        Xl := ComObject("Excel.Application")
        CheckOut := Xl.Workbooks.Open(xlPath)
        depRooms := CheckOut.Worksheets("Sheet1")


        for roomNumber in uniqueRooms {
            depRooms.Cells(A_Index, 1).Value := roomNumber
        }
        CheckOut.Save()
        Xl.Quit()
    }

    static getUniqueRoomNums(roomNumbers) {
        lastRoom := 0
        uniqueRoomNumbers := []
        for room in roomNumbers {
            if (room != lastRoom) {
                uniqueRoomNumbers.Push(room)
            }
            lastRoom := room
        }
        return uniqueRoomNumbers
    }
}
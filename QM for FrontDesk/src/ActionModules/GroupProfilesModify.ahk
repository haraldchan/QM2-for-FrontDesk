#Include "../../../Lib/Classes/utils.ahk"

class GroupProfilesModify {
    static name := "GroupProfilesModify"
    static description := "团队Profile录入  - Excel表：GroupRoomNum.xls"
    static popupTitle := "GroupProfilesModify"
    static scriptHost := SubStr(A_ScriptDir, 1, InStr(A_ScriptDir, "\", , -1, -1) - 1)
    static path := IniRead(this.scriptHost . "\Lib\QM for FrontDesk\config.ini", "GroupProfilesModify", "xlsPath")
    static wwly := this.getWwlyPath()

    static USE(desktopMode := 0, initX := 0, initY := 0) {
        if (desktopMode = true) {
            if (FileExist(A_Desktop . "\GroupRoomNum.xls")) {
                path := A_Desktop . "\GroupRoomNum.xls"
            } else if (FileExist(A_Desktop . "\GroupRoomNum.xlsx")) {
                path := A_Desktop . "\GroupRoomNum.xlsx"
            } else {
                MsgBox("对应 Excel表：GroupRoomNum.xls并不存在！`n 请先创建或复制文件到桌面！", this.popupTitle)
                return
            }
        } else {
            path := this.path
        }
        if (this.wwly = "") {
            MsgBox("没有找到旅业同步系统，请换一台电脑。")
            return
        }
        errorRed := "0x800000"
        gpmStart := MsgBox("
        (
        将开始团队Profile modify
    
        注意事项：
        1、请确保同一个房间内，PSB与Opera客人数量一致（关注一个人、三个人住）
        2、请在InHouse界面下启动
        )", GroupProfilesModify.popupTitle, "OKCancel 4096")
        if (gpmStart = "Cancel") {
            utils.cleanReload(winGroup)
        }

        Xl := ComObject("Excel.Application")
        GroupRoomNum := Xl.Workbooks.Open(path)
        groupRooms := GroupRoomNum.Worksheets("Sheet1")
        lastRow := groupRooms.Cells(groupRooms.Rows.Count, "A").End(-4162).Row
        ; roomNum := Integer(groupRooms.Cells(1, 1).Text)
        row := 1

        ; { tbt: read excel file all at once
        roomNums := []
        loop lastRow {
            roomNums.Push(Integer(groupRooms.Cells(A_Index, 1).Text))
        }
        GroupRoomNum.Close()
        Xl.Quit()
        ; }

        Run this.wwly
        Sleep 5000

        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        BlockInput true
        ; { tbt
        loop lastRow {
            A_Clipboard := roomNums[A_Index]
            Sleep 500
            MouseMove 598, 573
            Sleep 500
            Send "!p"
            Sleep 300
            Send "!n"
            Sleep 200
            MouseMove 666, 545
            Sleep 1000
            Click
            Sleep 3000

            Send "{Pause}"
            WinWait "ahk_class TMAIN"
            WinActivate "ahk_class TMAIN"

            CoordMode "Mouse", "Client"
            MouseMove 400, 23
            Click "Down"
            Sleep 200
            MouseMove 324, 23
            Click "Up"
            Sleep 200
            Send "^v"
            Sleep 200
            Send "{F11}"
            Sleep 300
            Send "{Enter}"
            Sleep 7500
            MouseMove 626, 299
            Sleep 500
            Send "!o"
            Sleep 500
            Send "!o"
            Sleep 2000
            Send "{Down}"
            Sleep 200
            CoordMode "Mouse", "Screen"
            ; stop on error
            ; if (PixelGetColor(698, 306) = errorRed) {
            ;     MsgBox("Modify出错，脚本已终止`n`n已Modify到：" . roomNums[A_Index], this.popupTitle)
            ;     quitOnRoom := A_Clipboard
            ;     IniWrite(quitOnRoom, A_ScriptDir . "\lib\lib\config.ini", "PsbBatchCO", "errorQuitAt")
            ;     Utils.cleanReload(winGroup)
            ; }
        }

        BlockInput false
        Sleep 500
        MsgBox("已Modify 完成，请再次检查是否正确。", this.popupTitle)
    }

    static getWwlyPath() {
        drive := ["C", "D", "E", "F"]
        loop drive.Length {
            wwlyExe := drive[A_Index] . ":\SQL\ww_ly.exe"
            if (FileExist(wwlyExe)) {
                return wwlyExe
            }
        }
    }
}
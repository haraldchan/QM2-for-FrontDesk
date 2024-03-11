#Include "../../../Lib/Classes/utils.ahk"

class GroupShare {
    static description := "旅行团房Share + DoNotMove"
    static popupTitle := "Group Share & DoNotMove"

    static USE(initX := 0, initY := 0) {
        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        Sleep 500
        confirmMsg := MsgBox("
        (
        将开始批量团Share及DoNotMove操作。
    
        运行前请先确认：
            1.Opera窗口已最大化。
            2.界面在RoomAssign。
            3.以Name筛选团房（如使用BlockCode将会出错）
        )", this.popupTitle, "OKCancel 4096")
        If (confirmMsg = "Cancel") {
            utils.cleanReload(winGroup)
        } else {
            roomQty := InputBox("`n请输入需要Share + DNM的房间数量", this.popupTitle, "h150")
            if (roomQty.Result = "Cancel") {
                utils.cleanReload(winGroup)
            }
        }

        this.dnmShare(roomQty.Value)

        Sleep 1000
        MsgBox("已完成DNM & Share共 " . roomQty.Value . " 房，请核对有否错漏。", this.popupTitle, "4096")
    }

    static dnmShare(roomQty, initX := 340, initY := 311) {
        MouseMove initX, initY ; 340, 311
        Sleep 100
        Click "Down"
        MouseMove initX - 158, initY - 1 ; 182, 310
        Sleep 100
        Click "Up"
        MouseMove initX - 40, initY - 4 ; 300, 307
        Sleep 100
        Send "{Backspace}"
        Sleep 100
        Send "{Text}TGDA"
        loop roomQty {
            BlockInput true
            MouseMove initX + 85, initY + 226 ; 425, 537
            Sleep 200
            Send "!r"
            MouseMove initX + 129, initY + 201 ; 469, 512
            Sleep 3000
            Click
            Sleep 700
            Send "!t"
            Sleep 100
            Send "!s"
            Sleep 100
            Send "!m"
            Sleep 100
            Sleep 3000
            Send "{Esc}"
            Sleep 300
            Send "{Text}1"
            Sleep 100
            MouseMove initX + 147, initY + 91 ; 487, 402
            Sleep 100
            Click "Down"
            MouseMove initX + 178, initY + 92 ; 518, 403
            Sleep 200
            Click "Up"
            MouseMove initX + 176, initY + 132 ; 516, 443
            Sleep 200
            Send "{Text}0"
            Sleep 200
            Send "!o"
            Sleep 1000
            Send "!r"
            Sleep 200
            MouseMove  950, 597
            Sleep 2500
            Click
            Sleep 800
            Send "!d"
            Sleep 1000
            Send "{Left}"
            Sleep 150
            Send "{Space}"
            Sleep 500
            Send "!o"
            Sleep 500
            Send "!c"
            Sleep 300
            MouseMove initX - 19, initY + 196 ; 321, 507
            Sleep 1500
            Click "Down"
            MouseMove initX - 154, initY + 198 ; 186, 509
            Sleep 200
            Click "Up"
            Sleep 200
            Send "{Text}NRR"
            Sleep 100
            Send "{Tab}"
            Sleep 500
            loop 5 {
                Send "{Esc}"
                Sleep 200
            }
            Send "!o"
            Sleep 800
            Send "!o"
            Sleep 3000
            Send "!c"
            Sleep 800
            Send "!c"
            Sleep 300
            Send "!c"
            Sleep 5000
            BlockInput false
        }
    }
}
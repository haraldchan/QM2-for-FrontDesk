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
        MsgBox("已完成DNM & Share共 " . roomQty.Value . " 房，请核对有否错漏。", this.popupTitle, "4096 T1")
    }

    static dnmShare(roomQty, initX := 340, initY := 311) {
        MouseMove initX, initY ; 340, 311
        utils.waitLoading()
        Click "Down"
        MouseMove initX - 158, initY - 1 ; 182, 310
        utils.waitLoading()
        Click "Up"
        MouseMove initX - 40, initY - 4 ; 300, 307
        utils.waitLoading()
        Send "{Backspace}"
        utils.waitLoading()
        Send "{Text}TGDA"
        loop roomQty {
            BlockInput true
            MouseMove initX + 85, initY + 226 ; 425, 537
            utils.waitLoading()
            Send "!r"
            MouseMove initX + 129, initY + 201 ; 469, 512
            utils.waitLoading()
            Click
            utils.waitLoading()
            Send "!t"
            utils.waitLoading()
            Send "!s"
            utils.waitLoading()
            Send "!m"
            utils.waitLoading()
            Send "{Esc}"
            utils.waitLoading()
            Send "{Text}1"
            utils.waitLoading()
            MouseMove initX + 147, initY + 91 ; 487, 402
            utils.waitLoading()
            Click "Down"
            MouseMove initX + 178, initY + 92 ; 518, 403
            utils.waitLoading()
            Click "Up"
            MouseMove initX + 176, initY + 132 ; 516, 443
            utils.waitLoading()
            Send "{Text}0"
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            Send "!r"
            utils.waitLoading()
            MouseMove  950, 597
            utils.waitLoading()
            Click
            utils.waitLoading()
            Send "!d"
            utils.waitLoading()
            Send "{Left}"
            utils.waitLoading()
            Send "{Space}"
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()
            MouseMove initX - 19, initY + 196 ; 321, 507
            utils.waitLoading()
            Click "Down"
            MouseMove initX - 154, initY + 198 ; 186, 509
            utils.waitLoading()
            Click "Up"
            utils.waitLoading()
            Send "{Text}NRR"
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            loop 5 {
                Send "{Esc}"
                utils.waitLoading()
            }
            Send "!o"
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()
            BlockInput false
        }
    }
}
#Include "../../../Lib/Classes/utils.ahk"

class DoNotMove {
    static description := "预到房间批量 DoNotMove"
    static popupTitle := "Do Not Move(batch)"

    static USE(initX := 0, initY := 0) {
        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        Sleep 100
        roomQty := InputBox("`n请输入需要DNM的房间数量", this.popupTitle, "h150")
        if (roomQty.Result = "Cancel") {
            utils.cleanReload(winGroup)
        }
        this.dnm(roomQty.Value)
        Sleep 1000
        MsgBox("已完成批量DoNotMove，合共" . roomQty.Value . "房。", this.popupTitle)
    }

    static dnm(roomQty, initX := 696, initY := 614) {
        BlockInput true
        loop roomQty {
            MouseMove initX, initY ; 696, 614
            Sleep 200
            Send "!r"
            Sleep 100
            MouseMove initX - 117, initY - 87 ; 579, 527
            Sleep 2000
            Click
            Sleep 400
            Click
            Sleep 300
            Click
            MouseMove initX - 223, initY - 100 ; 473, 514
            Sleep 500
            Click
            Sleep 700
            Send "!o"
            Sleep 100
        }
        BlockInput false
    }
}
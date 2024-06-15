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
        MsgBox("已完成批量DoNotMove，合共" . roomQty.Value . "房。", this.popupTitle, "4096 T1")
    }

    static dnm(roomQty, initX := 696, initY := 614) {
        BlockInput true
        loop roomQty {
            MouseMove initX, initY ; 696, 614
            utils.waitLoading()
            Send "!r"
            utils.waitLoading()
            MouseMove initX - 117, initY - 87 ; 579, 527
            utils.waitLoading()
            Click
            utils.waitLoading()
            Click
            utils.waitLoading()
            Click
            MouseMove initX - 223, initY - 100 ; 473, 514
            utils.waitLoading()
            Click
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
        }
        BlockInput false
    }
}
class GroupShareDnm_Action {
    static USE(roomQty, ratecode, both, shareOnly, dnmOnly) {
        WinMaximize "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        Sleep 500
        BlockInput true

        if (both = true) {
            this.shareDnm(roomQty, ratecode)
        } else if (dnmOnly = true) {
            this.dnm(roomQty)
        } else {
            this.shareDnm(roomQty, ratecode, shareOnly)
        }

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
    }

    static shareDnm(roomQty, ratecode, shareOnly := false, initX := 340, initY := 311) {
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
        Send Format("{Text}{1}", ratecode)
        loop roomQty {
            BlockInput true
            MouseMove initX + 85, initY + 226 ; 425, 537
            utils.waitLoading()
            Send "!r"

            ; TODO: test if this avoids dnm
            if (shareOnly = false) {
                MouseMove initX + 129, initY + 201 ; 469, 512
                utils.waitLoading()
                Click
                utils.waitLoading()
            }

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
            MouseMove 950, 597
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
            BlockInput false
        }
    }

    static dnm(roomQty, initX := 696, initY := 614) {
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

        Sleep 100
        MsgBox("已完成批量DoNotMove，合共" . roomQty . "房。", "Do Not Move", "4096 T1")
    }
}
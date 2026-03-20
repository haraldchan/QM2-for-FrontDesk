class GroupShareDnm_Action {
    static isRunning := false

    static start() {
        this.isRunning := true
        HotIf((*) => this.isRunning)
        Hotkey("F12", (*) => this.end(), "On")

        WinMaximize("ahk_class SunAwtFrame")
        WinActivate("ahk_class SunAwtFrame")
        Sleep(500)
        WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
        BlockInput(true)
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        BlockInput(false)
        WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
    }

    static USE(form) {
        this.start()

        if (form.shareDnm) {
            this.shareDnm(form.gsdRmQty, form.ratecodeField)
        }

        if (form.shareOnly) {
            this.shareDnm(form.gsdRmQty, form.useRc, true)
        }

        if (form.dnmOnly) {
            this.dnm(form.gsdRmQty)
        }

        if (form.dnmRemove) {
            this.dnm(form.gsdRmQty, true)
        }

        this.end()
    }

    static shareDnm(roomQty, ratecode, shareOnly := false, initX := 340, initY := 311) {
        ; check if Advance panel is opened
        CoordMode("Pixel", "Screen")
        if (PixelGetColor(198, 297) != "0xFFFF00") {
            Send("!a")
            utils.waitLoading()
        }

        MouseMove(initX, initY) ; 340, 311
        utils.waitLoading()
        Click("Down")
        MouseMove(initX - 158, initY - 1) ; 182, 310
        utils.waitLoading()
        Click("Up")
        MouseMove(initX - 40, initY - 4) ; 300, 307
        utils.waitLoading()
        Send("{Backspace}")
        utils.waitLoading()
        Send(Format("{Text}{1}", ratecode))
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        loop roomQty {
            BlockInput(true)
            MouseMove(initX + 85, initY + 226) ; 425, 537
            utils.waitLoading()
            Send("!r")

            if (shareOnly = false) {
                MouseMove(initX + 129, initY + 201) ; 469, 512
                utils.waitLoading()
                Click()
                utils.waitLoading()
            }
            if (!this.isRunning) {
                this.end()
                return
            }

            Send("!t")
            utils.waitLoading()
            Send("!s")
            utils.waitLoading()
            Send("!m")
            utils.waitLoading()
            Send("{Esc}")
            utils.waitLoading()
            Send("{Text}1")
            utils.waitLoading()
            MouseMove(initX + 147, initY + 91) ; 487, 402
            utils.waitLoading()
            Click("Down")
            MouseMove(initX + 178, initY + 92) ; 518, 403
            utils.waitLoading()
            Click("Up")
            MouseMove(initX + 176, initY + 132) ; 516, 443
            utils.waitLoading()
            Send("{Text}0")
            utils.waitLoading()
            Send("!o")
            utils.waitLoading()
            Send("!r")
            utils.waitLoading()
            if (!this.isRunning) {
                msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
                return
            }

            MouseMove(950, 597)
            utils.waitLoading()
            Click()
            utils.waitLoading()
            Send("!d")
            utils.waitLoading()
            Send("{Left}")
            utils.waitLoading()
            Send("{Space}")
            utils.waitLoading()
            Send("!o")
            utils.waitLoading()
            Send("!c")
            utils.waitLoading()
            if (!this.isRunning) {
                msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
                return
            }

            MouseMove(initX - 19, initY + 196) ; 321, 507
            utils.waitLoading()
            Click("Down")
            MouseMove(initX - 154, initY + 198) ; 186, 509
            utils.waitLoading()
            Click("Up")
            utils.waitLoading()
            Send("{Text}NRR")
            utils.waitLoading()
            Send("{Tab}")
            utils.waitLoading()
            if (!this.isRunning) {
                msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
                return
            }

            loop 5 {
                Send("{Esc}")
                utils.waitLoading()
            }
            Send("!o")
            utils.waitLoading()
            Send("!o")
            utils.waitLoading()
            Send("!c")
            utils.waitLoading()
            Send("!c")
            utils.waitLoading()
            BlockInput(false)
        }
    }

    ; TODO: re-evaluate the coords with opera-active-win anchor
    static dnm(roomQty, isRemove := false) {
        loop roomQty {
            if (!this.isRunning) {
                msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
                return
            }
            Send("!r")
            utils.waitLoading()
            Sleep(200)

            CoordMode("Pixel", "Screen")
            ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])
            Sleep(200)

            ; dismiss alerts
            loop {
                ; if there is a alert box
                if (PixelGetColor(x + 20, y + 166) != "0xFFFFFF") {
                    break
                }

                Send("{Enter}")
                utils.waitLoading()
            }

            ; check if room is dnm already
            ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-active-win.PNG"])
            if (PixelGetColor(x + 124, y + 304) != "0xFF0000" || isRemove) { ; room number field
                MouseMove(x + 275, y + 333)
                utils.waitLoading()
                Click()
                utils.waitLoading()
            }

            Send("!o")
            utils.waitLoading()
        }
    }
}

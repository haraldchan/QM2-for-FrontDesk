class Cashiering_Action {
    static isRunning := false

    static start() {
        try {
            WinMaximize "ahk_class SunAwtFrame"
            WinActivate "ahk_class SunAwtFrame"
            WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
            BlockInput true
        } catch {
            MsgBox("请先打开Opera PMS")
            return
        }

		this.isRunning := true
		HotIf (*) => this.isRunning
		Hotkey("F12", (*) => this.end(), "On")
    }

    static end() {
		this.isRunning := false
		Hotkey("F12", "Off")

		BlockInput false
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
    }

    static sendPassword(form) {
        Send Format("{Text}{1}", form.password)
    }

    static openBilling(form) {
        Send "!t"
        Sleep 100
        Send "!b"
        Sleep 100
        Send Format("{Text}{1}", form.password)
        Sleep 100
        Send "{Enter}"
    }

    static depositEntry(form) {
        amount := InputBox("请输入金额")
        if (amount.Result = "Cancel") {
            return
        }

        supplement := InputBox("请输入单号（后四位即可）")
        if (supplement.Result = "Cancel") {
            return
        }

        this.start()

        Send "!t"
        utils.waitLoading()
        Send "dep"
        utils.waitLoading()
        Send "!p"
        utils.waitLoading()
        Send Format("{Text}{1}", form.password)
        utils.waitLoading()
        
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        Send "{Enter}"
        utils.waitLoading()
        Send Format("{Text}{1}", form.paymentType)
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send Format("{Text}{1}", amount.Value)
        Sleep 200
        Send "{Tab}"
        Sleep 200

        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }
        Send Format("{Text}{1}", supplement.Value)

        Send "!o"
        utils.waitLoading()
        Send "{Escape}"
        utils.waitLoading()
        Send "{Escape}"
        utils.waitLoading()
        Send "{Escape}"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()

        this.end()
    }

    static agodaBalanceTransfer() {
        balance := InputBox("请输入账单金额")
        if (balance.Result = "Cancel") {
            return
        }

        orderId := InputBox("请输入单号")
        if (orderId.Result = "Cancel") {
            return
        }

        WinActivate "ahk_class SunAwtFrame"
        Sleep 100
        Send "!p"
        utils.waitLoading()
        Sleep 200
        if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.png"])) {
            MouseMove foundX, foundY
            Click
            Send "!y"
            utils.waitLoading()
        }

        Send "8888"
        Sleep 100
        Send "{Tab}"
        Send "{Text}" . balance.Value
        Sleep 100
        loop 5 {
            Send "{Tab}"
            Sleep 10
        }
        Send "{Text}" . Format("FR CRS.{1}", orderId.Value)
        Sleep 100
        Send "{Enter}"
        Sleep 100
        Send "8888"
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send "{Text}" . Format("-{1}", balance.Value)
        Sleep 100
        loop 5 {
            Send "{Tab}"
            Sleep 10
        }
        Send "{Text}TO 9003"
        Sleep 100
        Send "{Enter}"
        Sleep 100
        Send "!o"
        Sleep 100
        Send "!c"
        ; MsgBox("已完成.", "Agoda Transfer", "T1 4096")
    }

    static blockPmBilling(form) {
        this.start()

        Send "{Enter}"
        Sleep 100
        Send "!r"
        Sleep 100
        Send "!a"
        Sleep 100
        loop 6 {
            Send "{Tab}"
            Sleep 100
        }
        Send "{Text}-100"
        Sleep 100
        Send "!o"
        MouseMove 695, 220
        Click 1
        Sleep 100
        loop 10 {
            Send "{PgDn}"
            Sleep 10
        }
        Sleep 200
        Send "!e"
        loop 3 {
            Send "{Enter}"
            Sleep 100
        }
        Send "!t"
        Sleep 100
        Send "!b"
        Sleep 100
        Send Format("{Text}{1}", form.password)
        Sleep 100
        Send "{Enter}"

        this.end()
    }
}

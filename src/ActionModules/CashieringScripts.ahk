class CashieringScripts {
    static description := "入账关联 - 快速打开Billing、入Deposit等）"
    static popupTitle := "Cashiering Scripts"
    static paymentType := Map(
        9002, "9002 - Bank Transfer",
        9132, "9132 - Alipay",
        9138, "9138 - EFT-Wechat",
        9140, "9140 - EFT-Alipay",
    )
    static showPassword := signal(false)
    static paymentTypeSelected := signal(9132)
    static userPassword := signal("")

    static USE() {
        CS := Gui("+MinSize250x300", this.popupTitle)
        CS.AddText("h20", "Opera 密码")

        this.pwd := CS.AddReactiveEdit("Password* h20 w110 x+10", "",this.userPassword,,["LoseFocus", (e*) => CashieringScripts.updateUserPassword(e[1])])

        CS.AddReactiveCheckBox("h20 x+10", "显示", this.showPassword,, 
            ["Click", (c*) => CashieringScripts.togglePasswordVisibility(c[1])]
        )

        ; persist hotkey shotcuts
        CS.AddGroupBox("r5 x10 w260", " 快捷键 ")
        p := "
        (
            输入:pw   - 快速输入密码
            输入:agd  - 生成Agoda BalanceTransfer
            输入:blk  - Blocks 界面打开PM (主管权限)
            Alt+F11   - InHouse 界面打开Billing
            Win+F11   - 录入 Deposit
        )"
        StrSplit(p, "`n").map(fragment => 
            CS.AddText((A_Index = 1 ? "xp+10 " : "") . "yp+20", fragment)
        )

        CS.AddGroupBox("r4 x10 y+20 w260", " Deposit ")
        CS.AddText("xp+10 yp+20 h20", "支付类型")
        paymentType := CS.AddReactiveDropDownList("yp+20 w200 Choose2", this.paymentType)
        paymentType.setEvent("Change", (*) => this.paymentTypeSelected.set(paymentType.getValue()))

        CS.AddReactiveButton("y+10 w100", "录入 &Deposit",,,["Click", (*) => this.depositEntry()])

        CS.Show()
    }

    static updateUserPassword(e){
        CashieringScripts.userPassword.set(e.value)
        e.value := CashieringScripts.userPassword.value
    }

    static sendPassword() {
        Send Format("{Text}{1}", this.userPassword.value)
    }

    static togglePasswordVisibility(c) {
        CashieringScripts.showPassword.set(c.value)
        if (c.value = false) {
            CashieringScripts.pwd.setOptions("+Password*")
        } else {
            CashieringScripts.pwd.setOptions("-Password*")
        }
    }

    static openBilling() {
        try {
            WinMaximize "ahk_class SunAwtFrame"
            WinActivate "ahk_class SunAwtFrame"
        } catch {
            MsgBox("请先打开Opera PMS")
            return
        }
        Send "!t"
        Sleep 100
        Send "!b"
        Sleep 100
        Send Format("{Text}{1}", this.userPassword.value)
        Sleep 100
        Send "{Enter}"
    }

    static depositEntry() {
        try {
            WinMaximize "ahk_class SunAwtFrame"
            WinActivate "ahk_class SunAwtFrame"
        } catch {
            MsgBox("请先打开Opera PMS")
            return
        }
        amount := InputBox("请输入金额")
        supplement := InputBox("请输入单号（后四位即可）")
        if (amount.Result = "Cancel") {
            utils.cleanReload(winGroup)
        }
        if (supplement.Result = "Cancel") {
            utils.cleanReload(winGroup)
        }
        utils.waitLoading()
        Send "!t"
        MouseMove 710, 378
        utils.waitLoading()
        Click 1
        utils.waitLoading()
        Send "!p"
        utils.waitLoading()
        MouseMove 584, 446
        utils.waitLoading()
        Send "{BackSpace}"
        utils.waitLoading()
        Send Format("{Text}{1}", this.userPassword.value)
        utils.waitLoading()
        MouseMove 707, 397
        utils.waitLoading()
        Send "{Enter}"
        utils.waitLoading()
        Send Format("{Text}{1}", this.paymentTypeSelected.value)
        utils.waitLoading()
        MouseMove 944, 387
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", amount.Value)
        utils.waitLoading()
        MouseMove 577, 326
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", supplement.Value)
        utils.waitLoading()
        MouseMove 596, 421
        utils.waitLoading()
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
    }

    static agodaBalanceTransfer() {
        balance := InputBox("请输入账单金额")
        orderId := InputBox("请输入单号")
        WinActivate "ahk_class SunAwtFrame"
        utils.waitLoading()
        Send "!p"
        utils.waitLoading()
        Send "8888"
        utils.waitLoading()
        Send "{Tab}"
        Send balance.Value
        utils.waitLoading()
        loop 5 {
            Send "{Tab}"
            utils.waitLoading()
        }
        Send Format("FR CRS.{1}", orderId.Value)
        utils.waitLoading()
        Send "{Enter}"
        utils.waitLoading()
        Send "8888"
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send Format("-{1}", balance.Value)
        utils.waitLoading()
        loop 5 {
            Send "{Tab}"
            utils.waitLoading()
        }
        Send "{Text}TO 9003"
        utils.waitLoading()
        Send "{Enter}"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send "!c"
        MsgBox("DONE.", "Agoda Transfer", "T1 4096")
    }

    static blockPmBilling() {
        try {
            WinMaximize "ahk_class SunAwtFrame"
            WinActivate "ahk_class SunAwtFrame"
        } catch {
            MsgBox("请先打开Opera PMS")
            return
        }
        Send "{Enter}"
        utils.waitLoading()
        Send "!r"
        utils.waitLoading()
        Send "!a"
        utils.waitLoading()
        loop 6 {
            Send "{Tab}"
        utils.waitLoading()
        }
        Send "{Text}-100"
        utils.waitLoading()
        Send "!o"
        MouseMove 695, 220
        Click 1
        utils.waitLoading()
        loop 10 {
            Send "{PgDn}"
        utils.waitLoading()
        }
        utils.waitLoading()
        Send "!e"
        loop 3 {
            Send "{Enter}"
            utils.waitLoading()
        }
        Send "!t"
        utils.waitLoading()
        Send "!b"
        utils.waitLoading()
        Send Format("{Text}{1}", this.userPassword.value)
        utils.waitLoading()
        Send "{Enter}"
    }
}
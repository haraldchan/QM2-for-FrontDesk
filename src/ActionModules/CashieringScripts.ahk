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
        CS := Gui("+AlwaysOnTop +MinSize250x300", this.popupTitle)
        addReactiveText(CS, "h20", "Opera 密码")
        this.pwd := addReactiveEdit(CS, "Password* h20 w110 x+10", "")
        this.pwd.setEvent({ event: "Change", callback: (*) => this.userPassword.set(this.pwd.getInnerText())})

        addReactiveCheckBox(CS, "h20 x+10", "显示", { event: "Click", callback: CashieringScripts.togglePasswordVisibility })

        ; persist hotkey shotcuts
        CS.AddGroupBox("r5 x10 w260", " 快捷键 ")
        CS.AddText("xp+10 yp+20", "输入:pw   - 快速输入密码")
        CS.AddText("yp+20", "输入:agd  - 生成Agoda BalanceTransfer")
        CS.AddText("yp+20", "输入:blk  - Blocks 界面打开PM (主管权限)")
        CS.AddText("yp+20", "Alt+F11   - InHouse 界面打开Billing")
        CS.AddText("yp+20", "Win+F11   - 录入 Deposit")

        CS.AddGroupBox("r4 x10 y+20 w260", " Deposit ")
        CS.AddText("xp+10 yp+20 h20", "支付类型")
        paymentType := AddReactiveComboBox(CS, "yp+20 w200 Choose2", this.paymentType)
        paymentType.setEvent({ event: "Change", callback: (*) => this.paymentTypeSelected.set(paymentType.getValue()) })

        depositBtn := addReactiveButton(CS, "y+10 w100", "录入 &Deposit", { event: "Click", callback: (*) => this.depositEntry() })

        CS.Show()
    }

    static sendPassword() {
        Send Format("{Text}{1}", this.userPassword.get())
    }

    static togglePasswordVisibility() {
        if (CashieringScripts.showPassword.get() = true) {
            CashieringScripts.pwd.setOptions("+Password*")
        } else {
            CashieringScripts.pwd.setOptions("-Password*")
        }
        CashieringScripts.showPassword.set(!CashieringScripts.showPassword.get())
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
        Send Format("{Text}{1}", this.userPassword.get())
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
        Sleep 500
        Send "!t"
        MouseMove 710, 378
        Sleep 500
        Click 1
        Sleep 500
        Send "!p"
        Sleep 200
        MouseMove 584, 446
        Sleep 300
        Send "{BackSpace}"
        Sleep 100
        Send Format("{Text}{1}", this.userPassword.get())
        Sleep 200
        MouseMove 707, 397
        Sleep 500
        Send "{Enter}"
        Sleep 100
        Send Format("{Text}{1}", this.paymentTypeSelected.get())
        Sleep 200
        MouseMove 944, 387
        Sleep 450
        Send "{Tab}"
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send Format("{Text}{1}", amount.Value)
        Sleep 200
        MouseMove 577, 326
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", supplement.Value)
        Sleep 100
        MouseMove 596, 421
        Sleep 500
        Send "!o"
        Sleep 300
        Send "{Escape}"
        Sleep 200
        Send "{Escape}"
        Sleep 200
        Send "{Escape}"
        Sleep 200
        Send "!c"
        Sleep 200
        Send "!c"
        Sleep 200
    }

    static agodaBalanceTransfer() {
        balance := InputBox("请输入账单金额")
        orderId := InputBox("请输入单号")
        WinActivate "ahk_class SunAwtFrame"
        Sleep 100
        Send "!p"
        Sleep 100
        Send "8888"
        Sleep 100
        Send "{Tab}"
        Send balance.Value
        Sleep 100
        loop 5 {
            Send "{Tab}"
            Sleep 10
        }
        Send Format("FR CRS.{1}", orderId.Value)
        Sleep 100
        Send "{Enter}"
        Sleep 100
        Send "8888"
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send Format("-{1}", balance.Value)
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
        Send Format("{Text}{1}", this.userPassword.get())
        Sleep 100
        Send "{Enter}"
    }
}
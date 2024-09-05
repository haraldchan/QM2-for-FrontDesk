class Cashiering_Action {
    static USE() {

    }

    static sendPassword(form) {
        Send Format("{Text}{1}", form.password)
    }

    static openBilling(form) {
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
        Send Format("{Text}{1}", form.password)
        Sleep 100
        Send "{Enter}"
    }

    static depositEntry(form) {
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
        Send Format("{Text}{1}", form.password)
        Sleep 200
        MouseMove 707, 397
        Sleep 500
        Send "{Enter}"
        Sleep 100
        Send Format("{Text}{1}", form.paymentType)
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
        MsgBox("已完成.", "Agoda Transfer", "T1 4096")
    }

    static blockPmBilling(form) {
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
        Send Format("{Text}{1}", form.password)
        Sleep 100
        Send "{Enter}"
    }
}
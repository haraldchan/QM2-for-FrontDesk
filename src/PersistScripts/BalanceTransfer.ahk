class BalanceTransfer {
    static USE() {
        BT := Gui(, "Balance Transfer")
        BT.OnEvent("Escape", (this) => this.Destroy())

        handleSubmit(*) {
            formData := BT.Submit()
            for key, val in formData.OwnProps() {
                if (val == "") {
                    return
                }
            }

            WinActivate "ahk_class SunAwtFrame"
            this.BalanceTransfer_Action(formData)
        }

        return (
            ; form
            BT.AddText("x10 w60 h25 0x200", "金额："),
            BT.AddEdit("vbalance w150 x+10 h25 0x200", ""),
            BT.AddText("x10 w60 h25 0x200", "From 信息："),
            BT.AddEdit("vfromMsg w150 x+10 h25 0x200", ""),
            BT.AddText("x10 w60 h25 0x200", "To   信息："),
            BT.AddEdit("vtoMsg w150 x+10 h25 0x200", ""),
            ; bts
            BT.AddButton("x10 w105 h30", "取消").OnEvent("Click", (*) => BT.Destroy()),
            BT.AddButton("w105 h30 x+10 +Default", "确定").OnEvent("Click", handleSubmit),
            ;
            BT.Show()
        )
    }

    static BalanceTransfer_Action(formData) {
        balance := formData.balance
        fromMsg := formData.fromMsg
        toMsg := formData.toMsg
        
        WinActivate "ahk_class SunAwtFrame"
        Sleep 100
        Send "!p"
        Sleep 100
        Send "8888"
        Sleep 100
        Send "{Tab}"
        Send balance
        Sleep 100
        loop 5 {
            Send "{Tab}"
            Sleep 10
        }
        Send Format("{1}", fromMsg)
        Sleep 100
        Send "{Enter}"
        Sleep 100
        Send "8888"
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send Format("-{1}", balance)
        Sleep 100
        loop 5 {
            Send "{Tab}"
            Sleep 10
        }
        Send Format("{1}", toMsg)
        Sleep 100
        Send "{Enter}"
        Sleep 100
        Send "!o"
        Sleep 100
        Send "!c"
        MsgBox("已完成.", "Balance Transfer", "T1 4096")
    }
}
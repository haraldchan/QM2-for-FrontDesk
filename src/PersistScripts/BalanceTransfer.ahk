class BalanceTransfer {
    static alertImg := A_ScriptDir . "\src\Assets\alert.png"
    static isRunning := false

	static start() {
		WinMaximize "ahk_class SunAwtFrame"
		WinActivate "ahk_class SunAwtFrame"
		WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
		BlockInput true

		Hotkey("F12", (*) => this.end(), "On")
		this.isRunning := true
	}
	
	static end() {
		BlockInput false
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
		
		Hotkey("F12", (*) => {}, "Off")
		this.isRunning := false
	}

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
        
        this.start()

        ; Post
        Send "!p"
        utils.waitLoading()

        ; check if it is no post 
        if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.alertImg)) {
            Send "{Enter}"
            utils.waitLoading()
        } 

        ; post balance transfer transactions
        Send "8888"
        Sleep 100
        Send "{Tab}"
        Send balance
        Sleep 100
        loop 5 {
            Send "{Tab}"
            Sleep 10
        }
        Send Format("{Text}{1}", fromMsg)
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
        Send Format("{Text}{1}", toMsg)
        Sleep 100
        Send "{Enter}"
        Sleep 100
        Send "!o"
        utils.waitLoading()
        Send "!c"
        
        this.end()
        MsgBox("已完成.", "Balance Transfer", "T1 4096")
    }
}

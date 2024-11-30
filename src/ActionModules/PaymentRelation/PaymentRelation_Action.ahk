class PaymentRelation_Action {
	static isRunning := false

	static start() {
        this.isRunning := true
		HotIf (*) => this.isRunning
		Hotkey("F12", (*) => this.end(), "On")

        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"
		WinMaximize "ahk_class SunAwtFrame"
		WinActivate "ahk_class SunAwtFrame"
		WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
		BlockInput true
	}
	
	static end() {
        this.isRunning := false
		Hotkey("F12", "Off")

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
		BlockInput false
	}

    static USE(initX := 759, initY := 266) {
        this.start()

        commentPos := (A_OSVersion = "6.1.7601")
            ? A_ScriptDir . "\src\assets\commentWin7.PNG"
            : A_ScriptDir . "\src\assets\comment.PNG"

        if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, commentPos)) {
            anchorX := FoundX
            anchorY := FoundY
            MouseMove anchorX + 1, anchorY + 1
            Click
        } else {
            BlockInput "MouseMoveOff"
            manualClick := MsgBox("请先点击打开Comment。", "Payment Relation", "OKCancel 4096")
            if (manualClick = "Cancel") {
                return
            }
            BlockInput "MouseMove"
        }

        Sleep 100
        Send "!e"
        Sleep 200
        Send "^v"
        Sleep 150
        Send "!o"
        Sleep 100
        Send "!c"
        Sleep 100
		if (!this.isRunning) {
			msgbox("脚本已终止", popupTitle, "4096 T1")
			return
		}

        Send "!t"
        MouseMove initX, initY ; 759, 266
        Sleep 200
        Click
        Send "!n"
        Sleep 200
        Send "{Text}OTH"
        MouseMove initX - 242, initY + 133 ; 517, 399
        Sleep 100
        Click
        MouseMove initX - 280, initY + 169 ; 479, 435
        Sleep 100
        Click
        MouseMove initX - 70, initY + 211 ; 689, 477
        Sleep 100
		if (!this.isRunning) {
			msgbox("脚本已终止", popupTitle, "4096 T1")
			return
		}

        Click "Down"
        MouseMove initX - 62, initY + 211 ; 697, 477
        Sleep 100
        Click "Up"
        Sleep 100
        Send "^v"
        Sleep 150
        Send "!o"
        Sleep 400
        Send "!c"
        Sleep 200
        Send "!c"
        Sleep 200
        BlockInput false

        this.end()
    }
}
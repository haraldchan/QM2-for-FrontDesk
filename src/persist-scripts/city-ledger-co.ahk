class CityLedgerCo {
	static isRunning := false

	static start() {
		if (!WinExist("ahk_class SunAwtFrame")) {
			MsgBox("Opera PMS 未启动！", POPUP_TITLE, "4096 T2")
			return
		}
		WinMaximize "ahk_class SunAwtFrame"
		WinActivate "ahk_class SunAwtFrame"
		WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
		BlockInput "MouseMove"

		Hotkey("F12", (*) => this.end(), "On")
		this.isRunning := true
	}
	
	static end() {
		BlockInput "MouseMoveOff"
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
		
		Hotkey("F12", (*) => {}, "Off")
		this.isRunning := false
	}

	static USE() {
		this.start()

		isBlue := "0x004080"
		PixelGetColor(600, 830) == isBlue
			? this.fullWin()
			: this.smallWin()
		
		this.end()
	}

	static fullWin() {
		MouseMove 862, 272
		Sleep 100
		Click
		Sleep 10
		Send "!o"
		utils.waitLoading()
		Send "{Blind}{Text}CL"
		if (!this.isRunning) {
			this.end()
			return
		}

		Sleep 10
		Send "!f"
		utils.waitLoading()
		Send "!p"
		utils.waitLoading()
		Send "!n"
		utils.waitLoading()
		Sleep 100

		loop {
			if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["alert.png"])) {
				MouseMove foundX, foundY
				Click
				break
			}

			Sleep 100
		} until (A_Index > 20)

		Send "!n"
		utils.waitLoading()

		MouseMove 352, 269
		this.end()
	}

	static smallWin() {
		BlockInput true
		MouseMove 700, 200
		Sleep 10
		Click
		Sleep 10
		Send "!o"
		Sleep 10
		Send "{Blind}{Text}CL"
		Sleep 10
		Send "!f"
		Sleep 10
		Send "!p"
		Sleep 10
		Send "{Esc}"
		Sleep 10
		BlockInput false
		Sleep 10
		WinRestore "ahk_class SunAwtFrame"
	}
}

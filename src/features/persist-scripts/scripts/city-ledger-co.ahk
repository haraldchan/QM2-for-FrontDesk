class CityLedgerCo {
	static isRunning := false

	static start() {
		if (!WinExist("ahk_class SunAwtFrame")) {
			MsgBox("Opera PMS 未启动！", POPUP_TITLE, "4096 T2")
			return
		}
		WinMaximize("ahk_class SunAwtFrame")
		WinActivate("ahk_class SunAwtFrame")
		WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
		BlockInput("MouseMove")

		Hotkey("F12", (*) => this.end(), "On")
		this.isRunning := true

		SUSPEND_CONTROLLER.suspendOtherScripts()
	}
	
	static end() {
		BlockInput("MouseMoveOff")
		WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
		
		Hotkey("F12", (*) => {}, "Off")
		this.isRunning := false

		SUSPEND_CONTROLLER.restoreAllScripts()
	}

	static USE() {
		this.start()
		this.runCL()
		this.end()
	}

	static runCL() {
		MouseMove(862, 272)
		Sleep(100)
		Click()
		Sleep(10)
		Send("!o")
		utils.waitLoading()
		
		found := PmsImageFinder.find("city-ledger.PNG")
		if (!found) {
			this.end()
			return
		}

		Click(found.outX, found.outY)
		utils.waitLoading()
		Click(found.outX - 524, found.outY + 260)
		utils.waitLoading()
		Click(found.outX - 133, found.outY + 264)
		utils.waitLoading()
		Send("!n")
		utils.waitLoading()
		Sleep(100)

		found := PmsImageFinder.find("alert.PNG", 100, 10)
		if (!found) {
			this.end()
			return
		}
		Click(found.outX + 165, found.outY + 51)
		utils.waitLoading()

		MouseMove(352, 269)
		this.end()
	}
}

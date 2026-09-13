class CityLedgerCo {
	static isRunning := false

	static billingBtnCoords := [
		[243, 658],
		[315, 658],
		[399, 658],
		[480, 658],
		[562, 658],
		[657, 658]
	]

	static start() {
		if (!WinExist("ahk_class SunAwtFrame")) {
			MsgBox("Opera PMS 未启动！", POPUP_TITLE, "4096 T2")
			return
		}
		WinMaximize("ahk_class SunAwtFrame")
		WinActivate("ahk_class SunAwtFrame")
		WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")

		Hotkey("F12", (*) => this.end(), "On")
		this.isRunning := true

		SUSPEND_CONTROLLER.suspendOtherScripts()
	}

	static end() {
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

	static dismissAlerts() {
		; check if alert is on top
		loop {
			; if there is a alert box
			if (PixelGetColor(543, 438) != "0xFFFFFF") {
				break
			}

			Click(575, 533)
			utils.waitLoading()
			Sleep(250)
		}
	}

	static toNextRoom(toBillingIndex) {
		; sort by date on window 1
		; Click(231, 251)
		; utils.waitLoading()
		loop 5 {
			Send("{PgDn}")
			Sleep(10)
			Send("{PgDn}")
			Sleep(10)
		}
		utils.waitLoading()
		PixelSearch(&outX, &outY, 440, 264, 533, 613, "0X000080")
		Sleep(200)
		MouseClickDrag("L", outX + 5, outY + 5, this.billingBtnCoords[toBillingIndex]*)
		Sleep(200)
		utils.waitLoading()
		Click(this.billingBtnCoords[toBillingIndex]*)
		utils.waitLoading()
		Sleep(200)
	}

	static runCL() {
		Click(862, 272) ; win2
		utils.waitLoading()
		Sleep(100)
		Click(816, 720) ; check-out btn
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

	static runSequence() {
		startIndex := InputBox("starts at?", "CL Sequence", , 2)
		if (startIndex.Result == "Cancel") {
			return
		}

		endIndex := InputBox("ends at?", "CL Sequence", , 6)
		if (endIndex.Result == "Cancel") {
			return
		}

		curIndex := Integer(startIndex.Value)
		curEnd := Integer(endIndex.Value)

		this.start()
		loop {
			this.toNextRoom(curIndex)
			this.dismissAlerts()
			this.runCL()
			curIndex++
		} until (curIndex > curEnd)
		this.end()
	}
}

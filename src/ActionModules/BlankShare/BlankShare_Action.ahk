class BlankShare_Action {
	static isRunning := false

	static start() {
		this.isRunning := true
		HotIf (*) => this.isRunning
		Hotkey("F12", (*) => this.end(), "On")

		WinMaximize "ahk_class SunAwtFrame"
		WinActivate "ahk_class SunAwtFrame"
		Sleep 500
		WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
		BlockInput true
	}

	static end() {
		this.isRunning := false
		Hotkey("F12", "Off")

		BlockInput false
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
	}

	static USE(form) {
		form := JSON.parse(JSON.stringify(form))
		roomNums := Trim(form["shareRoomNums"])
		shareQty := Trim(form["shareQty"])
		checkIn := form["checkIn"]

		this.start()
		; single room share(s)
		if (!roomNums) {
			this.makeShare(checkIn, shareQty)
			return
		}

		; multi room share(s)
		shareQty := shareQty.includes(" ") ? shareQty.split(" ") : shareQty
		roomNums := roomNums.includes(" ") ? roomNums.split(" ") : [roomNums]
		for room in roomNums {
			this.search(room)
			if (!this.isRunning) {
            	msgbox("脚本已终止", popupTitle, "4096 T1")
            	return	
			}
			utils.waitLoading()
			this.makeShare(checkIn, (shareQty is Array ? shareQty[A_Index] : shareQty), true)
			utils.waitLoading()
		}

		this.end()
	}

	static search(roomNum) {
        formattedRoom := StrLen(roomNum) == 3 ? "0" . roomNum : roomNum

		MouseMove 329, 196 ; room number field
        Click 3
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        Send "{Text}" . formattedRoom
        utils.waitLoading()


        Send "!h" ; alt+h => search
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        ; sort by Prs.
        Click 838, 378, "Right" 
        utils.waitLoading()
        Send "o"
        utils.waitLoading() 
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }
	}
	
	static makeShare(checkIn, shareQty, keepGoing := false, initX := 949, initY := 599) {
		this.start()

		Send "!t"
		utils.waitLoading()
		Send "!s"
		utils.waitLoading()
		Send "!m"
		utils.waitLoading()
		Send "{Esc}"
		utils.waitLoading()
		Send "{Text}1"
		utils.waitLoading()
		loop 4 {
			Send "{Tab}"
			utils.waitLoading()
		}
		if (!this.isRunning) {
			msgbox("脚本已终止", popupTitle, "4096 T1")
			return
		}

		Send "{Text}0"
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Text}6"
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()

		if (!this.isRunning) {
			msgbox("脚本已终止", popupTitle, "4096 T1")
			return
		}
		; open resv
		Send "!r"
		utils.waitLoading()
		; delete comment
		MouseMove initX, initY ; 949, 599
		utils.waitLoading()
		Click
		utils.waitLoading()
		Send "!d"
		MouseMove initX - 338, initY - 53 ; 611, 546
		utils.waitLoading()
		Click
		utils.waitLoading()
		Send "!c"

		if (!this.isRunning) {
			msgbox("脚本已终止", popupTitle, "4096 T1")
			return
		}
		; change RateCode to NRR
		MouseMove initX - 625, initY - 92 ; 324, 507
		utils.waitLoading()
		Click "Down"
		MouseMove initX - 737, initY - 79 ; 212, 520
		utils.waitLoading()
		Click "Up"
		utils.waitLoading()
		Send "{Text}NRR"
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()
		loop 4 {
			Send "{Esc}"
			utils.waitLoading()
		}
	
		if (!this.isRunning) {
			msgbox("脚本已终止", popupTitle, "4096 T1")
			return
		}
		if (checkIn == true) {
			Send "!i"
			utils.waitLoading()

			; TODO: determine whether there is a "Room Condition" popup
			CoordMode "Pixel", "Screen"
			ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\Assets\alert.PNG")
			if (PixelGetColor(foundX + 150, foundY) == "0xEDEAE6") {
				Send "!y"
			}

			; loop 5 {
			Send "{Esc}"
			utils.waitLoading()
			Send "{Space}"
			utils.waitLoading()
			; }
		}

		if (shareQty > 1) {
			loop (shareQty - 1) {
				if (!this.isRunning) {
					msgbox("脚本已终止", popupTitle, "4096 T1")
					return
				}
				loop 5 {
					Send "{Down}"
					utils.waitLoading()
				}
				Send "!m"
				utils.waitLoading()
				Send "{Esc}"
				utils.waitLoading()
				Send "{Text}1"
				utils.waitLoading()
				loop 4 {
					Send "{Tab}"
					utils.waitLoading()
				}
				Send "{Text}0"
				utils.waitLoading()
				Send "{Tab}"
				utils.waitLoading()
				Send "{Tab}"
				utils.waitLoading()
				Send "{Text}6"
				utils.waitLoading()
				Send "!o"
				utils.waitLoading()
				if (checkIn = true) {
					Send "!i"
					utils.waitLoading()
					loop 5 {
						Send "{Esc}"
						utils.waitLoading()
						Send "{Space}"
						utils.waitLoading()
					}
				}
			}
		}

		Send "!o"
		utils.waitLoading()
		Send "!c"
		utils.waitLoading()

		( !keepGoing && this.end() )
	}
}
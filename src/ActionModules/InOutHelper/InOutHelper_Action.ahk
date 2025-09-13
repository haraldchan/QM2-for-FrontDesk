#Include "./InOutHelper_Action.ahk"

class InOutHelper_Action {
	static FOUND := "0x000080"
	static NOT_FOUND := "0x008080"

	static USE(form) {
		form.prevBookingInfo := this.getPrevBookingInfo()
	}

	static searchUpdateReservation(conf, date) {
		; search for extend booking with conf
		loop 6 {
			Send "{Tab}"
			Sleep 100
		}
		Send "{Text}" . conf
		utils.waitLoading()
		Send "!h"
		utils.waitLoading()

		this.openResv()
		roomNum := this.getRoomNum()

		; search with room number and dep date
		Send "!r"
		utils.waitLoading()

		; send dep date
		loop 10 { ; <- loop time might need changes
			Send "{Tab}"
			Sleep 100
		}
		Send "{Text}" . date
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Text}" . date
		utils.waitLoading()

		; open advance options and entry room number
		Send "!a"
		utils.waitLoading()
		loop 3 {
			Send "{Tab}"
			Sleep 100
		}
		Send "{Text}" . roomNum
		utils.waitLoading()
		Send "!h"
		utils.waitLoading()

		; sort by Prs.
		Click 838, 378, "Right"
		Sleep 200
		Send "{Down}"
		Sleep 200
		Send "{Enter}"
		utils.waitLoading()
	}

	static getPrevBookingInfo() {
		shareCount := this.countShares()
		idNums := this.getIdNums(shareCount)

		this.openResv()

		depDate := this.getDepDate()
		roomNum := this.getRoomNum()

		return {
			roomNum: roomNum,
			depDate: depDate,
			shareCount: shareCount,
			idNums: idNums,
		}
	}

	static handleNextBookingEntry(form) {
		this.searchUpdateReservation(form.prevConf, form.prevBookingInfo.depDate)
		
		; Trace and Alert entry
		this.writeTrace(form.prevBookingInfo.depDate, form.traceText)
		this.writeAlert(Format("此为 #{1} 的续住 Booking", form.prevConf))
		
		
		; Profile Entry
		; open and get room number
		Send "!r"
		utils.waitLoading()
		this.searchUpdateReservation(form.prevConf, form.prevBookingInfo.depDate)
		nextRoomNum := this.getRoomNum()
		
		existShareCount := this.countShares()
		if (form.shareCount > existShareCount) {
			BlankShare_Action.makeShare(false, form.shareCount - existShareCount)
		}
		
		Send "!r"
		utils.waitLoading()
		this.searchUpdateReservation(form.prevConf, form.prevBookingInfo.depDate)

		; enter profile(s)
		loop form.shareCount {
			Send "!p"
			utils.waitLoading()

			if (this.matchHistory(form.prevBookingInfo.idNums[A_Index]) == this.FOUND) {
				; save matching profile
				Send "!o"
				utils.waitLoading()
			} else {
				; TODO: close it if not found
			}

			Send "{Down}"
			utils.waitLoading()
		}
	}

	static openResv() {
		; open reservation
		Send "{Enter}"
		utils.waitLoading()

		; check if alert is on top
		loop {
			; if there is a alert box
			if (PixelGetColor(551, 421) != "0xFFFFFF") {
				break
			}

			Send "{Enter}"
			Sleep 250
		}
		utils.waitLoading()
	}

	static getDepDate() {
		Send "!i"
		Send "!c"
		utils.waitLoading()

		loop 2 {
			Send "{Tab}"
			Sleep 200
		}

		Send "^c"
		utils.waitLoading()

		return A_Clipboard
	}

	static getRoomNum() {
		MouseClickDrag "Left", 325, 485, 250, 485
		utils.waitLoading()
		Send "^c"
		utils.waitLoading()

		return A_Clipboard
	}

	static countShares() {
		shareCount := 1

		; sort by Prs.
		Click 838, 378, "Right"
		Sleep 200
		Send "{Down}"
		Sleep 200
		Send "{Enter}"
		utils.waitLoading()

		x := 811
		y := 419

		loop {
			Send "{Down}"
			utils.waitLoading()
			if (PixelGetColor(x, y) == "0x000080") {
				shareCount++
				y += 22
			} else {
				break
			}
		}

		return shareCount
	}

	static getIdNums(shareCount) {
		idNums := []

		loop shareCount {
			Send "!p"
			utils.waitLoading()
			MouseMove 825, 329
			utils.waitLoading()
			Click 2
			utils.waitLoading()
			Send "^c"
			utils.waitLoading()

			idNums.InsertAt(1, A_Clipboard)

			Send "!o"
			utils.waitLoading()
			Send "{Up}"
			utils.waitLoading()
		}

		return idNums
	}

	static writeTrace(depDate, traceText) {
		; open option and create new trace
		Send "!t"
		utils.waitLoading()
		Send "!t"
		utils.waitLoading()
		Send "!n"
		utils.waitLoading()

		; save new trace
		Send "{Text}" . depDate
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Text}" . depDate
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Text}FD"
		utils.waitLoading()
		Send "{Tab}"
		utils.waitLoading()
		Send "{Text}" . traceText
		utils.waitLoading()

		; save and out
		Send "!o"
		utils.waitLoading()
		Send "!c"
		utils.waitLoading()
		Send "!c"
		utils.waitLoading()
	}

	static writeAlert(alertText) {
		initX := 759, initY := 266 ; 759, 266

		Send "!t"
		MouseMove initX, initY ; 759, 266
		utils.waitLoading()
		Click
		Send "!n"
		utils.waitLoading()
		Send "{Text}OTH"
		MouseMove initX - 242, initY + 133 ; 517, 399
		utils.waitLoading()
		Click
		MouseMove initX - 280, initY + 169 ; 479, 435
		utils.waitLoading()
		Click
		MouseMove initX - 70, initY + 211 ; 689, 477


		Click "Down"
		MouseMove initX - 62, initY + 211 ; 697, 477
		utils.waitLoading()
		Click "Up"
		utils.waitLoading()
		Send "{Text}" . alertText
		utils.waitLoading()
		Send "!o"
		utils.waitLoading()
		Send "!c"
		utils.waitLoading()
		Sleep 200
		Send "!c"
		utils.waitLoading()
	}

	static matchHistory(idNum) {
		loop {
			Sleep 100
			if (A_Index > 30) {
				MsgBox("界面定位失败", POPUP_TITLE, "T2 4096")
				utils.cleanReload(WIN_GROUP)
			}

			if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, IMAGES["AltNameAnchor.PNG"])) {
				x := Number(FoundX) + 350
				y := Number(FoundY) + 80
				break
			} else {
				continue
			}
		}

		Send "!h"
		utils.waitLoading()
		Send "{Esc}" ; cancel the "save changes msgbox"
		utils.waitLoading()
		loop 12 {
			Send "{Tab}"
			Sleep 10
		}

		Send Format("{Text}{1}", idNum)
		utils.waitLoading()
		Send "!h"
		utils.waitLoading()
		Sleep 500

		res := PixelGetColor(x, y)
		utils.waitLoading()

		return res
	}
}
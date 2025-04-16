#Include "./InOutHelper_Action.ahk"

class InOutHelper_Action {

	static handlePrevBooking() {
		shareCount := this.countShares()
		idNums := this.getIdNums(shareCount)

		this.openResv()
		
		depDate := this.getDepDate()
		roomNum := this.getRoomNum()

		msgbox JSON.stringify({
			shareCount: shareCount,
			idNums: idNums,
			depDate: depDate,
			roomNum: roomNum
		})

		return	
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

	static writeAlert(confNum) {
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
        Send "{Text}" . Format("续住 Booking #{1}", confNum)
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
        Sleep 200
        Send "!c"
        utils.waitLoading()
	}
}
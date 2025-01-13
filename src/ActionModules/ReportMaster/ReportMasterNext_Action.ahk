class ReportMasterNext_Action {
	static isRunning := false

	static start() {
        this.isRunning := true
		HotIf (*) => this.isRunning
		Hotkey("F12", (*) => this.end(), "On")

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

    static reportList := {
        onr: [{
            searchStr: "%complimentary",
            name: "Guest INH Complimentary",
            saveFn: this.comp
        }, {
            searchStr: "FI01",
            name: "NA02-Manager Flash",
            saveFn: this.mgrFlash
        }, {
            searchStr: "RS05",
            name: "RS05-（前后15天）History & Forecast",
            saveFn: this.hisFor15
        }, {
            searchStr: "RS05",
            name: "RS05-（FO当月）History & Forecast",
            saveFn: this.hisForThisMonth
        }, {
            searchStr: "RS05",
            name: "RS05-（FO次月）History & Forecast",
            saveFn: this.hisForNextMonth
        }, {
            searchStr: "FO01-VIP",
            name: "VIP Arrival (VIP Arr)",
            saveFn: this.vipArr
        }, {
            searchStr: "FO03",
            name: "FO03-VIP DEP",
            saveFn: this.vipDep
        }, {
            searchStr: "FO01",
            name: "FO01-Arrival Detailed",
            saveFn: this.arrAll
        }, {
            searchStr: "FO02",
            name: "FO02-Guests INH by Room",
            saveFn: this.inhAll
        }, {
            searchStr: "FO03",
            name: "FO03-Departures",
            saveFn: this.depAll
        }, {
            searchStr: "FO11",
            name: "FO11-Credit Limit",
            saveFn: this.creditLimit
        }, {
            searchStr: "FO13",
            name: "FO13-Package Forecast（仅早餐）",
            saveFn: this.bbf
        }, {
            searchStr: "%hkroomstatusperroom",
            name: "Rooms-housekeepingstatus",
            saveFn: this.rooms
        }, {
            searchStr: "HK03",
            name: "HK03-OOO",
            saveFn: this.ooo
        }, {
            searchStr: "grprmlist",
            name: "Group Rooming List",
            saveFn: this.groupRoom
        }, {
            searchStr: "grpinhouse",
            name: "Group In House",
            saveFn: this.groupInh
        }, {
            searchStr: "FO08",
            name: "FO08-No Show",
            saveFn: this.noShow
        }, {
            searchStr: "rescancel",
            name: "Cancellations",
            saveFn: this.cancel
        }, {
            searchStr: "%guestinhw",
            name: "Guest In House w/o Due Out(VIP INH)",
            saveFn: this.vipInh
        }],
        misc: [{
            searchStr: "Wshgz_special",
            name: "Specials - 当天水果5 报表",
            saveFn: this.special
        }, {
            searchStr: "pkgforecast",
            name: "Upselling - 当天 Upsell 报表",
            saveFn: this.upsellPkg
        }, {
            searchStr: "pkgforecast",
            name: "Afternoon Tea - 当天 大堂吧下午茶 报表",
            saveFn: this.lobbyBarAFT
        }, {
            searchStr: "pkgforecast",
            name: "Morning Tea - 宏图府早茶 报表",
            saveFn: this.hongtuMorningTea
        }, {
            searchStr: "pkgforecast",
            name: "Morning Tea - 丝绸之路早茶 报表",
            saveFn: this.silkroadMorningTea
        }],
        groupArr: {
            searchStr: "GRPRMLIST",
            name: "Group Arrival - 当天预抵团单",
            saveFn: this.arrivingGroups
        }
    }

    static reportFiling(reportInfoObj, fileType, initX := 433, initY := 598) {

        fileTypeSelectPointer := Map(
            "PDF", 0,
            "XML", 2,
            "TXT", 4,
            "XLS", 5,
        )

        Send "!m"
        Sleep 100
        Send "{Text}R"
        Sleep 100
        Send Format("{Text}{1}", reportInfoObj.searchStr)
        Sleep 100
        Send "!h"
        Sleep 100
        MouseMove initX, initY ; 433, 598
        Sleep 150
        Click ; click print to file
        Sleep 150

        MouseMove initX + 380, initY
        Click
        if (fileTypeSelectPointer[fileType] != 0) {
            loop fileTypeSelectPointer[fileType] {
                Send "{Down}"
                Sleep 10
            }
        }
        Sleep 100
        Send "{Enter}"
        Sleep 100
        Send "!o"
		if (!this.isRunning) {
			msgbox("脚本已终止", popupTitle, "4096 T1")
			return
		}

        ; run saving actions, return filename
        reportFn := reportInfoObj.saveFn
        if (reportInfoObj.searchStr = "GRPRMLIST" && reportInfoObj.name = "Group Arrival - 当天预抵团单") {
            saveName := reportFn(this, reportInfoObj.blockCode, reportInfoObj.blockName)
        } else {
            saveName := reportInfoObj.hasOwnProp("args")
                ? reportFn(this, reportInfoObj.args*)
                : reportFn(this)
        }
        saveFileName := saveName . "." . fileType

        Sleep 1000
        Send "!f"
        
        WinWait("Please Select a Directory to Download")
        Sleep 200
        Send "{Backspace}"
        Sleep 200
        Send Format("{Text}{1}", saveFileName)
        Sleep 1000
        Send "{Enter}"

        TrayTip Format("正在保存：{1}", saveFileName)
		if (!this.isRunning) {
			msgbox("脚本已终止", popupTitle, "4096 T1")
			return
		}

        ; isWindows7 := StrSplit(A_OSVersion, ".")[1] == 6
        loop 30 {
            if (!this.isRunning) {
                this.end()
                return
            }
            sleep 1000
            if (Winwait("Warning",, 20)) {
                WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
                Sleep 100
                WinActivate "Warning"
                utils.waitLoading()
                Send "{Enter}"
                utils.waitLoading()
                WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
            }

            if (FileExist(A_MyDocuments . "\" . saveFileName)) {
                break
            }

            if (A_Index = 30) {
                MsgBox("保存出错，脚本已终止。", "ReportMaster", "T1 4096")
                this.end()
                return
            }
        }

        MouseMove initX, initY
        utils.waitLoading()
        Click
        Sleep 200
        Send "!c"
    }

    static comp() {
        fileName := "Comp"
        Sleep 200
        return fileName
    }

    static mgrFlash(initX := 749, initY := 333) {
        fileName := "NA02-MANAGER FLASH"
        Sleep 200
        MouseMove initX, initY ; 749, 333
        Sleep 150
        Send "!o"
        MouseMove initX - 149, initY + 169 ; 600, 502
        Sleep 150
        Click
        Sleep 150
        return fileName
    }

    static hisFor15(initX := 644, initY := 178) {
        fileName := "RS05-林总"
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 644, 178
        Sleep 150
        Click "Down"
        MouseMove initX - 102, initY - 8 ; 542, 170
        Sleep 150
        Click "Up"
        MouseMove initX - 117, initY - 27 ; 527, 151
        Sleep 150
        Send "{NumpadSub}"
        Sleep 150
        Send "8"
        MouseMove initX + 2, initY + 26 ; 646, 204
        Sleep 150
        Click "Down"
        MouseMove initX - 111, initY + 41 ; 533, 219
        Sleep 150
        Click "Up"
        MouseMove initX - 171, initY + 92 ; 473, 270
        Sleep 150
        Send "{NumpadSub}"
        Sleep 150
        Send "8"
        MouseMove initX - 27, initY + 463 ; 617, 641
        Sleep 150
        Send "{Tab}"
        MouseMove initX - 34, initY + 511 ; 610, 689
        Sleep 150
        Click
        Sleep 150
        return fileName
    }

    static hisForThisMonth(initX := 645, initY := 205) {
        preAuditDate := DateAdd(A_Now, -1, "Days")
        preAuditMonth := FormatTime(preAuditDate, "MM")
        preAuditYear := FormatTime(preAuditDate, "yyyy")
        nextMonth := (preAuditMonth = 12) ? 1 : preAuditMonth + 1

        nextMonth := (nextMonth < 10) ? "0" . nextMonth : nextMonth

        printYear := (preAuditMonth) = 12 ? preAuditYear + 1 : preAuditYear
        firstDayOfNextMonth := printYear . nextMonth . "01"

        dateFirst := preAuditMonth . "01" . preAuditYear
        dateLast := FormatTime(DateAdd(firstDayOfNextMonth, -1, "Days"), "MMddyyyy")

        fileName := Format("RS05-{1}月", preAuditMonth)
        Sleep 150
        Send "{Backspace}"
        Sleep 300
        Send Format("{Text}{1}", dateFirst)
        Sleep 300
        MouseMove initX, initY ; 645, 205
        Sleep 150
        Click "Down"
        MouseMove initX - 114, initY - 1 ; 531, 204
        Sleep 150
        Click "Up"
        Sleep 150
        Send "{Backspace}"
        Sleep 300
        Send Format("{Text}{1}", dateLast)
        Sleep 300
        MouseMove initX - 28, initY + 436 ; 617, 641
        Sleep 150
        Send "{Tab}"
        MouseMove initX - 35, initY + 484 ; 610, 689
        Sleep 150
        Click
        Sleep 150
        return fileName
    }

    static hisForNextMonth(initX := 645, initY := 205) {
        preAuditDate := DateAdd(A_Now, -1, "Days")
        preAuditMonth := FormatTime(preAuditDate, "MM")
        preAuditYear := FormatTime(preAuditDate, "yyyy")

        nMonth := (preAuditMonth = 12) ? 1 : preAuditMonth + 1
        nextMonth := (nMonth < 10) ? "0" . nMonth : nMonth
        nextNextMonth := (nextMonth = 12) ? 1 : nextMonth + 1
        nextNextMonth := (nextNextMonth < 10) ? "0" . nextNextMonth : nextNextMonth

        printYear := preAuditMonth = 12 ? preAuditYear + 1 : preAuditYear

        firstDayOfNextMonth := printYear . nextMonth . "01"
        firstDayOfNextNextMonth := nextNextMonth == "01"
            ? printYear + 1 . nextNextMonth . "01"
            : printYear . nextNextMonth . "01"

        dateFirstNext := nextMonth . "01" . printYear
        dateLastNext := FormatTime(DateAdd(firstDayOfNextNextMonth, -1, "Days"), "MMddyyyy")

        fileName := Format("RS05-{1}月", nextMonth)
        ; BlockInput true
        ; reportOpen(searchStr)
        Sleep 200
        ; report options here
        Send "{Backspace}"
        Sleep 300
        Send Format("{Text}{1}", dateFirstNext)
        Sleep 300
        MouseMove initX, initY ; 645, 205
        Sleep 150
        Click "Down"
        MouseMove initX - 114, initY - 1 ; 531, 204
        Sleep 150
        Click "Up"
        Sleep 150
        Send "{Backspace}"
        Sleep 300
        Send Format("{Text}{1}", dateLastNext)
        Sleep 300
        MouseMove initX - 28, initY + 436 ; 617, 641
        Sleep 150
        Send "{Tab}"
        MouseMove initX - 35, initY + 484 ; 610, 689
        Sleep 150
        Click
        Sleep 150
        return fileName
    }

    static vipArr(initX := 464, initY := 194) {
        fileName := "FO01-VIP ARR"
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 464, 194
        Sleep 150
        Click "Down"
        MouseMove initX - 128, initY + 4 ; 336, 198
        Sleep 50
        Click "Up"
        Sleep 150
        Send "{NumpadAdd}"
        Sleep 150
        Send "{Text}2"
        Sleep 100
        MouseMove initX + 146, initY + 426 ; 610, 620
        Sleep 150
        Click
        MouseMove initX + 168, initY + 399 ; 632, 593
        Sleep 150
        Click
        MouseMove initX + 146, initY + 549 ; 610, 743
        Sleep 150
        return fileName
    }

    static vipInh() {
        fileName := "VIP INH-Guest INH without due out"
        Sleep 200
        return fileName
    }

    static vipDep(initX := 622, initY := 391) {
        fileName := "FO03-VIP DEP"
        Sleep 200
        ; report options here
        MouseMove initX, initY
        Sleep 150
        Click
        MouseMove 855, 391
        Sleep 150
        Click
        Sleep 150
        Send "!a"
        Sleep 150
        Send "!o"
        Sleep 200
        return fileName
    }

    static arrAll(initX := 309, initY := 566) {
        fileName := "FO01-Arrival Detailed"
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 309, 566
        Sleep 150
        Click
        MouseMove initX + 8, initY + 53 ; 317, 619
        Sleep 150
        Click
        MouseMove initX + 16, initY + 97 ; 325, 663
        Sleep 150
        Click
        MouseMove initX + 290, initY + 28 ; 599, 594
        Sleep 150
        Click
        MouseMove initX + 299, initY + 52 ; 608, 618
        Click
        Sleep 150
        return fileName
    }

    static inhAll(initX := 433, initY := 523) {
        fileName := "FO02-INH"
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 433, 523
        Sleep 150
        Click
        return fileName
    }

    static depAll(initX := 607, initY := 540) {
        fileName := "FO03-DEP"
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 607, 540
        Sleep 150
        click
        Sleep 150
        MouseMove initX - 119, initY - 50 ; 488, 490
        Sleep 150
        Click
        return fileName
    }

    static creditLimit(initX := 686, initY := 474) {
        fileName := "FO11-CREDIT LIMIT"
        ; BlockInput true
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 686, 474
        Click
        MouseMove initX - 277, initY + 48 ; 409, 522
        Sleep 150
        Click
        Sleep 200
        return fileName
    }

    static bbf(initX := 599, initY := 276) {
        fileName := "FO13-Packages 早餐"
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 599, 276
        Sleep 150
        Click "Down"
        MouseMove initX - 80, initY + 3 ; 519, 279
        Sleep 150
        Click "Up"
        Sleep 150
        Send "{NumpadSub}"
        Sleep 150
        Send "1"
        Sleep 150
        Send "{Enter}"
        MouseMove initX + 10, initY - 7 ; 609, 269
        Sleep 150
        Click "Down"
        MouseMove initX - 129, initY + 7 ; 470, 283
        Sleep 150
        Click "Up"
        Sleep 100
        Send "^c"
        Sleep 200
        MouseMove initX + 6, initY + 27 ; 605, 303
        Sleep 150
        MouseMove initX + 6, initY + 27 ; 605, 303
        Sleep 150
        Click "Down"
        MouseMove initX - 103, initY + 30 ; 496, 306
        Sleep 150
        Click "Up"
        MouseMove initX - 105, initY + 31 ; 494, 307
        Sleep 100
        Send "^v"
        Sleep 100
        MouseMove initX - 136, initY + 242 ; 463, 518
        Sleep 150
        Click
        Sleep 150
        return fileName
    }

    static rooms(initX := 476, initY := 515) {
        fileName := "Rooms"
        Sleep 200
        ; report options here
        MouseMove initX, initY
        Sleep 150
        Click
        Sleep 150
        return fileName
    }

    static ooo() {
        fileName := "HK03-OOO"
        Sleep 200
        return fileName
    }

    static groupRoom(initX := 372, initY := 544) {
        fileName := "Group Rooming List"
        ; BlockInput true
        ; reportOpen(searchStr)
        Sleep 200
        ; ; report options here
        ; MouseMove initX, initY ; 372, 544
        ; Sleep 150
        ; Click
        ; MouseMove initX + 148, initY - 78 ; 520, 466
        ; Sleep 150
        ; Click
        ; MouseMove initX + 160, initY + 5 ; 532, 549
        ; Sleep 150
        ; Click
        ; Sleep 150
        loop 14 {
            sleep 100
            Send "{Tab}"
        }

        Sleep 100
        Send "{Space}"

        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send "{Space}"

        loop 5 {
            sleep 100
            Send "{Tab}"
        }
        Sleep 100
        Send "{Space}"

        loop 4 {
            sleep 100
            Send "{Tab}"
        }
        Sleep 100
        Send "{Space}"

        return fileName
    }

    static groupInh(initX := 470, initY := 425) {
        fileName := "Group INH"
        ; BlockInput true
        ; reportOpen(searchStr)
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 470, 425
        Sleep 150
        Click
        MouseMove initX + 155, initY + 68 ; 625, 493
        Sleep 150
        Click
        Sleep 150
        return fileName
    }

    static noShow(initX := 573, initY := 440) {
        fileName := "FO08-NO SHOW"
        Sleep 200
        ; report options here
        MouseMove initX, initY
        Sleep 50
        Send "{Backspace}"
        Sleep 150
        Send "{NumpadSub}"
        Sleep 100
        Send "{Text}1"
        Sleep 150
        Send "{Tab}"
        Sleep 150
        Send "{NumpadSub}"
        Sleep 100
        Send "{Text}1"
        Sleep 150
        return fileName
    }

    static cancel(initX := 601, initY := 291) {
        fileName := "CXL"
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 601, 291
        Sleep 150
        Click "Down"
        MouseMove initX - 196, initY - 13 ; 485, 278
        Sleep 150
        Click "Up"
        Sleep 150
        Send "{Backspace}"
        Sleep 150
        Send "{NumpadSub}"
        Sleep 150
        Send "{Text}1"
        Sleep 50
        Send "{Enter}"
        Sleep 150
        MouseMove initX + 1, initY - 3 ; 602, 288
        Sleep 150
        Click "Down"
        MouseMove initX - 153, initY + 1 ; 448, 292
        Sleep 150
        Click "Up"
        Sleep 50
        Send "^c"
        Sleep 150
        MouseMove initX - 15, initY + 18 ; 586, 309
        Sleep 150
        Click "Down"
        MouseMove initX - 188, initY + 30 ; 413, 321
        Sleep 150
        Click "Up"
        MouseMove initX - 162, initY + 34 ; 439, 325
        Sleep 50
        Send A_Clipboard
        MouseMove initX + 86, initY + 26 ; 687, 317
        Sleep 150
        Click
        MouseMove initX + 94, initY + 32 ; 695, 323
        Sleep 150
        return fileName
    }

    static arrivingGroups(blockCodeInput, saveName, initX := 845, initY := 376) {
        fileName := saveName
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 845, 376
        Sleep 150
        Click
        MouseMove initX - 41, initY + 10 ; 804, 386
        Sleep 150
        Send "!a"
        Sleep 150
        MouseMove initX - 37, initY + 229 ; 808, 605
        Sleep 150
        Click "Down"
        MouseMove initX - 40, initY + 239 ; 805, 614
        Sleep 150
        Click "Up"
        MouseMove initX - 108, initY + 239 ; 737, 615
        Sleep 150
        Click
        Sleep 150
        loop 8 {
            Send "{Space}"
            Sleep 100
            Send "{Up}"
            Sleep 100
        }
        Sleep 350
        Send "!o"
        Sleep 150
        MouseMove initX - 3, initY - 52 ; 842, 324
        Sleep 150
        Click
        MouseMove initX - 276, initY - 93 ; 569, 283
        Sleep 150
        Click
        Sleep 150
        Send Format("{Text}{1}", blockCodeInput)
        Sleep 150
        MouseMove initX + 3, initY - 95 ; 848, 281
        Sleep 150
        Click
        MouseMove initX - 242, initY + 36 ; 603, 412
        Sleep 150
        Click
        Sleep 150
        Send "{Space}"
        MouseMove initX - 117, initY + 97 ; 728, 473
        Sleep 150
        Send "!o"
        Sleep 150
        Send "!o"
        Sleep 150
        MouseMove initX - 134, initY + 115 ; 711, 491
        Sleep 150
        Click
        MouseMove initX - 423, initY + 144 ; 422, 520
        Sleep 150
        Click
        MouseMove initX - 236, initY + 271 ; 609, 647
        return fileName
    }

    static special(initX := 600, initY := 482) {
        fileName := Format("{1} 水果5", FormatTime(A_Now, "yyyyMMdd"))
        Sleep 200
        ; report options here
        MouseMove initX, initY ; 600, 482
        Sleep 200
        Click
        Sleep 200
        Send "{Text}水果5"
        Sleep 100
        MouseMove initX + 16, initY + 56 ; 616, 538
        Sleep 200
        return fileName
    }

    static upsellPkg() {
        fileName := Format("{1} Upsell", FormatTime(A_Now, "yyyyMMdd"))
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send "^c"
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send "^v"
        MouseMove 764, 373
        Sleep 200
        Click
        Sleep 200
        Send "!n"
        Sleep 200
        Send "{Text}%US"
        Sleep 200
        Send "!h"
        Sleep 200
        Send "!a"
        Sleep 200
        Send "!o"
        Sleep 200
        return fileName
    }

    static lobbyBarAFT() {
        fileName := Format("{1} 大堂吧下午茶", FormatTime(A_Now, "yyyyMMdd"))
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send "^c"
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send "^v"
        MouseMove 764, 373
        Sleep 200
        Click
        Sleep 200
        Send "!n"
        Sleep 200
        Send "{Text}ATPR-2"
        Sleep 200
        Send "!h"
        Sleep 200
        Send "!a"
        Sleep 200
        Send "!o"
        Sleep 200
        return fileName
    }

    static hongtuMorningTea() {
        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
        query := MsgBox("保存报表日期？`n`n(Y)  - 今天`n(N) - 昨天", "Report Master", "4096 YN")
        Sleep 100
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        queryDate := query = "Yes" ? A_Now : DateAdd(A_Now, -1, "Days")
        fileName := Format("{1} 宏图府早茶", FormatTime(queryDate, "yyyyMMdd"))
        Sleep 500
        MouseMove 659, 271
        Sleep 200
        Click
        Sleep 200
        Send "!c"
        Sleep 200
        Send FormatTime(queryDate, "MMddyyyy")
        Sleep 200

        MouseMove 659, 300
        Sleep 200
        Click
        Sleep 200
        Send "!c"
        Sleep 200
        Send FormatTime(queryDate, "MMddyyyy")
        Sleep 200

        MouseMove 764, 373
        Sleep 200
        Click
        Sleep 200
        Send "!n"
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send "{Text}%宏图府"
        Sleep 200
        Send "!h"
        Sleep 200
        Send "!a"
        Sleep 200
        Send "!o"
        Sleep 200
        return fileName
    }

    static silkroadMorningTea() {
        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
        query := MsgBox("保存报表日期？`n`n(Y)  - 今天`n(N) - 昨天", "Report Master", "4096 YN")
        Sleep 100
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        queryDate := query = "Yes" ? A_Now : DateAdd(A_Now, -1, "Days")
        fileName := Format("{1} 丝绸之路早茶", FormatTime(queryDate, "yyyyMMdd"))
        Sleep 500
        MouseMove 659, 271
        Sleep 200
        Click
        Sleep 200
        Send "!c"
        Sleep 200
        Send FormatTime(queryDate, "MMddyyyy")
        Sleep 200

        MouseMove 659, 300
        Sleep 200
        Click
        Sleep 200
        Send "!c"
        Sleep 200
        Send FormatTime(queryDate, "MMddyyyy")
        Sleep 200

        MouseMove 764, 373
        Sleep 200
        Click
        Sleep 200
        Send "!n"
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send "{Text}%丝绸之路"
        Sleep 200
        Send "!h"
        Sleep 200
        Send "!a"
        Sleep 200
        Send "!o"
        Sleep 200
        return fileName
    }

    static depForBatchOut() {
        fileName := Format("{1} - Departures", FormatTime(A_Now, "yyyyMMdd"))

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false

        Sleep 1000
        timePeriod := InputBox(
            textMsg := "
            (
            请选择FO03 - Departures数据时间范围：
        
            1 - 夜班： 00:00 ~ 07:00
            2 - 早班： 07:00 ~ 15:00
            3 - 中班： 15:00 ~ 23:59
            0 - 自定义时间段
            )", "Report Master")
        if (timePeriod.Result = "Cancel") {
            Reload
        }
        frTime := ""
        toTime := ""
        switch timePeriod.Value {
            Case "1":
                frTime := "0000"
                toTime := "0700"
            Case "2":
                frTime := "0600"
                toTime := "1500"
            Case "3":
                frTime := "1400"
                toTime := "2359"
            Case "0":
                frTime := InputBox("请输入开始时间（格式：“hhmm”）", "Report Master").Value
                toTime := InputBox("请输入结束时间（格式：“hhmm”）", "Report Master").Value
            default:
                MsgBox("请输入对应时间的指令。")
                return
        }

        Sleep 100
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        WinActivate "ahk_class SunAwtFrame"
        Sleep 100
        MouseMove 490, 363
        Sleep 100
        Click 3
        Sleep 100
        Send Format("{Text}{1}", frTime)
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", toTime)
        Sleep 100
        loop 7 {
            Send "{Tab}"
            Sleep 100
        }
        Send "{Space}"
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send "{Space}"

        return fileName
    }

}
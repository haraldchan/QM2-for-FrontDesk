class ReportMaster_Action {
    static isRunning := false

    static start() {
        this.isRunning := true
        HotIf((*) => this.isRunning)
        Hotkey("F12", (*) => this.end(), "On")

        CoordMode("Mouse", "Screen")
        try {
            WinMaximize("ahk_class SunAwtFrame")
            WinActivate("ahk_class SunAwtFrame")
            WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
            BlockInput(true)
        }
        catch Error as e {
            return false
        }

        return true
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
        BlockInput(false)
    }


    static overnightReports := [
        {
            name: "Guest INH Complimentary",
            searchStr: "%complimentary",
            saveFn: this.comp
        },
        {
            name: "NA02-Manager Flash",
            searchStr: "FI01",
            saveFn: this.mgrFlash
        },
        {
            name: "RS05-（前后15天）History & Forecast",
            searchStr: "RS05",
            saveFn: this.hisFor15
        }, 
        {
            name: "RS05-（FO当月）History & Forecast",
            searchStr: "RS05",
            saveFn: this.hisForThisMonth
        }, 
        {
            name: "RS05-（FO次月）History & Forecast",
            searchStr: "RS05",
            saveFn: this.hisForNextMonth
        }, 
        {
            name: "VIP Arrival (VIP Arr)",
            searchStr: "FO01-VIP",
            saveFn: this.vipArr
        }, 
        {
            name: "FO03-VIP DEP",
            searchStr: "FO03",
            saveFn: this.vipDep
        }, 
        {
            name: "FO01-Arrival Detailed",
            searchStr: "FO01",
            saveFn: this.arrAll
        }, 
        {
            name: "FO02-Guests INH by Room",
            searchStr: "FO02",
            saveFn: this.inhAll
        }, 
        {
            name: "FO03-Departures",
            searchStr: "FO03",
            saveFn: this.depAll
        },
        {
            name: "FO11-Credit Limit",
            searchStr: "FO11",
            saveFn: this.creditLimit
        }, 
        {
            name: "FO13-Package Forecast（仅早餐）",
            searchStr: "FO13",
            saveFn: this.bbf
        }, 
        {
            name: "Rooms-housekeepingstatus",
            searchStr: "%hkroomstatusperroom",
            saveFn: this.rooms
        }, 
        {
            name: "HK03-OOO",
            searchStr: "HK03",
            saveFn: this.ooo
        }, 
        {
            name: "Group Rooming List",
            searchStr: "grprmlist",
            saveFn: this.groupRoom
        }, 
        {
            name: "Group In House",
            searchStr: "grpinhouse",
            saveFn: this.groupInh
        }, 
        {
            name: "FO08-No Show",
            searchStr: "FO08",
            saveFn: this.noShow
        }, 
        {
            name: "Cancellations",
            searchStr: "rescancel",
            saveFn: this.cancel
        }, 
        {
            name: "Reservation Traces",
            searchStr: "%gitraces",
            saveFn: this.reservationTraces
        }, 
        {
            name: "Guest In House w/o Due Out(VIP INH)",
            searchStr: "%guestinhw",
            saveFn: this.vipInh
        }
    ]

    static downtimeReports := [
        {
            name: "FO01-Arrival Detailed",
            searchStr: "FO01",
            saveFn: this.arrAll
        },
        {
            name: "FO02-Guests INH by Room",
            searchStr: "FO02",
            saveFn: this.inhAll
        },
        {
            name: "FO03-Departures",
            searchStr: "FO03",
            saveFn: this.depAll
        },
        {
            name: "FO11-Credit Limit",
            searchStr: "FO11",
            saveFn: this.creditLimit
        },
        {
            name: "Rooms-housekeepingstatus",
            searchStr: "%hkroomstatusperroom",
            saveFn: this.rooms
        },
        {
            name: "HK03-OOO",
            searchStr: "HK03",
            saveFn: this.ooo
        },
        {
            name: "Reservation Traces",
            searchStr: "%gitraces",
            saveFn: this.reservationTraces
        },
        {
            name: "Group Rooming List",
            searchStr: "grprmlist",
            saveFn: this.groupRoom
        },
        {
            name: "Group In House",
            searchStr: "grpinhouse",
            saveFn: this.groupInh
        }
    ]

    static miscReports := [
        {
            name: "FO13 - Packages",
            searchStr: "pkgforecast",
            saveFn: this.packages    
        },
        {
            name: "WSHGZ - Specials",
            searchStr: "Wshgz_special",
            saveFn: this.specials            
        },
        {
            name: "预抵消费券",
            searchStr: "FO01-Arrival",
            saveFn: this.arrivingCoupons
        },
        {
            name: "当天夜退房间",
            searchStr: "departure_all",
            saveFn: this.onDayLateOut
        },
        {
            name: "昨日住房国籍数量",
            searchStr: "stat_countrybyday",
            saveFn: this.countryByDate
        },
        {
            name: "Market Segment",
            searchStr: "RS07",
            saveFn: this.marketStats
        },
        {
            name: "可售房型余量",
            searchStr: "detail_avail",
            saveFn: this.detailedAvailability
        },
    ]

    static reportList := {
        onr: this.overnightReports,
        downtime: this.downtimeReports,
        groupArr: {
            name: "Group Arrival - 当天预抵团单",
            searchStr: "GRPRMLIST",
            saveFn: this.arrivingGroups
        }
    }


    static handleBrowserReopen(browser, pmsURL, username, password) {
        SUSPEND_CONTROLLER.suspendOtherScripts()
        ; close all pms win
        utils.killApp("360se.exe")

        Run(browser . " " . pmsURL)
        WinWait("OPERA Login")
        WinMaximize("OPERA Login")
        WinActivate("OPERA Login")
        Sleep(200)

        ; log into opera
        found := PmsImageFinder.find("opera-login-anchor.png", 10)
        MouseMove(found.outX + 29, found.outY - 168)
        if (!found) {
            return found
        }
        Click(found.outX + 29, found.outY - 168)
        Sleep(100)
        Send("{TEXT}" . username)
        Sleep(200)
        Send("{Tab}")
        Sleep(200)
        Send("{TEXT}" . password)
        Sleep(200)
        loop 3 {
            Send("{Tab}")
            Sleep(200)
        }
        Send("{Enter}")
        utils.waitLoading(1000)

        loop {
            found := ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["pms-login.png"])
            if (found) {
                break
            }
            Sleep(500)
        }
        Click(x, y)

        ; wait for PMS app
        WinWait("OPERA PMS")
        WinActivate("OPERA PMS")
        utils.waitLoading(2000)

        ; wait for window standby
        loop {
            found := ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight, IMAGES["opera-logo.png"])
            if (found) {
                break
            }
            Sleep(500)
        }

        SUSPEND_CONTROLLER.restoreAllScripts()
    }


    /**
     * 
     * @param reportDescriptor 
     * @param {"PDF" | "XML" | "TXT" | "XLS"} fileType 
     * @param {Integer} initX 
     * @param {Integer} initY 
     * @returns {void | String} 
     */
    static reportFiling(reportDescriptor, fileType, initX := 433, initY := 598) {
        fileTypeSelectPointer := Map(
            "HTML", -1,
            "PDF", 0,
            "XML", 2,
            "TXT", 4,
            "XLS", 5,
        )

        Send("!m")
        Sleep(100)
        Send("{Text}R")
        utils.waitLoading(400)
        Send(Format("{Text}{1}", reportDescriptor.searchStr))
        Sleep(200)
        Send("!h")
        utils.waitLoading()
        Send("!i")
        utils.waitLoading()
        Send("{Tab}")
        Sleep(100)

        if (fileTypeSelectPointer[fileType] > 0) {
            loop fileTypeSelectPointer[fileType] {
                Send("{Down}")
                Sleep(10)
            }
        }
        else {
            loop Abs(fileTypeSelectPointer[fileType]) {
                Send("{Up}")
                Sleep(Random(100, 500))
            }
        }
        Send("!o")
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        ; run saving actions, return filename
        reportFn := reportDescriptor.saveFn
        if (reportDescriptor.searchStr = "GRPRMLIST" && reportDescriptor.name = "Group Arrival - 当天预抵团单") {
            saveName := reportFn(this, reportDescriptor.blockCode, reportDescriptor.blockName)
        } else {
            saveName := reportDescriptor.hasOwnProp("args")
                ? reportFn(this, reportDescriptor.args*)
                : reportFn(this)
        }
        saveFileName := (saveName ? saveName : reportDescriptor.name) . "." . fileType

        Sleep(1000)
        Send("!f")

        WinWait("Please Select a Directory to Download")
        Sleep(200)
        Send("{Backspace}")
        Sleep(200)
        Send(Format("{Text}{1}", saveFileName))
        Sleep(1000)
        Send("{Enter}")

        TrayTip(Format("正在保存：{1}", saveFileName))
        if (!this.isRunning) {
            msgbox("脚本已终止", POPUP_TITLE, "4096 T1")
            return
        }

        if (!this.isRunning) {
            this.end()
            return
        }
        sleep(1000)

        if (Winwait("Warning", , 20)) {
            WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
            Sleep(100)
            WinActivate("Warning")
            utils.waitLoading()
            Send("{Enter}")
            utils.waitLoading()
            WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
        }

        waitIndex := 0
        loop {
            Sleep(1000)
            if (FileExist(A_MyDocuments . "\" . saveFileName)) {
                break
            }
            waitIndex++
        } until (waitIndex > 30)
        if (waitIndex > 30) {
            this.isRunning := false
        }
        MouseMove(initX, initY)
        utils.waitLoading()
        Click()
        Sleep(200)
        Send("!c")

        if (!this.isRunning) {
            MsgBox("保存出错，脚本已终止。", "ReportMaster", "T1 4096")
            this.end()
            return
        }

        return saveFileName
    }

    /**
     * 
     * @param {Array} reportDescriptors
     * @param {"PDF" | "XML" | "TXT" | "XLS"} fileType 
     * @returns {String} saved report names
     */
    static saveReports(reportDescriptors, fileType) {
        savedReports := ""

        for reportObj in reportDescriptors {
            if (!ReportMaster_Action.isRunning && A_Index > 1) {
                return
            }

            started := this.start()
            if (!started) {
                MsgBox("Opera PMS 未启动，请登录后重试", POPUP_TITLE, "4096 T1 icon!")
                return
            }
            res := ReportMaster_Action.reportFiling(reportObj, fileType)
            Sleep(Random(1000, 1500))
            if (!res) {
                continue
            }
            
            savedReports .= reportObj.name . "`n"
        }

        this.end()

        return savedReports
    }

    static comp() {
        fileName := "Comp"
        Sleep(Random(100,500))
        return fileName
    }

    static mgrFlash(initX := 749, initY := 333) {
        fileName := "NA02-MANAGER FLASH"
        Sleep(Random(100,500))
        MouseMove(initX, initY) ; 749, 333
        Sleep(Random(100,500))
        Send("!o")
        MouseMove(initX - 149, initY + 169) ; 600, 502
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
        return fileName
    }

    static hisFor15(initX := 644, initY := 178) {
        fileName := "RS05-林总"
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 644, 178
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 102, initY - 8) ; 542, 170
        Sleep(Random(100,500))
        Click("Up")
        MouseMove(initX - 117, initY - 27) ; 527, 151
        Sleep(Random(100,500))
        Send("{NumpadSub}")
        Sleep(Random(100,500))
        Send("8")
        MouseMove(initX + 2, initY + 26) ; 646, 204
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 111, initY + 41) ; 533, 219
        Sleep(Random(100,500))
        Click("Up")
        MouseMove(initX - 171, initY + 92) ; 473, 270
        Sleep(Random(100,500))
        Send("{NumpadSub}")
        Sleep(Random(100,500))
        Send("8")
        MouseMove(initX - 27, initY + 463) ; 617, 641
        Sleep(Random(100,500))
        Send("{Tab}")
        MouseMove(initX - 34, initY + 511) ; 610, 689
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
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
        Sleep(Random(100,500))
        Send("{Backspace}")
        Sleep(Random(100,500))
        Send(Format("{Text}{1}", dateFirst))
        Sleep(Random(100,500))
        MouseMove(initX, initY) ; 645, 205
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 114, initY - 1) ; 531, 204
        Sleep(Random(100,500))
        Click("Up")
        Sleep(Random(100,500))
        Send("{Backspace}")
        Sleep(Random(100,500))
        Send(Format("{Text}{1}", dateLast))
        Sleep(Random(100,500))
        MouseMove(initX - 28, initY + 436) ; 617, 641
        Sleep(Random(100,500))
        Send("{Tab}")
        MouseMove(initX - 35, initY + 484) ; 610, 689
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
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
        Sleep(Random(100,500))
        ; report options here
        Send("{Backspace}")
        Sleep(Random(100,500))
        Send(Format("{Text}{1}", dateFirstNext))
        Sleep(Random(100,500))
        MouseMove(initX, initY) ; 645, 205
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 114, initY - 1) ; 531, 204
        Sleep(Random(100,500))
        Click("Up")
        Sleep(Random(100,500))
        Send("{Backspace}")
        Sleep(Random(100,500))
        Send(Format("{Text}{1}", dateLastNext))
        Sleep(Random(100,500))
        MouseMove(initX - 28, initY + 436) ; 617, 641
        Sleep(Random(100,500))
        Send("{Tab}")
        MouseMove(initX - 35, initY + 484) ; 610, 689
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
        return fileName
    }

    static vipArr(initX := 464, initY := 194) {
        fileName := "FO01-VIP ARR"
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 464, 194
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 128, initY + 4) ; 336, 198
        Sleep(Random(100,500))
        Click("Up")
        Sleep(Random(100,500))
        Send("{NumpadAdd}")
        Sleep(Random(100,500))
        Send("{Text}2")
        Sleep(Random(100,500))
        MouseMove(initX + 146, initY + 426) ; 610, 620
        Sleep(Random(100,500))
        Click()
        MouseMove(initX + 168, initY + 399) ; 632, 593
        Sleep(Random(100,500))
        Click()
        MouseMove(initX + 146, initY + 549) ; 610, 743
        Sleep(Random(100,500))
        return fileName
    }

    static vipInh() {
        fileName := "VIP INH-Guest INH without due out"
        Sleep(Random(100,500))
        return fileName
    }

    static vipDep(initX := 622, initY := 391) {
        fileName := "FO03-VIP DEP"
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY)
        Sleep(Random(100,500))
        Click()
        MouseMove(855, 391)
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
        Send("!a")
        Sleep(Random(100,500))
        Send("!o")
        Sleep(Random(100,500))
        return fileName
    }

    static arrAll(initX := 309, initY := 566) {
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 309, 566
        Sleep(Random(100,500))
        Click()
        MouseMove(initX + 8, initY + 53) ; 317, 619
        Sleep(Random(100,500))
        Click()
        MouseMove(initX + 16, initY + 97) ; 325, 663
        Sleep(Random(100,500))
        Click()
        MouseMove(initX + 290, initY + 28) ; 599, 594
        Sleep(Random(100,500))
        Click()
        MouseMove(initX + 299, initY + 52) ; 608, 618
        Click()
        Sleep(Random(100,500))
    }

    static inhAll(initX := 433, initY := 523) {
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 433, 523
        Sleep(Random(100,500))
        Click()
    }

    static depAll(initX := 607, initY := 540) {
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 607, 540
        Sleep(Random(100,500))
        click()
        Sleep(Random(100,500))
        MouseMove(initX - 119, initY - 50) ; 488, 490
        Sleep(Random(100,500))
        Click()
    }

    static creditLimit(initX := 686, initY := 474) {
        ; BlockInput true
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 686, 474
        Click()
        MouseMove(initX - 277, initY + 48) ; 409, 522
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
    }

    static bbf(initX := 599, initY := 276) {
        fileName := "FO13-Packages 早餐"
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 599, 276
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 80, initY + 3) ; 519, 279
        Sleep(Random(100,500))
        Click("Up")
        Sleep(Random(100,500))
        Send("{NumpadSub}")
        Sleep(Random(100,500))
        Send("1")
        Sleep(Random(100,500))
        Send("{Enter}")
        MouseMove(initX + 10, initY - 7) ; 609, 269
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 129, initY + 7) ; 470, 283
        Sleep(Random(100,500))
        Click("Up")
        Sleep(Random(100,500))
        Send("^c")
        Sleep(Random(100,500))
        MouseMove(initX + 6, initY + 27) ; 605, 303
        Sleep(Random(100,500))
        MouseMove(initX + 6, initY + 27) ; 605, 303
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 103, initY + 30) ; 496, 306
        Sleep(Random(100,500))
        Click("Up")
        MouseMove(initX - 105, initY + 31) ; 494, 307
        Sleep(Random(100,500))
        Send("^v")
        Sleep(Random(100,500))
        MouseMove(initX - 136, initY + 242) ; 463, 518
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
        return fileName
    }

    static rooms(initX := 476, initY := 515) {
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY)
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
    }

    static ooo() {
        fileName := "HK03-OOO"
        Sleep(Random(100,500))
        return fileName
    }

    static groupRoom(initX := 372, initY := 544) {
        fileName := "Group Rooming List"
        ; BlockInput true
        ; reportOpen(searchStr)
        Sleep(Random(100,500))
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
            sleep(Random(100,500))
            Send("{Tab}")
        }

        Sleep(Random(100,500))
        Send("{Space}")

        Sleep(Random(100,500))
        Send("{Tab}")
        Sleep(Random(100,500))
        Send("{Space}")

        loop 5 {
            sleep(Random(100,500))
            Send("{Tab}")
        }
        Sleep(Random(100,500))
        Send("{Space}")

        loop 4 {
            sleep(Random(100,500))
            Send("{Tab}")
        }
        Sleep(Random(100,500))
        Send("{Space}")

        return fileName
    }

    static groupInh(initX := 470, initY := 425) {
        ; reportOpen(searchStr)
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 470, 425
        Sleep(Random(100,500))
        Click()
        MouseMove(initX + 155, initY + 68) ; 625, 493
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
    }

    static noShow(initX := 573, initY := 440) {
        fileName := "FO08-NO SHOW"
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY)
        Sleep(Random(100,500))
        Send("{Backspace}")
        Sleep(Random(100,500))
        Send("{NumpadSub}")
        Sleep(Random(100,500))
        Send("{Text}1")
        Sleep(Random(100,500))
        Send("{Tab}")
        Sleep(Random(100,500))
        Send("{NumpadSub}")
        Sleep(Random(100,500))
        Send("{Text}1")
        Sleep(Random(100,500))
        return fileName
    }

    static cancel(initX := 601, initY := 291) {
        fileName := "CXL"
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 601, 291
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 196, initY - 13) ; 485, 278
        Sleep(Random(100,500))
        Click("Up")
        Sleep(Random(100,500))
        Send("{Backspace}")
        Sleep(Random(100,500))
        Send("{NumpadSub}")
        Sleep(Random(100,500))
        Send("{Text}1")
        Sleep(Random(100,500))
        Send("{Enter}")
        Sleep(Random(100,500))
        MouseMove(initX + 1, initY - 3) ; 602, 288
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 153, initY + 1) ; 448, 292
        Sleep(Random(100,500))
        Click("Up")
        Sleep(Random(100,500))
        Send("^c")
        Sleep(Random(100,500))
        MouseMove(initX - 15, initY + 18) ; 586, 309
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 188, initY + 30) ; 413, 321
        Sleep(Random(100,500))
        Click("Up")
        MouseMove(initX - 162, initY + 34) ; 439, 325
        Sleep(Random(100,500))
        Send(A_Clipboard)
        MouseMove(initX + 86, initY + 26) ; 687, 317
        Sleep(Random(100,500))
        Click()
        MouseMove(initX + 94, initY + 32) ; 695, 323
        Sleep(Random(100,500))
        return fileName
    }

    static arrivingGroups(blockCodeInput, saveName, initX := 845, initY := 376) {
        fileName := saveName
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 845, 376
        Sleep(Random(100,500))
        Click()
        MouseMove(initX - 41, initY + 10) ; 804, 386
        Sleep(Random(100,500))
        Send("!a")
        Sleep(Random(100,500))
        MouseMove(initX - 37, initY + 229) ; 808, 605
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 40, initY + 239) ; 805, 614
        Sleep(Random(100,500))
        Click("Up")
        MouseMove(initX - 108, initY + 239) ; 737, 615
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
        loop 8 {
            Send("{Space}")
            Sleep(100)
            Send("{Up}")
            Sleep(100)
        }
        Sleep(Random(100,500))
        Send("!o")
        Sleep(Random(100,500))
        MouseMove(initX - 3, initY - 52) ; 842, 324
        Sleep(Random(100,500))
        Click()
        MouseMove(initX - 276, initY - 93) ; 569, 283
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
        Send(Format("{Text}{1}", blockCodeInput))
        Sleep(Random(100,500))
        MouseMove(initX + 3, initY - 95) ; 848, 281
        Sleep(Random(100,500))
        Click()
        MouseMove(initX - 242, initY + 36) ; 603, 412
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
        Send("{Space}")
        MouseMove(initX - 117, initY + 97) ; 728, 473
        Sleep(Random(100,500))
        Send("!o")
        Sleep(Random(100,500))
        Send("!o")
        Sleep(Random(100,500))
        MouseMove(initX - 134, initY + 115) ; 711, 491
        Sleep(Random(100,500))
        Click()
        MouseMove(initX - 423, initY + 144) ; 422, 520
        Sleep(Random(100,500))
        Click()
        MouseMove(initX - 236, initY + 271) ; 609, 647
        return fileName
    }

    static arrivingFedex(initX := 845, initY := 376) {
        fileName := Format("{1}-FEDEX-ARRIVAL", FormatTime(A_Now, "yyyyMMdd"))

        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 845, 376
        Sleep(Random(100,500))
        Click()
        MouseMove(initX - 41, initY + 10) ; 804, 386
        utils.waitLoading()
        Send("!a")
        utils.waitLoading()
        MouseMove(initX - 37, initY + 229) ; 808, 605
        Sleep(Random(100,500))
        Click("Down")
        MouseMove(initX - 40, initY + 239) ; 805, 614
        Sleep(Random(100,500))
        Click("Up")
        MouseMove(initX - 108, initY + 239) ; 737, 615
        Sleep(Random(100,500))
        Click()
        utils.waitLoading()
        loop 8 {
            Send("{Space}")
            utils.waitLoading(100)
            Send("{Up}")
            utils.waitLoading(100)
        }
        Sleep(Random(100,500))
        Send("!o")
        utils.waitLoading()
        MouseMove(initX - 3, initY - 52) ; 842, 324
        Sleep(Random(100,500))
        Click()
        utils.waitLoading()
        MouseMove(initX - 276, initY - 93) ; 569, 283
        Sleep(Random(100,500))
        Click()
        utils.waitLoading()
        Sleep(Random(100,500))
        Send(Format("{Text}{1}", "%FEDEX"))
        Sleep(Random(100,500))
        ; MouseMove(initX + 3, initY - 95) ; 848, 281
        ; Sleep(150)
        ; Click()
        ; MouseMove(initX - 242, initY + 36) ; 603, 412
        ; Sleep(150)
        ; Click()
        ; Sleep(150)
        ; Send("{Space}")
        ; MouseMove(initX - 117, initY + 97) ; 728, 473
        Send("!h")
        utils.waitLoading()
        Send("!a")
        utils.waitLoading()
        Sleep(Random(100,500))
        Send("!o")
        utils.waitLoading()

        ; check ETA
        loop 6 {
            Send("{Tab}")
            Sleep(Random(100,500))
        }
        Send("{Space}")

        Sleep(Random(100,500))
        Send("!o")
        utils.waitLoading()

        MouseMove(initX - 236, initY + 271) ; 609, 647
        return fileName
    }

    static special(initX := 600, initY := 482) {
        fileName := Format("{1} 水果5", FormatTime(A_Now, "yyyyMMdd"))
        Sleep(Random(100,500))
        ; report options here
        MouseMove(initX, initY) ; 600, 482
        Sleep(Random(100,500))
        Click()
        Sleep(Random(100,500))
        Send("{Text}水果5")
        Sleep(Random(100,500))
        MouseMove(initX + 16, initY + 56) ; 616, 538
        Sleep(Random(100,500))
        return fileName
    }

    /**
     * @param {String} spCodes 
     * @param {String} fileNameInput
     * @param {Integer} [initX=600] 
     * @param {Integer} [initY=482] 
     * @returns {String} 
     */
    static specials(spCodes, fileNameInput, frDate, toDate, initX := 600, initY := 482) {
        if (!spCodes) {
            return
        }

        fileName := Format("{1}-{2}", FormatTime(A_Now, "yyyyMMdd"), fileNameInput)
        ; report options here
        Send("{Text}" . frDate.toFormat("MMddyyyy"))
        Sleep(Random(100,500))
        Send("{Tab}")
        Sleep(Random(100,500))

        Send("{Text}" . toDate.toFormat("MMddyyyy"))
        Sleep(Random(100,500))
        Send("{Tab}")
        Sleep(Random(100,500))

        Send(spCodes.replace(" ", ","))
        Sleep(Random(100,500))

        return fileName
    }

    /**
     * @param {String} pkgCodes 
     * @param {String} fileNameInput 
     * @param {String} frDate 
     * @param {String} toDate 
     * @param {Integer} initX 
     * @param {Integer} initY 
     * @returns {String}
     */
    static packages(pkgCodes, fileNameInput, frDate, toDate, groupByPkg := true, initX := 600, initY := 482) {
        if (!pkgCodes) {
            return
        }

        fmtFrDate := frDate.toFormat("yyyyMMdd")
        fmtToDate := frDate.toFormat("yyyyMMdd")

        fileNameDate := fmtFrDate == fmtToDate ? fmtFrDate : fmtFrDate . "-" . fmtToDate
        fileName := Format("{1}-{2}", fileNameDate, fileNameInput)

        ; dates
        Send("{Tab}")
        Sleep(Random(100,500))
        Send("{Text}" . frDate.toFormat("MMddyyyy"))
        Sleep(Random(100,500))
        Send("{Tab}")
        Sleep(Random(100,500))
        Send("{Text}" . toDate.toFormat("MMddyyyy"))
        Sleep(Random(100,500))

        ; package codes(products)
        loop 2 {
            Send("{Tab}")
            Sleep(Random(100,500))
        }

        if (!pkgCodes.includes("%")) {
            Send("{Text}" . pkgCodes.replace(" ", ","))
        }
        else {
            Send("{Text}%")
            Sleep(Random(100,500))
            Send("{Enter}")
            utils.waitLoading()
            Send("{Text}" . pkgCodes) ; products input
            Sleep(Random(100,500))
            Send("!h") ; search
            utils.waitLoading()
            Send("!a") ; select all
            utils.waitLoading()
            Send("!o") ; ok
            utils.waitLoading()
        }

        ; include pseudo rooms(apartments/presidential)
        Send("!e")
        Sleep(Random(100,500))

        ; remove GroupBy condition
        if (!groupByPkg) {
            loop 3 {
                Send("{Tab}")
                Sleep(Random(100,500))
            }
            Send("{Down}")
            Sleep(Random(100,500))
        }

        return fileName
    }

    static reservationTraces(initX := 600, initY := 482) {
        loop 6 {
            Send("{Tab}")
            utils.waitLoading(Random(100,500))
        }

        ; Include reservation types
        ; pseudo rooms
        Send("{space}")
        utils.waitLoading(Random(100,500))
        Send("{Tab}")
        utils.waitLoading(Random(100,500))

        ; skip checked-in and check reserved
        Send("{Tab}")
        utils.waitLoading(Random(100,500))
        Send("{space}")
        utils.waitLoading(Random(100,500))
        Send("{Tab}")
        utils.waitLoading(Random(100,500))

        ; check due out
        Send("{space}")
        utils.waitLoading(Random(100,500))
        Send("{Tab}")
        utils.waitLoading(Random(100,500))

        ; check checked-out
        Send("{space}")
        utils.waitLoading(Random(100,500))
        Send("{Tab}")
        utils.waitLoading(Random(100,500))

        ; check notes and specials
        loop 2 {
            Send("{Tab}")
            utils.waitLoading(Random(100,500))
        }
        Send("{space}")
        utils.waitLoading(Random(100,500))
        Send("{Tab}")
        utils.waitLoading(Random(100,500))
        Send("{Tab}")
        utils.waitLoading(Random(100,500))
        Send("{space}")
        utils.waitLoading(Random(100,500))

        fileName := "Reservation Traces"
        return fileName
    }

    static depForBatchOut() {
        fileName := Format("{1} - Departures", FormatTime(A_Now, "yyyyMMdd"))

        WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
        BlockInput(false)

        Sleep(1000)
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
            Reload()
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

        Sleep(100)
        WinSetAlwaysOnTop(true, "ahk_class SunAwtFrame")
        BlockInput(true)

        WinActivate("ahk_class SunAwtFrame")
        Sleep(100)
        MouseMove(490, 363)
        Sleep(100)
        Click(3)
        Sleep(100)
        Send(Format("{Text}{1}", frTime))
        Sleep(100)
        Send("{Tab}")
        Sleep(100)
        Send(Format("{Text}{1}", toTime))
        Sleep(100)
        loop 7 {
            Send("{Tab}")
            Sleep(100)
        }
        Send("{Space}")
        Sleep(100)
        Send("{Tab}")
        Sleep(100)
        Send("{Space}")

        return fileName
    }

    static arrivingCoupons() {
        Sleep(500)
        topLeft := PmsImageFinder.find("opera-active-win.png")
        if (!topLeft) {
            return
        }

        ; filter rate codes
        Click(topLeft.outX + 648, topLeft.outY + 215)
        utils.waitLoading()
        Send("!n")
        utils.waitLoading()
        Send("{Tab}")
        utils.waitLoading()
        Send("{Text}%通")
        Sleep(Random(100,500))
        Send("!h")
        utils.waitLoading()
        Send("!a")
        utils.waitLoading()
        Send("{Text}%消")
        Sleep(Random(100,500))
        Send("!h")
        utils.waitLoading()
        Send("!a")
        utils.waitLoading()
        Send("!o")
        utils.waitLoading()

        ; check Notes
        loop 19 {
            Send("{Tab}")
            Sleep(Random(100,500))
        }
        Send("{Space}")
    }

    static onDayLateOut() {
        CoordMode("Mouse", "Screen")
        Sleep(Random(100,500))
        topLeft := PmsImageFinder.find("opera-active-win.png")
        if (!topLeft) {
            return
        }

        ; enter depart from time
        loop 6 {
            Send("{Tab}")
            Sleep(100)
        }
        Send("{Text}1700")

        ; sort order -> Departure Time
        ; Click(topLeft.outX + 584, topLeft.outY + 465)
        Click(854, 639)
        utils.waitLoading()
        Send("!r")
        utils.waitLoading()
        Send("!o")
        utils.waitLoading()
        ; Click(topLeft.outX + 584, topLeft.outY + 465)
        Click(854, 639)
        utils.waitLoading()
        loop 2 {
            Send("{Down}")
            Sleep(Random(100,500))
        }
        Send("!a")
        utils.waitLoading()
        Send("!o")
        utils.waitLoading()
    }

    static countryByDate() {
        Send("{Text}" . FormatTime(DateAdd(A_Now, -1, "Days"), "MM-dd-yy"))
        utils.waitLoading()

        ; uncheck Display-Room Nights
        loop 5 {
            Send("{Tab}")
            Sleep(Random(100,500))
        }
        Send("{Space}")
        Sleep(Random(100,500))

        ; Check Display-Adult Nights
        loop 2 {
            Send("{Tab}")
            Sleep(Random(100,500))
        }
        Send("{Space}")
        Sleep(Random(100,500))
    }

    ; for Revenue
    static hisForSixMonths(initX := 645, initY := 205) {
        startDate := A_Mon "01" A_Year
        endDate := pipe(
            x => (x + 7 > 12 ? x + 7 - 12 : x + 7),
            x => x > 10 ? String(x) : Format("0{}", x),
            x => Format("{}{}{}", x < A_Mon ? A_Year + 1 : A_Year, x, "01"),
            x => DateAdd(x, -1, "Days"),
            x => FormatTime(x, "MMddyyyy")
        )(Integer(A_Mon))

        Sleep(Random(100,500))
        Send("{Backspace}")
        Sleep(Random(100,500))
        Send(Format("{Text}{1}", startDate))
        Sleep(Random(100,500))
        MouseClickDrag("Left", initX, initY, initX - 114, initY - 1) ; 645, 205, 531, 204
        Sleep(Random(100,500))
        Send("{Backspace}")
        Sleep(Random(100,500))
        Send(Format("{Text}{1}", endDate))
        Sleep(Random(100,500))
        Click(initX - 28, initY + 436) ; 617, 641
        Sleep(Random(100,500))
        Send("{Tab}")
        Sleep(Random(100,500))
        Click(initX - 35, initY + 484) ; 610, 689
        Sleep(Random(100,500))

        return Format("RS05 H&F {}-{}", FormatTime(startDate, "yyyy.MM.dd"), FormatTime("yyyy.MM.dd"))
    }

    /**
     * @param {"MarketCode"|"SourceCode"} groupBy 
     */
    static marketStats(groupBy, queryDate) {
        ; groupby changes `GroupBy` and `SubGroupBy`
        Send("{Text}" . FormatTime(queryDate, "MMddyyyy"))
        Sleep(10)
        Send("{Tab}")

        if (groupBy == "SourceCode") {
            Send("!g")
            Sleep(Random(100,500))
            Send("!g")
            Sleep(Random(100,500))
            Send("{Tab}")
            Sleep(Random(100,500))

            loop 2 {
                Send("{Down}")
                Sleep(Random(100,500))
            }
            Send("{Tab}")
            Sleep(Random(100,500))
            loop 2 {
                Send("{Down}")
                Sleep(Random(100,500))
            }
        }
    }

    ; search: "detail_avail"
    static detailedAvailability() {
        fromDate := FormatTime(A_Now, "MMddyyyy")
        toDate := FormatTime(DateAdd(A_Now, 72, "Days"), "MMddyyyy")
        roomClasses := ["STD", "DEX", "CDR", "CES", "CPS"]

        found := PmsImageFinder.find("opera-active-win.png")
        if (!found) {
            return
        }

        ; send dates
        Send("{Text}" fromDate)
        Send("{Tab}")
        Sleep(Random(100,500))
        Send("{Text}" toDate)
        Sleep(Random(100,500))

        ; enter room class filter
        Click(found.outX + 360, found.outY + 117)
        utils.waitLoading()
        for (roomCls in roomClasses) {
            Send("{Text}" roomCls)
            Send("!h")
            utils.waitLoading()
            Send("!a")
            utils.waitLoading()
        }
        Send("!o")
        utils.waitLoading(300)

        ; select "non-deduct"
        Send("!n")
        utils.waitLoading(300)
    }
}
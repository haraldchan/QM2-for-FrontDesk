class useReport {
    __New(searchString, fileName, fileType, optionFn := 0) {
        this.searchString := searchString
        this.fileType := fileType
        this.saveFileName := fileName . "." . fileType
        this.optionFn := optionFn
        this.initX := 433
        this.initY :=
            this.fileTypeSelectPointer := Map(
                "PDF", 0,
                "XML", 2,
                "TXT", 4,
                "XLS", 5,
            )
    }

    runSaving() {
        this.chooseReport()
        this.chooseOptions()
        this.saveReport()
    }

    chooseReport() {
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        BlockInput true
        Sleep 100
        Send "!m"
        Sleep 100
        Send "{Text}R"
        Sleep 100
        Send Format("{Text}{1}", this.searchString)
        Sleep 100
        Send "!h"
        Sleep 100
        MouseMove this.initX, this.initY ; 433, 598
        Sleep 150
        Click ; click print to file
        Sleep 150

        ; TODO: select saving file type
        MouseMove this.initX + 380, this.initY
        Click
        if (this.fileTypeSelectPointer[this.fileType] != 0) {
            loop this.fileTypeSelectPointer[this.fileType] {
                Send "{Down}"
                Sleep 10
            }
        }
        Sleep 100
        Send "{Enter}"
        Sleep 100
        Send "!o"
        Sleep 100
    }

    chooseOptions() {
        if (this.optionFn = 0) {
            return
        }
        this.optionFn()
    }

    saveReport() {
        Sleep 1000
        Send "!f"
        Sleep 1000
        Send "{Backspace}"
        Sleep 200
        Send Format("{Text}{1}", this.saveFileName)
        Sleep 1000
        Send "{Enter}"

        TrayTip Format("正在保存：{1}", this.saveFileName)
        loop {
            sleep 1000
            if (FileExist(A_MyDocuments . "\" . this.saveFileName)) {
                break
            }
            if (A_Index = 30000) {
                MsgBox("保存出错，脚本已中断。", "Report Master Next", "T1 4096")
            }
        }

        Sleep 200
        Send "!c"
        BlockInput false
        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
    }
}

class Complimentary extends useReport {
    __New(fileType) {
        super.__New("%complimentary", "Comp", fileType)
        this.label := "Guest INH Complimentary"
    }
}

class ManagerFlash extends useReport {
    __New(fileType) {
        super.__New("FI01", "NA02-MANAGER FLASH", fileType, this.optioning)
        this.label := "NA02-Manager Flash"
    }

    optioning(initX := 749, initY := 333) {
        Sleep 200
        MouseMove initX, initY ; 749, 333
        Sleep 150
        Send "!o"
        MouseMove initX - 149, initY + 169 ; 600, 502
        Sleep 150
        Click
        Sleep 150
    }
}

class HistoryForecast extends useReport {

}

class HistoryForecastThisMonth extends HistoryForecast {

}

class HistoryForecastNextMonth extends HistoryForecast {

}

class VipArrival extends useReport {
    __New(fileType) {
        super.__New("FI01-VIP", "FO01-VIP ARR", fileType, this.optioning)
        this.label := "VIP Arrival (VIP Arr)"
    }

    optioning(initX := 464, initY := 194) {
        Sleep 200
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
    }
}

class VipInHouse extends useReport {
    __New(fileType) {
        super.__New("%guestinhw", "Guest In House w/o Due Out(VIP INH)", fileType)
        this.label := "VIP INH-Guest INH without due out"
    }
}

class VipDeparture extends useReport {
    __New(fileType) {
        super.__New("FI03", "FO03-VIP DEP", fileType, this.optioning)
        this.label := "VIP Departure"
    }

    optioning(initX := 622, initY := 391) {
        Sleep 200
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
    }
}

class ArrivalAll extends useReport {
    __New(fileType) {
        super.__New("FO01", "FO01-Arrival Detailed", fileType, this.optioning)
        this.label := "FO01-Arrival Detailed"
    }

    optioning(initX := 309, initY := 566) {
        Sleep 200
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
    }
}

class InHouseAll extends useReport {
    __New(fileType) {
        super.__New("FO02", "FO02-INH", fileType, this.optioning)
        this.label := "FO02-Guests INH by Room"
    }

    optioning(initX := 433, initY := 523) {
        Sleep 200
        MouseMove initX, initY ; 433, 523
        Sleep 150
        Click
    }
}

class DepartureAll extends useReport {
    __New(fileType) {
        super.__New("FO03", "FO03-DEP", fileType, this.optioning)
        this.label := "FO03-Departures"
    }

    optioning(initX := 433, initY := 523) {
        Sleep 200
        MouseMove initX, initY ; 433, 523
        Sleep 150
        Click
    }
}

class CreditLimits extends useReport {
    __New(fileType) {
        super.__New("FO11", "FO11-CREDIT LIMIT", fileType, this.optioning)
        this.label := "FO11-Credit Limit"
    }

    optioning(initX := 686, initY := 474) {
        Sleep 200
        MouseMove initX, initY ; 686, 474
        Click
        MouseMove initX - 277, initY + 48 ; 409, 522
        Sleep 150
        Click
        Sleep 200
    }
}

class Rooms extends useReport {
    __New(fileType) {
        super.__New("%hkroomstatusperroom", "Rooms", fileType, this.optioning)
        this.label := "Rooms-housekeepingstatus"
    }

    optioning(initX := 476, initY := 515) {
        Sleep 200
        MouseMove initX, initY
        Sleep 150
        Click
        Sleep 150
    }
}

class OutOfOrder extends useReport {
    __New(fileType) {
        super.__New("HK03", "HK03-OOO", fileType, this.optioning)
        this.label := "HK03-OOO"
    }
}

class GroupRoomingListAll extends useReport {
    __New(fileType) {
        super.__New("%grprmlist", "Group Rooming List", fileType, this.optioning)
        this.label := "Group Rooming List"
    }

    optioning(initX := 372, initY := 544) {
        Sleep 200
        MouseMove initX, initY ; 372, 544
        Sleep 150
        Click
        MouseMove initX + 148, initY - 78 ; 520, 466
        Sleep 150
        Click
        MouseMove initX + 160, initY + 5 ; 532, 549
        Sleep 150
        Click
        Sleep 150
    }
}

class GroupInHouseAll extends useReport {
    __New(fileType) {
        super.__New("%grpinhouse", "Group In House", fileType, this.optioning)
        this.label := "Group In House"
    }

    optioning(initX := 470, initY := 425) {
        Sleep 200
        MouseMove initX, initY ; 470, 425
        Sleep 150
        Click
        MouseMove initX + 155, initY + 68 ; 625, 493
        Sleep 150
        Click
        Sleep 150
    }
}

class NoShows extends useReport {
    __New(fileType) {
        super.__New("FO08", "FO08-NoShows", fileType, this.optioning)
        this.label := "FO08-NoShows"
    }

    optioning(initX := 573, initY := 440) {
        Sleep 200
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
    }
}
class FedexSignInGen {
    static scheduleDir := "\\10.0.2.13\FD\25-FEDEX\Schedule"
    static signInTemplate := "\\10.0.2.13\FD\25-FEDEX\Schedule生成处理工具\FedEx Sign In Sheet temp(空模板).xlsx"
    static signInSaveDir := A_Desktop

    static shceduleFlightInfoItems := [
        "tripNum",
        "roomQty",
        "flightIn1",
        "flightIn2",
        "ciDate",
        "eta",
        "stayHours",
        "coDate",
        "etd",
        "flightOut1",
        "flightOut2"
    ]

    static cellColors := [
        "EDE1F6",
        "FFE699",
        "C6E0B4",
        "F8CBAD",
        "9BC2E6",
    ]

    /**
     * @param {String} date 
     * @param {String} frTime 
     * @param {String} toTime 
     */
    static USE(date, frTime, toTime) {
        arrRead := this.readArrivalXml(A_MyDocuments "\" date "-FEDEX-ARRIVAL.xml")
        if (!arrRead) {
            MsgBox("未找到 FedEx Arrival 团单文件，请重新保存", POPUP_TITLE, "4096 T1 icon!")
            return
        }

        arrivalList := arrRead.filter(flight => Integer(flight.eta.replace(":", "")) >= Integer(frTime.replace(":", "")) && Integer(flight.eta.replace(":", "")) <= Integer(toTime.replace(":", "")))
        onDayList := this.readScheduleXls(date)
        nextDayList := this.readScheduleXls(FormatTime(DateAdd(date, 1, "Days"), "yyyyMMdd"))
        scheduleList := onDayList.append(nextDayList)

        this.writeSignInSheet(arrivalList, scheduleList, date, frTime)
    }

    /**
     * Finds the matching schedule
     * @param {String} date date in yyyyMMdd format
     * @returns {String | void} 
     */
    static findSchedule(date) {
        toDate := ""
        targetXls := ""

        loop files (this.scheduleDir . "\*.xls") {
            if (A_LoopFileName.includes("Schedule")) {
                scheduleRange := A_LoopFileName.replaceThese(["Schedule", "(", ")", ".xls"]).trim().split("-")

                fromDate := scheduleRange[1]
                curToDate := scheduleRange[2]

                if (DateDiff(fromDate, date, "Days") <= 0) {
                    if (!toDate) {
                        toDate := curToDate
                        targetXls := A_LoopFileFullPath
                    }
                    else {
                        if (DateDiff(curToDate, toDate, "Days") > 1) {
                            targetXls := A_LoopFileFullPath
                        }
                    }
                }
            }
        }

        return targetXls
    }

    static saveArrivalXml() {
        reportDescriptor := {
            searchStr: "GRPRM",
            name: FormatTime(A_Now, "yyyyMMdd") . " Fedex 团单",
            saveFn: ReportMaster_Action.arrivingFedex
        }

        savedReport := ReportMaster_Action.saveReports([reportDescriptor], "XML")
        saveText := "已保存报表：`n`n" . savedReport . "`n`n是否打开所在文件夹? "
        if (MsgBox(saveText, POPUP_TITLE, "OKCancel 4096") == "OK") {
            saveFilename := A_MyDocuments "\" FormatTime(A_Now, "yyyyMMdd") "-FEDEX-ARRIVAL.XML"
            Run(Format('explorer /select, "{1}"', saveFilename))
        } else {
            utils.cleanReload(WIN_GROUP)
        }
    }

    /**
     * Returns a list of formatted Fdx bookings
     * @param date date in yyyyMMdd format
     * @returns {Array} 
     */
    static readArrivalXml(xmlPath) {
        if (!FileExist(xmlPath)) {
            return false
        }

        onDayMap := Map()
        nextDayMap := Map()

        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)
        fdxBookings := xmlDoc.getElementsByTagName("G_CONFIRMATION_NO")

        loop (fdxBookings.Length) {
            curBooking := fdxBookings[A_Index - 1]
            ; conf
            confNum := curBooking.getElementsByTagName("CONFIRMATION_NO").item(0).text

            ; fullname or trip no.
            fullNameTagContent := curBooking.getElementsByTagName("FULL_NAME").item(0).text
            if (fullNameTagContent.includes("/")) {
                tripNum := fullNameTagContent.split("  ")[2]
                fullName := ""
            }
            else {
                tripNum := ""
                name := fullNameTagContent.split(",")
                fullname := name[2] . " " . name[1]
            }

            ; arrival
            arrival := curBooking.getElementsByTagName("ARRIVAL").item(0).text.split("-")
            ciDate := Format("{}/{}", arrival[1], arrival[2])

            ; departure
            departure := curBooking.getElementsByTagName("DEPARTURE").item(0).text.split("-")
            coDate := Format("{}/{}", departure[1], departure[2])

            ; room num
            roomNum := curBooking.getElementsByTagName("ROOM").item(0).text

            ; ETA
            eta := curBooking.getElementsByTagName("ARRIVAL_TIME").item(0).text.trim()

            ; inbound
            flightIn := curBooking.getElementsByTagName("AIRLINE_AND_NUMBER").item(0).text.trim()

            formatted := {
                confNum: confNum,
                tripNum: tripNum,
                fullName: fullName,
                ciDate: ciDate,
                coDate: coDate,
                roomNum: roomNum,
                eta: eta,
                flightIn: flightIn
            }

            if (Integer(eta.split(":")[1]) >= 10) {
                if (onDayMap.Has(formatted.flightIn)) {
                    onDayMap[formatted.flightIn].Push(formatted)
                }
                else {
                    onDayMap[formatted.flightIn] := [formatted]
                }
            }
            else {
                if (nextDayMap.Has(formatted.flightIn)) {
                    nextDayMap[formatted.flightIn].Push(formatted)
                }
                else {
                    nextDayMap[formatted.flightIn] := [formatted]
                }
            }
        }

        xmlDoc := ""
        sortedOnDay := !onDayMap.Capacity ? [] : onDayMap.values().flat().sort((a, b) => Integer(a.eta.replace(":", "")) - Integer(b.eta.replace(":", "")))
        sortedNextDay := nextDayMap.values().flat().sort((a, b) => Integer(a.eta.replace(":", "")) - Integer(b.eta.replace(":", "")))

        return sortedOnDay.append(sortedNextDay)
    }

    /**
     * Returns a list or scheduled Fdx info
     * @param {String}date date in yyyyMMdd format
     * @returns {Array} 
     */
    static readScheduleXls(date) {
        Xl := ""
        try {
            Xl := ComObject("Ket.Application")
        }
        catch {
            Xl := ComObject("Excel.Application")
        }
        targetSchedule := Xl.Workbooks.Open(this.findSchedule(date))
        try {
            targetSheet := targetSchedule.Worksheets(date.replace(A_Year, ""))
        }
        catch {
            Xl.Quit()
            return []
        }

        lastRow := targetSheet.Cells(targetSheet.Rows.Count, "A").End(-4162).Row

        row := 4
        shceduledInboundFlights := []

        loop (lastRow - 3) {
            flightInfoMap := {}
            for item in this.shceduleFlightInfoItems {
                flightInfoMap.%item% := targetSheet.Cells(row, A_Index).Text
            }

            shceduledInboundFlights.Push(flightInfoMap)
            row++
        }

        Xl.Quit()
        return shceduledInboundFlights
    }

    /**
     * Convert hex to BGR integer
     * @param {String} hex 
     * @returns {Integer} 
     */
    static hexToExcelColor(hex) {
        r := Integer("0x" SubStr(hex, 1, 2))
        g := Integer("0x" SubStr(hex, 3, 2))
        b := Integer("0x" SubStr(hex, 5, 2))

        return r | (g << 8) | (b << 16)
    }

    /**
     * @param {Array} arrivalList 
     * @param {Array} scheduleList 
     * @param {String} date 
     */
    static writeSignInSheet(arrivalList, scheduleList, date, frTime) {
        listToWrite := []

        for (booking in arrivalList) {
            if (booking.fullName) {
                listToWrite.Push(OrderedMap(
                    "fullName", booking.fullName,
                    "roomNum", booking.roomNum,
                    "confNum", booking.confNum,
                    "tripNum", booking.tripNum,
                    "qty", "",
                    "flightIn1", booking.flightIn.substr(1, 2),
                    "flightIn2", booking.flightIn.substr(3),
                    "ciDate", Integer(booking.eta.replace(":", "")) >= 10 ? booking.ciDate : FormatTime(DateAdd(date, 1, "Days"), "MM/dd"),
                    "eta", booking.eta,
                ))
            }
            else {
                bk := booking
                matchedFlight := scheduleList.find(flight => (
                    (flight.tripNum == bk.tripNum) &&
                    (flight.flightIn1 . flight.flightIn2 == bk.flightIn)
                ))
                if (!matchedFlight) {
                    continue
                }

                lineToWrite := OrderedMap(
                    "fullName", booking.fullName,
                    "roomNum", booking.roomNum,
                    "confNum", booking.confNum,
                    "tripNum", booking.tripNum,
                    "qty", "",
                    "flightIn1", matchedFlight.flightIn1,
                    "flightIn2", matchedFlight.flightIn2,
                    "ciDate", matchedFlight.ciDate,
                    "eta", booking.eta,
                    "stayHours", matchedFlight.stayHours,
                    "coDate", matchedFlight.coDate,
                    "etd", matchedFlight.etd,
                    "flightOut1", matchedFlight.flightOut1,
                    "flightOut2", matchedFlight.flightOut2,
                )

                listToWrite.Push(lineToWrite)
            }
        }

        Xl := ""
        try {
            Xl := ComObject("Ket.Application")
        }
        catch {
            Xl := ComObject("Excel.Application")
        }
        signInTemplate := Xl.Workbooks.Open(this.signInTemplate)
        sheet := signInTemplate.Worksheets(1)
        row := 3
        curInbound := ""
        curColorPtr := 0

        for (line in listToWrite) {
            sheet.Cells(row, 1).Value := A_Index

            for (key, val in line) {
                lineInbound := line["flightIn1"] . line["flightIn2"]
                sheet.Cells(row, A_Index + 1).Value := val
                if (key == "flightIn1" || key == "flightIn2") {
                    if (lineInbound != curInbound) {
                        curInbound := lineInbound
                        curColorPtr++
                        if (curColorPtr > this.cellColors.Length) {
                            curColorPtr := 1
                        }
                    }
                    sheet.Cells(row, A_Index + 1).Interior.Color := this.hexToExcelColor(this.cellColors[curColorPtr])
                }
            }

            row++
        }

        saveDate := Integer(frTime.replace(":", "")) <= 10
            ? date
            : FormatTime(DateAdd(date, 1, "Days"), "yyyyMMdd")
        saveFilename := Format("{1}\{2}FedEx Sign In Sheet{3}.xlsx", this.signInSaveDir, saveDate, saveDate == date ? "" : " (早到)")
        signInTemplate.SaveAs(saveFilename)
        Xl.Quit()

        checkSavedSignInSheet := MsgBox("已生成Sign-in Sheet文件。`n是否打开保存所在文件夹查看？", "FedexScheduleMonthly", "OKCancel")
        if (checkSavedSignInSheet == "OK") {
            Run(Format('explorer /select, "{1}"', saveFilename))
        }
    }





    static USE2(date, frTime, toTime) {
        arrRead := this.readArrivalXml(A_MyDocuments "\" date "-FEDEX-ARRIVAL.xml")
        if (!arrRead) {
            MsgBox("未找到 FedEx Arrival 团单文件，请重新保存", POPUP_TITLE, "4096 T1 icon!")
            return
        }

        arrivalList := arrRead.filter(flight => Integer(flight.eta.replace(":", "")) >= Integer(frTime.replace(":", "")) && Integer(flight.eta.replace(":", "")) <= Integer(toTime.replace(":", "")))
        onDayList := this.getTargetDayList(date).values()[1]
        nextDayList := this.getTargetDayList(FormatTime(DateAdd(date, 1, "Days"), "yyyyMMdd")).values()[1]
        scheduleList := onDayList.append(nextDayList)

        this.writeSignInSheet2(arrivalList, scheduleList, date, frTime)
    }

    static createFmtSchdJSON(schdPDF) {
        pdfToText := A_ScriptDir "\vendor\pdftotext.exe"
        tempOutput := A_Temp "\schd_output.txt"

        RunWait('"' pdfToText '" -raw "' schdPDF '" "' tempOutput '"', , "Hide")

        schdTxt := FileRead(tempOutput, "utf-8")
        FileDelete(tempOutput)

        if (!schdTxt.includes("FEDERAL EXPRESS PILOT HOUSING SCHEDULE")) {
            return false
        }

        regex := "^\d+/\d+.*\d+/\d+$"

        res := ""
        loop parse schdTxt, "`n" {
            if (RegExMatch(A_LoopField, regex)) {
                res .= A_LoopField "`n"
            }
        }
        res := RTrim(res, "`n")

        rawSchd := res.split("`n")
        schd := []
        daySchd := Map()
        curDate := ""
        for (line in rawSchd) {
            splittedLine := line.split(" ")

            if (splittedLine.Length == 14) {
                if (daySchd.Capacity > 0) {
                    schd.Push(daySchd)
                }

                ciDate := splittedLine[2]
                fullDate := StrSplit(ciDate, "/")[1] < A_MM
                    ? Format("{1}{2}", A_Year + 1, StrReplace(ciDate, "/", ""))
                    : Format("{1}{2}", A_Year, StrReplace(ciDate, "/", ""))

                curDate := fullDate
                daySchd := Map(curDate, [])
                splittedLine.RemoveAt(2, 2)
            }

            flightInfo := Map(
                "tripNum", splittedLine[1],
                "roomQty", splittedLine[2],
                "inbound", splittedLine[4] . splittedLine[5],
                "ibDate", FormatTime(curDate, "MM/dd"),
                "ETA", splittedLine[6],
                "stayHours", splittedLine[7],
                "obDate", splittedLine[12],
                "ETD", splittedLine[8],
                "outbound", splittedLine[9] . splittedLine[10]
            )

            daySchd[curDate].Push(flightInfo)
        }

        schd.Push(daySchd)

        return schd
    }

    static getTargetDayList(date) {
        curMonthSchd := this.scheduleDir "\" Format("HOTEL-CAN-{1}-{2}.pdf", FormatTime(date, "yyyy;MM").split(";")*)
        nextMonthSchd := this.scheduleDir "\" Format("HOTEL-CAN-{1}-{2}.pdf", FormatTime(DateAdd(date, 30, "Days"), "yyyy;MM").split(";")*)

        curMonthSchdList := this.createFmtSchdJSON(curMonthSchd)
        nextMonthSchdList := FileExist(nextMonthSchd) ? this.createFmtSchdJSON(nextMonthSchd) : []
        targetDayMap := Map()

        if (found := nextMonthSchdList.find(day => day.Has(FormatTime(date, "yyyyMMdd")))) {
            targetDayMap := found
        }
        else {
            targetDayMap := curMonthSchd.find(day => day.Has(FormatTime(date, "yyyyMMdd")))
        }

        return targetDayMap
    }

    static writeSignInSheet2(arrivalList, scheduleList, date, frTime) {
        listToWrite := []

        for (booking in arrivalList) {
            if (booking.fullName) {
                listToWrite.Push(OrderedMap(
                    "fullName", booking.fullName,
                    "roomNum", booking.roomNum,
                    "confNum", booking.confNum,
                    "tripNum", booking.tripNum,
                    "qty", "",
                    "flightIn1", booking.flightIn.substr(1, 2),
                    "flightIn2", booking.flightIn.substr(3),
                    "ciDate", Integer(booking.eta.replace(":", "")) >= 10 ? booking.ciDate : FormatTime(DateAdd(date, 1, "Days"), "MM/dd"),
                    "eta", booking.eta,
                ))
            }
            else {
                bk := booking
                matchedFlight := scheduleList.find(flight => (
                    (flight["tripNum"] == bk.tripNum) &&
                    (flight["inbound"] == bk.flightIn)
                ))
                if (!matchedFlight) {
                    continue
                }

                lineToWrite := OrderedMap(
                    "fullName", booking.fullName,
                    "roomNum", booking.roomNum,
                    "confNum", booking.confNum,
                    "tripNum", booking.tripNum,
                    "qty", "",
                    "flightIn1", matchedFlight["inbound"].substr(1, 2),
                    "flightIn2", matchedFlight["inbound"].substr(3),
                    "ciDate", matchedFlight["ibDate"],
                    "eta", booking.eta,
                    "stayHours", matchedFlight["stayHours"],
                    "coDate", matchedFlight["outbound"],
                    "etd", matchedFlight["ETD"],
                    "flightOut1", matchedFlight["outbound"].substr(1, 2),
                    "flightOut2", matchedFlight["outbound"].substr(3),
                )

                listToWrite.Push(lineToWrite)
            }
        }

        Xl := ""
        try {
            Xl := ComObject("Ket.Application")
        }
        catch {
            Xl := ComObject("Excel.Application")
        }
        signInTemplate := Xl.Workbooks.Open(this.signInTemplate)
        sheet := signInTemplate.Worksheets(1)
        row := 3
        curInbound := ""
        curColorPtr := 0

        for (line in listToWrite) {
            sheet.Cells(row, 1).Value := A_Index

            for (key, val in line) {
                lineInbound := line["flightIn1"] . line["flightIn2"]
                sheet.Cells(row, A_Index + 1).Value := val
                if (key == "flightIn1" || key == "flightIn2") {
                    if (lineInbound != curInbound) {
                        curInbound := lineInbound
                        curColorPtr++
                        if (curColorPtr > this.cellColors.Length) {
                            curColorPtr := 1
                        }
                    }
                    sheet.Cells(row, A_Index + 1).Interior.Color := this.hexToExcelColor(this.cellColors[curColorPtr])
                }
            }

            row++
        }

        saveDate := Integer(frTime.replace(":", "")) <= 10
            ? date
            : FormatTime(DateAdd(date, 1, "Days"), "yyyyMMdd")
        saveFilename := Format("{1}\{2}FedEx Sign In Sheet{3}.xlsx", this.signInSaveDir, saveDate, saveDate == date ? "" : " (早到)")
        signInTemplate.SaveAs(saveFilename)
        Xl.Quit()

        checkSavedSignInSheet := MsgBox("已生成Sign-in Sheet文件。`n是否打开保存所在文件夹查看？", "FedexScheduleMonthly", "OKCancel")
        if (checkSavedSignInSheet == "OK") {
            Run(Format('explorer /select, "{1}"', saveFilename))
        }
    }
}
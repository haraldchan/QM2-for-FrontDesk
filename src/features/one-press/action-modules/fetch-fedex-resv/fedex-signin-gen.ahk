class FedexSignInGen {
    static scheduleDir := A_Desktop "\fdx-test"
    static signInTemplate := "c:\Users\haraldchan\Desktop\fdx-test\FedEx Sign In Sheet temp(空模板).xlsx"
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
     * 
     * @param {String} date 
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

        this.writeSignInSheet(arrivalList, scheduleList, date)
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

            mapToAdd := Integer(eta.split(":")[1]) >= 10 ? onDayMap : nextDayMap
            if (mapToAdd.Has(formatted.flightIn)) {
                mapToAdd[formatted.flightIn].Push(formatted)
            }
            else {
                mapToAdd[formatted.flightIn] := [formatted]
            }
        }

        xmlDoc := ""


        sortedOnDay := onDayMap.values().flat().sort((a, b) => Integer(a.eta.replace(":", "")) - Integer(b.eta.replace(":", "")))
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
     * @param {Array} arrivalList 
     * @param {Array} scheduleList 
     * @param {String} date 
     */
    static writeSignInSheet(arrivalList, scheduleList, date) {
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
                    "ciDate", booking.ciDate,
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

        saveFilename := Format("{1}\{2}FedEx Sign In Sheet.xlsx", this.signInSaveDir, date)
        signInTemplate.SaveAs(saveFilename)
        Xl.Quit()

        checkSavedSignInSheet := MsgBox("已生成Sign-in Sheet文件。`n是否打开保存所在文件夹查看？", "FedexScheduleMonthly", "OKCancel")
        if (checkSavedSignInSheet == "OK") {
            Run(Format('explorer /select, "{1}"', saveFilename))
        }
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

    static saveArrivalXml() {
        reportDescriptor := {
            searchStr: "GRPRMLIST",
            name: "Group Arrival - 当天预抵团单",
            saveFn: ReportMaster_Action.arrivingFedex
        }

        ReportMaster_Action.saveReports([reportDescriptor], "XML")
    }
}
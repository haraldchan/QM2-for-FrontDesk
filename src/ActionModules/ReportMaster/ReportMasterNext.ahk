#Include "./ReportMasterNext_Action.ahk"

ReportMasterNext(App) {
    ON_DAY_GROUP := Format("\\10.0.2.13\fd\9-ON DAY GROUP DETAILS\{2}\{2}{3}\{1}Group ARR&DEP.xlsx", FormatTime(A_Now, "yyyyMMdd"), A_Year, A_MM)

    reportIndex := Map(
        "夜班报表", ReportMasterNext_Action.reportList.onr,
        "预抵团队", [],
        "其他报表", ReportMasterNext_Action.reportList.misc,
        "Loading", []
    )

    reportCategory := signal("夜班报表")
    reportDetails := computed(reportCategory, cat => reportIndex[cat])

    updateListContent(ctrl) {
        reportLV := App.getCtrlByName("$reportList")
        reportLV.setColumndDetails(ctrl.Text = "预抵团队" ? lvSettings.columnDetailsGroup : lvSettings.columnDetails)
        
        if (ctrl.Text = "预抵团队" && reportIndex["预抵团队"].Length = 0) {
            reportCategory.set("Loading") ; make it blank on first load
            reportIndex["预抵团队"] := getBlockInfo(ON_DAY_GROUP)

            reportCategory.set("预抵团队")            
        }

        reportCategory.set(ctrl.Text)
    }

    effect(reportCategory, cur => handleCategorySelect(cur))
    handleCategorySelect(current) {
        btns := [App.getCtrlByName("onr"), App.getCtrlByName("odg"), App.getCtrlByName("misc")]
        for btn in btns {
            fontStyle := btn.Text = current ? "Bold" : "Norm"
            btn.SetFont(btn.Text = current ? "Bold" : "Norm")
        }

        isShowingMisc := current = "其他报表"
        App.getCtrlByName("$reportList").ctrl.Opt(isShowingMisc ? "-Checked -Multi" : "+Checked +Multi")
        App.getCtrlByName("$reportCheckAll").ctrl.Visible := !isShowingMisc
    }

    getBlockInfo(fileName) {
        blockInfo := []

        Xl := ComObject("Excel.Application")
        OnDayGroupDetails := Xl.Workbooks.Open(fileName).Worksheets("Sheet1")
        loop {
            blockCodeReceived := OnDayGroupDetails.Cells(A_Index + 3, 1).Text
            blockNameReceived := OnDayGroupDetails.Cells(A_Index + 3, 2).Text
            if (blockCodeReceived = "" || blockCodeReceived = "Group StayOver") {
                break
            }

            blockInfo.Push(
                Map(
                    "blockName", blockNameReceived,
                    "blockCode", blockCodeReceived
                )
            )
        }
        Xl.Workbooks.Close()
        Xl.Quit()

        return blockInfo
    }

    handleHisForNextMonthUncheck() {
        if (A_MDay = "01") {
            return
        }

        LV := App.getCtrlByName("$reportList").ctrl
        day31Months := ["01", "03", "05", "07", "08", "10", "12"]

        if (A_MM = "02" && A_MDay > 24) {
            LV.Modify(5, "-Check")
        } else if (day31Months.Has(A_MM) && A_MDay < 28) {
            LV.Modify(5, "-Check")
        } else {
            if (A_MDay < 27) {
                LV.Modify(5, "-Check")
            }
        }
    }

    lvSettings := {
        columnDetails: {
            keys: ["searchStr", "name"],
            titles: ["搜索字段", "报表名称"],
            widths: [120, 200]
        },
        columnDetailsGroup: {
            keys: ["blockCode", "blockName"],
            titles: ["block code", "团队名称"],
            widths: [120, 200]
        },
        options: {
            lvOptions: "$reportList Checked Grid NoSortHdr -ReadOnly -Multi x30 y+15 w350 r15",
            itemOptions: "Check"
        }
    }

	openMyDocs(reportName) {
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
		saveText := "已保存报表：`n`n" . reportName . "`n`n是否打开所在文件夹? "
		openFolder := MsgBox(saveText, popupTitle, "OKCancel 4096")
		if (openFolder = "OK") {
			Run A_MyDocuments
		} else {
			utils.cleanReload(winGroup)
		}
	}

    saveReports() {
        LV := App.getCtrlByName("$reportList").ctrl
        fileType := App.getCtrlByName("fileType").Text
        savedReports := ""

        ; handle misc report saving
        if (reportCategory.value = "其他报表") {
            savedReports .= reportDetails.value[LV.GetNext()].name
            ReportMasterNext_Action.reportFiling(reportDetails.value[LV.GetNext()], fileType)
        }

        ; handle over-night reports
        if (reportCategory.value = "夜班报表") {
            selectedReport := []
            for row in LV.getCheckedRowNumbers() {
                if (LV.getCheckedRowNumbers()[1] = "0") {
                    MsgBox("未选中报表", popupTitle, "T2")
                    App.Show()
                    return
                }
                selectedReport.Push(reportDetails.value[row])
            }

            for report in selectedReport {
                ReportMasterNext_Action.reportFiling(report, fileType)
                savedReports .= report.name . "`n"
            }
        }
        
        ; handle on-day group arriving
        if (reportCategory.value = "预抵团队") {
            selectedBlocks := []
            for block in LV.getCheckedRowNumbers() {
                if (LV.getCheckedRowNumbers()[1] = "0") {
                    MsgBox("未选中团队", popupTitle, "T2")
                    App.Show()
                    return
                }
                selectedBlocks.Push(reportDetails.value[block])
            }
            
            for block in selectedBlocks {
                reportObj := ReportMasterNext_Action.reportList.groupApp
                reportObj.blockName := block["blockName"]
                reportObj.blockCode := block["blockCode"]
                ReportMasterNext_Action.reportFiling(reportObj, fileType)
                savedReports .= block["blockName"] . "`n"
            }
        }

        openMyDocs(savedReports)
    }

    return (
        ; report selector btn group
        App.AddButton("vonr x30 y+15 w115 h35", "夜班报表").OnEvent("Click", (ctrl, _) => updateListContent(ctrl)),
        App.AddButton("vodg x+0 w115 h35", "预抵团队").OnEvent("Click", (ctrl, _) => updateListContent(ctrl)),
        App.AddButton("vmisc x+0 w115 h35", "其他报表").OnEvent("Click", (ctrl, _) => updateListContent(ctrl)),
        ; report listview
        App.AddReactiveListView(lvSettings.options, lvSettings.columnDetails, reportDetails),
        ; footer
        App.AddReactiveCheckBox("$reportCheckAll Checked y+10 h25", "全选"),
        App.AddDropDownList("vfileType w50 x+160 Choose1", ["PDF", "XML", "TXT", "XLS"]),
        App.AddButton("vreportSave h26 w80 x+10 Default", "保存报表").OnEvent("Click", (*) => saveReports()),
        ; bind check status
        shareCheckStatus(
            App.getCtrlByName("$reportCheckAll").ctrl,
            App.getCtrlByName("$reportList").ctrl
        ),
        handleHisForNextMonthUncheck()
    )
}
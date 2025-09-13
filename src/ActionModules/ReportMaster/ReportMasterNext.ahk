#Include "./ReportMasterNext_Action.ahk"

ReportMasterNext(App) {
    XL_FILE_PATH := ""
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
            reportIndex["预抵团队"] := getBlockInfo()
        }

        reportCategory.set(ctrl.Text)
    }

    effect(reportCategory, handleCategorySelect)
    handleCategorySelect(current) {
        btns := [App.getCtrlByName("onr"), App.getCtrlByName("odg"), App.getCtrlByName("misc")]
        for btn in btns {
            fontStyle := btn.Text = current ? "Bold" : "Norm"
            btn.SetFont(btn.Text = current ? "Bold" : "Norm")
        }

        isShowingMisc := current == "其他报表"
        App.getCtrlByName("$reportList").ctrl.Opt(isShowingMisc ? "-Checked -Multi" : "+Checked +Multi")
        App.getCtrlByName("$reportCheckAll").ctrl.Visible := !isShowingMisc
    }

    getBlockInfo() {
        monthFolder := Format("\\10.0.2.13\fd\9-ON DAY GROUP DETAILS\{1}\{1}{2}", A_Year, A_MM)

        loop files monthFolder . "\*" {
            if (InStr(A_LoopFileName, FormatTime(A_Now, "yyyyMMdd"))) {
                XL_FILE_PATH := A_LoopFileFullPath
                break
            }
        }

        if (XL_FILE_PATH == "") {
            MsgBox("未找到 OnDayGroup Excel 文件，请手动添加", POPUP_TITLE, "4096 T1")
            App.Opt("+OwnDialogs")
            XL_FILE_PATH := FileSelect(3, , "请选择 OnDayGroup Excel 文件")
            if (XL_FILE_PATH == "") {
                return
            } 
        }
        
        blockInfo := []
        Xl := ComObject("Excel.Application")
        OnDayGroupDetails := Xl.Workbooks.Open(XL_FILE_PATH).Worksheets("Sheet1")
        loop {
            blockCodeReceived := OnDayGroupDetails.Cells(A_Index + 3, 1).Text
            blockNameReceived := OnDayGroupDetails.Cells(A_Index + 3, 2).Text
            commentReceived :=  OnDayGroupDetails.Cells(A_Index + 3, 4).Text
            if (blockCodeReceived = "" || blockCodeReceived = "Group StayOver") {
                break
            }

            blockInfo.Push(
                Map(
                    "blockName", blockNameReceived,
                    "blockCode", blockCodeReceived,
                    "comment", commentReceived
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
            keys: ["blockCode", "blockName", "comment"],
            titles: ["block code", "团队名称", "Comment"],
            widths: [120, 130, 200]
        },
        options: {
            lvOptions: "$reportList Checked Grid NoSortHdr -ReadOnly -Multi LV0x4000 x30 y+15 w350 r20",
            itemOptions: "Check"
        }
    }

	openMyDocs(reportName) {
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
		saveText := "已保存报表：`n`n" . reportName . "`n`n是否打开所在文件夹? "
		openFolder := MsgBox(saveText, POPUP_TITLE, "OKCancel 4096")
		if (openFolder = "OK") {
			Run A_MyDocuments
		} else {
			utils.cleanReload(WIN_GROUP)
		}
	}

    saveReports() {
        LV := App.getCtrlByName("$reportList").ctrl
        fileType := App.getCtrlByName("fileType").Text
        savedReports := ""

        ; handle misc report saving
        if (reportCategory.value = "其他报表") {
            savedReports .= reportDetails.value[LV.GetNext()].name
            ReportMasterNext_Action.start()
            ReportMasterNext_Action.reportFiling(reportDetails.value[LV.GetNext()], fileType)
            ReportMasterNext_Action.end()
        }

        ; handle over-night reports
        if (reportCategory.value = "夜班报表") {
            selectedReport := []
            for row in LV.getCheckedRowNumbers() {
                if (LV.getCheckedRowNumbers()[1] = "0") {
                    MsgBox("未选中报表", POPUP_TITLE, "T2")
                    App.Show()
                    return
                }
                selectedReport.Push(reportDetails.value[row])
            }

            ReportMasterNext_Action.start()
            for report in selectedReport {
                if (!ReportMasterNext_Action.isRunning && A_Index > 1) {
                    return
                }
                ReportMasterNext_Action.reportFiling(report, fileType)
                savedReports .= report.name . "`n"
            }
            ReportMasterNext_Action.end()
        }
        
        ; handle on-day group arriving
        if (reportCategory.value = "预抵团队") {
            selectedBlocks := []
            for block in LV.getCheckedRowNumbers() {
                if (LV.getCheckedRowNumbers()[1] = "0") {
                    MsgBox("未选中团队", POPUP_TITLE, "T2")
                    App.Show()
                    return
                }
                selectedBlocks.Push(reportDetails.value[block])
            }
            
            ReportMasterNext_Action.start()
            for block in selectedBlocks {
                if (!ReportMasterNext_Action.isRunning && A_Index > 1) {
                    return
                }
                reportObj := ReportMasterNext_Action.reportList.groupArr
                reportObj.blockName := block["blockName"]
                reportObj.blockCode := block["blockCode"]
                ReportMasterNext_Action.reportFiling(reportObj, fileType)
                savedReports .= block["blockName"] . "`n"
            }
            ReportMasterNext_Action.end()
        }

        openMyDocs(savedReports)
    }

    return (
        ; report selector btn group
        App.AddButton("vonr x30 y+15 w115 h35", "夜班报表").OnEvent("Click", (ctrl, _) => updateListContent(ctrl)),
        App.ARButton("vodg x+0 w115 h35", "预抵团队").OnEvent(
            "Click", (ctrl, _) => updateListContent(ctrl),
            "DoubleClick", (*) => Run(XL_FILE_PATH)
        ),
        App.AddButton("vmisc x+0 w115 h35", "其他报表").OnEvent("Click", (ctrl, _) => updateListContent(ctrl)),
        ; report listview
        App.ARListView(lvSettings.options, lvSettings.columnDetails, reportDetails),
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

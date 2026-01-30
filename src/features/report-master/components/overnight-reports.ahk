/**
 * @param {Svaner} App 
 */
OverNightReports(App) {
    handleHisForNextMonthUncheck() {
        if (A_MDay == "01") {
            return
        }

        day31Months := ["01", "03", "05", "07", "08", "10", "12"]

        if (
            A_MM == "02" && A_MDay > 24
            || day31Months.Has(A_MM) && A_MDay < 28
            || A_MDay < 27
        ) {
            App["onr-list"].Modify(5, "-Check")
        }
    }

    saveReports(*) {
        selectedReport := []
        selectedRows := App["onr-list"].getCheckedRowNumbers()
        if (!selectedRows.Length) {
            MsgBox("未选中报表", POPUP_TITLE, "T2")
            App.Show()
            return
        }

        for row in selectedRows {
            selectedReport.Push(ReportMaster_Action.reportList.onr[row])
        }

        ReportMaster_Action.start()
        for report in selectedReport {
            if (!ReportMaster_Action.isRunning && A_Index > 1) {
                return
            }
            ReportMaster_Action.reportFiling(report, App["onr-file-type"].Text)
            savedReports .= report.name . "`n"
        }
        ReportMaster_Action.end()

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        saveText := "已保存报表：`n`n" . savedReports . "`n`n是否打开所在文件夹? "
        if (MsgBox(saveText, POPUP_TITLE, "OKCancel 4096") == "OK") {
            Run A_MyDocuments
        } else {
            utils.cleanReload(WIN_GROUP)
        }
    }

    onMount() {
        shareCheckStatus(App["onr-check-all"], App["onr-list"])
        handleHisForNextMonthUncheck()
    }

    return (
        ; report listview
        App.AddListView(
            ; options
            {
                lvOptions: "vonr-list Checked Grid NoSortHdr -ReadOnly -Multi @lv:label-tip x30 y+15 w350 r20",
                itemOptions: "Check"
            },
            ; col-details
            {
                keys: ["searchStr", "name"],
                titles: ["搜索字段", "报表名称"],
                widths: [120, 200]
            },
            ; report infos
            signal(ReportMaster_Action.reportList.onr)
        ),
        ; footer
        App.AddCheckBox("vonr-check-all Checked y+10 h25", "全选"),
        App.AddDDL("vonr-file-type w50 x+160 Choose1", ["PDF", "XML", "TXT", "XLS"]),
        App.AddButton("vonr-report-save h25 w80 x+10 Default", "保存报表").onClick(saveReports),
        onMount()
    )
}
/**
 * @param {Svaner} App 
 * @param {signal} curActiveTab
 */
OnDayGroupReports(App, curActiveTab) {
    dirFormat := "\\10.0.2.13\fd\9-ON DAY GROUP DETAILS\{1}\{1}{2}"

    onDayBlockInfo := signal([Map(
        "blockName", "",
        "blockCode", "",
        "comment", ""
    )])

    effect(curActiveTab, cur => initLoad(cur))
    initLoad(cur) {
        if (cur != "团单信息" || !(onDayBlockInfo.value.Length == 1 && !onDayBlockInfo.value[1]["blockName"])) {
            return
        }

        ; onDayBlockInfo.set(getBlockInfo())
    }

    getBlockInfo(yyyy := A_Year, MM := A_MM, dd := A_DD) {
        monthFolder := Format(dirFormat, yyyy, MM)

        loop files monthFolder . "\*" {
            if (InStr(A_LoopFileName, yyyy . MM . dd)) {
                XL_FILE_PATH := A_LoopFileFullPath
                break
            }
        }

        if (!XL_FILE_PATH) {
            MsgBox("未找到 OnDayGroup Excel 文件，请手动添加", POPUP_TITLE, "4096 T1")
            App.Opt("+OwnDialogs")
            XL_FILE_PATH := FileSelect(3, , "请选择 OnDayGroup Excel 文件", "Excel 文件 (*.xls; *.xlsx; *.xlsm)")
            if (!XL_FILE_PATH) {
                return
            }
        }

        blockInfo := []
        Xl := ComObject("Excel.Application")
        OnDayGroupDetails := Xl.Workbooks.Open(XL_FILE_PATH).Worksheets("Sheet1")
        loop {
            blockCodeReceived := OnDayGroupDetails.Cells(A_Index + 3, 1).Text
            blockNameReceived := OnDayGroupDetails.Cells(A_Index + 3, 2).Text
            commentReceived := OnDayGroupDetails.Cells(A_Index + 3, 4).Text
            if (blockCodeReceived = "" || blockCodeReceived = "Group StayOver") {
                break
            }

            blockInfo.Push(Map(
                "blockName", blockNameReceived,
                "blockCode", blockCodeReceived,
                "comment", commentReceived
            ))
        }
        Xl.Workbooks.Close()
        Xl.Quit()

        return blockInfo
    }

    handleBlockInfoUpdate(ctrl, _) {
        ; onDayBlockInfo.set(getBlockInfo(ctrl.Value.toFormat("yyyy,MM,dd").split(",")*))
    }

    handleOpenOdgDir(*) {
        selectedDate := App["odg-date"].Value.toFormat("yyyy,MM,dd").split(",")
        odgFilePattern := Format(dirFormat . "\{1}{2}{3}GroupARR&DEP.xlsx", selectedDate*)

        Run Format('explorer /select, "{1}"', odgFilePattern)
    }

    openMyDocs(reportName) {
        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        saveText := "已保存报表：`n`n" . reportName . "`n`n是否打开所在文件夹? "
        if (MsgBox(saveText, POPUP_TITLE, "OKCancel 4096") == "OK") {
            Run A_MyDocuments
        } else {
            utils.cleanReload(WIN_GROUP)
        }
    }

    saveReports(*) {
        selectedBlocks := []
        selectedRows := App["odg-list"].getCheckedRowNumbers()
        if (!App["odg-list"].getCheckedRowNumbers().Length) {
            MsgBox("未选中团队", POPUP_TITLE, "T2")
            App.Show()
            return
        }

        for block in selectedRows {
            selectedBlocks.Push(onDayBlockInfo.value[block])
        }

        ReportMaster_Action.start()
        for block in selectedBlocks {
            if (!ReportMaster_Action.isRunning && A_Index > 1) {
                return
            }
            reportObj := ReportMaster_Action.reportList.groupArr
            reportObj.blockName := block["blockName"]
            reportObj.blockCode := block["blockCode"]
            ReportMaster_Action.reportFiling(reportObj, App["odg-file-type"])
            savedReports .= block["blockName"] . "`n"
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
        shareCheckStatus(App["odg-check-all"], App["odg-list"])
    }

    return (
        App.AddDateTime("vodg-date x30 y+15 w260 h25", "yyyy/MM/dd").onChange(handleBlockInfoUpdate),
        App.AddButton("x+10 h25 w80", "打开位置").onClick(handleOpenOdgDir),
        ; report listview
        App.AddListView(
            ; options
            {
                lvOptions: "vodg-list Checked Grid NoSortHdr -ReadOnly -Multi @lv:label-tip x30 y+15 w350 r20",
                itemOptions: "Check"
            },
            ; col-details
            {
                keys: ["blockCode", "blockName", "comment"],
                titles: ["block code", "团队名称", "Comment"],
                widths: [120, 130, 200]
            },
            ; group infos
            onDayBlockInfo
        ),
        ; footer
        App.AddCheckBox("vodg-check-all Checked y+10 h25", "全选"),
        App.AddDDL("vodg-file-type x+160 w50 @ddl:h36 Choose1", ["PDF", "XML", "TXT", "XLS"]),
        App.AddButton("vodg-report-save h25 w80 x+10 Default", "保存报表").onClick(saveReports),
        onMount()
    )
}
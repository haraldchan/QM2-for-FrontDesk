#Include "./PsbBatchCheckout_Action.ahk"
#Include "./DepartedRooms.ahk"
#Include "./MatchFailedRooms.ahk"

PsbBatchCheckout(props) {
    App := props.App
    styles := props.styles

    pbc := Component(App, A_ThisFunc)

    departedRooms := signal([{ roomNum: "", name: "", id: "" }])

    handleGetDepartedRooms(forceReportDownload := false) {
        if (forceReportDownload && MsgBox("是否下载 FO03 - Departures？", popupTitle, "OKCancel") == "Cancel") {
            return
        }

        filename := FormatTime(A_Now, "yyyyMMdd") . " - departure"
        if (forceReportDownload || !FileExist(A_MyDocuments . "\" . filename . ".XML")) {
            ReportMasterNext_Action.start()
            ReportMasterNext_Action.reportFiling({
                searchStr: "FO03",
                name: filename,
                saveFn: PsbBatchCheckout_Action.saveDeps,
                args: [App.getCtrlByName("dpFrom").Text, App.getCtrlByName("dpTo").Text]
            }, "XML")
            ReportMasterNext_Action.end()
        }

        useListPlaceholder(departedRooms, ["roomNum", "name", "idNum"], "Loading...")
        pbc.ctrls.filter(ctrl => ctrl.type == "Button").map(ctrl => ctrl.Enabled := false)
        
        res := PsbBatchCheckout_Action.getDepartedRooms(A_MyDocuments . "\" . filename . ".XML")
        ; res -> [departedGuests, matchFailedGuests]
        if (res[2].Length) {
            MatchFailedRooms(departedRooms, res[2])
        }

        if (!res[1].Length) {
            useListPlaceholder(departedRooms, ["roomNum", "name", "idNum"], "No data")
        } else {
            departedRooms.set(res[1])
        }
        
        pbc.ctrls.filter(ctrl => ctrl.type == "Button").map(ctrl => ctrl.Enabled := true)
        Sleep 500
        App.Show()
    }

    handleFilterByActLog(ctrl, forceReportDownload := false) {
        ctrl.Text := ctrl.Text == "Log 筛选" ? "查看全部" : "Log 筛选"

        if (ctrl.Text == "查看全部") {
            userCode := InputBox("请输入用户Opera Code。多个用户请用空格分割")
            if (userCode.Result == "Cancel") {
                return
            }

            if (forceReportDownload && MsgBox("是否下载 User Activity Log？", popupTitle, "OKCancel") == "Cancel") {
                ctrl.Text := "Log 筛选"
                return
            }
                        
            reportObj := {
                searchStr: "user_activity_log", 
                name: FormatTime(A_Now, "yyyyMMdd") . "-" . userCode.Value.trim(), 
                saveFn: PsbBatchCheckout_Action.saveActLog,
                args: [userCode.Value.trim()]
            }
            
            if (forceReportDownload || !FileExist(A_MyDocuments . "\" . reportObj.name . ".XML")) {
                ReportMasterNext_Action.start()
                ReportMasterNext_Action.reportFiling(reportObj, "XML")
                ReportMasterNext_Action.end()
            }
            pbc.ctrls.filter(ctrl => ctrl.type == "Button").map(ctrl => ctrl.Enabled := false)
            
            roomNums := PsbBatchCheckout_Action.getDepartedRoomFromActLog(A_MyDocuments . "\" . reportObj.name . ".XML")
            filteredDepartedRooms := departedRooms.value.filter(depRoom => roomNums.find(room => room == depRoom["roomNum"]))

            departedRooms.set(filteredDepartedRooms)
        } else  {
            handleGetDepartedRooms()
        }
        
        pbc.ctrls.filter(ctrl => ctrl.type == "Button").map(ctrl => ctrl.Enabled := true)
        Sleep 500
        App.Show()
    }

    handleBatchCheckout(*) {
        LV := App.getCtrlByName("roomsDp")
        if (LV.GetNext() == 0) {
            return
        }

        checkedRooms := []
        for row in LV.getCheckedRowNumbers() {
            if (LV.getCheckedRowNumbers()[1] == "0") {
                MsgBox("未选中房号", popupTitle, "T2")
                App.Show()
                return
            }

            checkedRooms.Push(departedRooms.value[row])
        }

        PsbBatchCheckout_Action.USE(checkedRooms)
    }

    pbc.render := (this) => this.Add(
        App.AddGroupBox("Section r11 " . styles.xPos . styles.yPos . styles.wide, "旅业二期（网页版）批量退房"),
        ; Departed guest list by room
        DepartedRoomsList(App, departedRooms),
        ; btns
        App.ARButton("xs10 w80 h30", "获取房号")
           .OnEvent(
                "Click", (*) => handleGetDepartedRooms(),
                "ContextMenu", (*) => handleGetDepartedRooms(true)
        ),
        App.ARButton("x+10 w80 h30", "Log 筛选")
           .OnEvent(
                "Click", (ctrl, _) => handleFilterByActLog(ctrl),
                "ContextMenu", (ctrl, *) => handleFilterByActLog(ctrl, true)
        ),
        App.ARButton("vPsbBatchCheckoutAction x+10 w80 h30", "开始退房").OnEvent("Click", handleBatchCheckout)
    )

    return pbc
}
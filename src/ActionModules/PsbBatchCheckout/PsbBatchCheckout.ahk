#Include "./PsbBatchCheckout_Action.ahk"
#Include "./DepartedRooms.ahk"

PsbBatchCheckout(props) {
    App := props.App
    styles := props.styles

    pbc := Component(App, A_ThisFunc)

    departedRooms := signal([{ roomNum: "", name: "" }])

    handleGetDepartedRooms(forceReportDownload := false) {
        if (forceReportDownload) {
            if (MsgBox("是否下载 FO03 - Departures？", popupTitle, "OKCancel") == "Cancel") {
                return
            } 
        }

        filename := FormatTime(A_Now, "yyyyMMdd") . " - departure"
        if (forceReportDownload || !FileExist(A_MyDocuments . "\" . filename . ".XML")) {
            ReportMasterNext_Action.start()
            ReportMasterNext_Action.reportFiling({
                searchStr: "FO03", 
                name: filename, 
                saveFn: PsbBatchCheckout_Action.saveDeps,
                args: [App.getCtrlByName("dpFrom").Value, App.getCtrlByName("dpTo").Value] 
            }, "XML")
            ReportMasterNext_Action.end()
        }

        useListPlaceholder(departedRooms, ["roomNum", "name"], "Loading...")

        res := PsbBatchCheckout_Action.getDepartedRooms(A_MyDocuments . "\" . filename . ".XML")
        if (res.Length == 0) {
            useListPlaceholder(departedRooms, ["roomNum", "name"], "No data")
        } else {
            departedRooms.set(res)
        }

        App.Show()
    }

    handleBatchCheckout(*) {
        LV := App.getCtrlByName("roomsDp")
        if (LV.GetNext() = 0) {
            return
        }

        checkedRooms := []
        for row in LV.getCheckedRowNumbers() {
            if (LV.getCheckedRowNumbers()[1] = "0") {
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
        App.ARButton("xs10 yp+240 w120 h30", "获取房号")
           .OnEvent(Map(
                "Click", (*) => handleGetDepartedRooms(),
                "ContextMenu", (*) => handleGetDepartedRooms(true)
            )),
        App.ARButton("vPsbBatchCheckoutAction x+10 w120 h30", "开始退房")
           .OnEvent("Click", handleBatchCheckout)
    )

    return pbc
}
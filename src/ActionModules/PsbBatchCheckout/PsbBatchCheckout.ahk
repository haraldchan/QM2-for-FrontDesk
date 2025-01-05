#Include "./PsbBatchCheckout_Action.ahk"
#Include "./DepartedRooms.ahk"

PsbBatchCheckout(props) {
    App := props.App
    styles := props.styles

    pbc := Component(App, A_ThisFunc)

    departedRooms := signal([{ roomNum: "", name: "" }])

    handleGetDepartedRooms(*) {
        filename := FormatTime(A_Now, "yyyyMMdd") . " - departure"
        if (!FileExist(A_MyDocuments . "\" . filename . ".XML")) {
            ReportMasterNext_Action.start()
            ReportMasterNext_Action.reportFiling({ searchStr: "FO03", name: filename, saveFn: PsbBatchCheckout_Action.saveDeps }, "XML")
            ReportMasterNext_Action.end()
        }

        useListPlaceholder(departedRooms, ["roomNum"], "Loading...")

        departedRooms.set(PsbBatchCheckout_Action.getDepartedRooms(A_MyDocuments . "\" . filename . ".XML"))
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
           .OnEvent("Click", handleGetDepartedRooms),
        App.ARButton("vPsbBatchCheckoutAction x+10 w120 h30", "开始退房")
           .OnEvent("Click", handleBatchCheckout)
    )

    return pbc
}
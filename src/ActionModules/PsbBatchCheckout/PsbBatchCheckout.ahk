#Include "./PsbBatchCheckout_Action.ahk"
#Include "./DepartedRooms.ahk"

PsbBatchCheckout(props) {
    App := props.App
    styles := props.styles

    pbc := Component(App, A_ThisFunc)

    readme := "
    (
        使用步骤
        1. 开始退房前，务必先到蓝豆查看“续住”工单，剔除列表中的续住房号
        
        2. 开始退房前，请先登录旅业二期，并选择“入住管理”
    )"

    departedRooms := signal([])

    handleGetDepartedRooms(*) {
        filename := FormatTime(A_Now, "yyyyMMdd") . " - departure"
        if (!FileExist(A_MyDocuments . "\" . filename . ".XML")) {
            ReportMasterNext_Action.start()
            ReportMasterNext_Action.reportFiling({ searchStr: "FO03", name: filename, saveFn: PsbBatchCheckout_Action.saveDeps }, "XML")
            ReportMasterNext_Action.end()
        }

        useListPlaceholder(departedRooms, ["roomNum"], "Loading...")

        departedRooms.set(PsbBatchCheckout_Action.getDepartedRooms(A_MyDocuments . "\" . filename . ".XML"))
    }

    pbc.render := (this) => this.Add(
        App.AddGroupBox("Section r4 " . styles.xPos . styles.yPos . styles.wide, "旅业二期（网页版）批量退房"),
        App.AddText("xs10 yp+30 0x200", readme),
        DepartedRoomsList(App, departedRooms),
        App.AddButton("w120 h30", "获取房号").OnEvent("Click", handleGetDepartedRooms),
        App.AddButton("vPsbBatchCheckoutAction x+10 w120 h30", "开始退房")
    )

    return pbc
}
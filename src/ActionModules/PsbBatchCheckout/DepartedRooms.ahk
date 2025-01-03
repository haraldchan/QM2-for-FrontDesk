DepartedRoomsList(App, departedRooms) {
    drl := Component(App, A_ThisFunc)

    columnDetails := {
        keys: ["roomNum", "name"],
        titles: ["房号", "姓名"],
        widths: [80, 220]
    }

    options := {
        lvOptions: "vroomsDp Checked Grid NoSortHdr -ReadOnly xs10 yp+25 w330 r7 ",
        itemOptions: "Check"
    }

    drl.render := (this) => this.Add(
        App.ARCheckBox("vcheckAllDp Checked xs10 h20 xs10 yp-210", " 全选").SetFont("bold s10"),
        App.ARListView(options, columnDetails, departedRooms),
        shareCheckStatus(
            App.getCtrlByName("checkAllDp"),
            App.getCtrlByName("roomsDp")
        )
    )

    return drl
}
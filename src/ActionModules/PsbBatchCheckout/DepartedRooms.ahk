DepartedRoomsList(App, departedRooms) {
    drl := Component(App, A_ThisFunc)

    columnDetails := {
        keys: ["roomNum", "name", "idNum"],
        titles: ["房号", "姓名", "证件号码"],
        widths: [80, 200, 200]
    }

    options := {
        lvOptions: "vroomsDp Checked Grid NoSortHdr -ReadOnly xs10 yp+25 w330 r9 ",
        itemOptions: "Check"
    }

    today := FormatTime(A_Now, "yyyyMMdd")

    drl.render := (this) => this.Add(
        App.ARCheckBox("vcheckAllDp Checked xs10 h20 xs10 yp-270", " 全选").SetFont("bold s10"),
        
        ; time range
        App.AddText("x+55 h20 0x200", "FO03 时间区间："),
        App.AddDateTime("1 vdpFrom x+10 h20 w55 Choose" . today . "0000", "HH:mm"),
        App.AddText("x+1 h20 0x200", "-"),
        App.AddDateTime("1 vdpTo x+1 h20 w55 Choose" . today . "2359", "HH:mm"),
        
        ; departed guest list
        App.ARListView(options, columnDetails, departedRooms),
        shareCheckStatus(
            App.getCtrlByName("checkAllDp"),
            App.getCtrlByName("roomsDp")
        )
    )

    return drl
}
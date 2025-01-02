DepartedRoomsList(App, departedRooms) {
    columnDetails := {
        keys: ["roomNum"],
        titles: ["房号"],
        widths: [150]
    }

    options := {
        lvOptions: "vroomsDp Checked Grid NoSortHdr -ReadOnly w245 r14 y+5",
        itemOptions: "Check"
    }

    return (
        App.AddCheckBox("vcheckAllDp Checked h20 x310 y155", " 全选").SetFont("bold s10"),
        App.AddReactiveListView(options, columnDetails, departedRooms),
        ; link check all status
        shareCheckStatus(
            App.getCtrlByName("checkAllDp"),
            App.getCtrlByName("roomsDp"),
        )
    )
}
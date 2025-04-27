MatchFailedRooms(matchFailedSignal, failedList) {
    App := Gui("", "匹配缺失")
    App.SetFont(, "微软雅黑")
    App.OnEvent("Close", (*) => App.Destroy())

    submitUpdatedIdNums() {
        idNumInputs := App.GetCtrlsByType("Edit")
        completedList := failedList.map((guest, index) => guest["idNum"] := idNumInputs.find(edit => edit.name == "idNum" . index).Value)

        matchFailedSignal.set(completedList)
        App.Destroy()
    }

    return (
        App.AddGroupBox("x10 w500 r10 +VScroll", "信息详情"),
        App.AddText("xs10 yp+20 w200", "以下 Departure 客人信息匹配失败, 请补全信息。"),
        failedList.map((guest, index) => (
            App.AddText("xs10 yp+20 w80", "房号: " . guest["roomNum"]),
            App.AddText("x+20 w80", "房号: " . guest["name"]),
            App.AddText("x+20 w50", "证件号: "),
            App.AddEdit("vidNum" . index, " x+1 w150", ""),
        )),
        App.AddButton("w100 h30 y+10", "完 成"),
        App.Show()
    )
}
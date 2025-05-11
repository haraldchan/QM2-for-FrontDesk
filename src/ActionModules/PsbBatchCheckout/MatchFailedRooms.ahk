MatchFailedRooms(departedRooms, failedList, prevFailedList) {
    App := Gui("+AlwaysOnTop", "匹配缺失")
    App.SetFont(, "微软雅黑")
    App.OnEvent("Close", (*) => App.Destroy())

    submitUpdatedIdNums(*) {
        idNumInputs := App.GetCtrlByTypeAll("Edit")
        
        for guest in failedList {
            g := guest
            guest["idNum"] := idNumInputs.find(edit => edit.name == g["name"].replace(" ")).Value
        }

        prevFailedList.set(failedList)

        appendedList := departedRooms.value.append(failedList.filter(g => g["idNum"] != ""))
        departedRooms.set(appendedList)
        App.Destroy()
    }

    return (
        App.AddGroupBox("Section x10 w500 " . "h" . (60 + failedList.Length * 40), "信息详情"),
        App.AddText("xs10 yp+20 w480", "以下 Departure 客人信息匹配失败, 请补全信息。"),
        failedList.map((guest, index) => (
            App.AddText("xs10 w70 yp+40", "房号: " . guest["roomNum"]),
            App.AddText("x+20 w150", "姓名: " . guest["name"]),
            App.AddText("x+20 w50", "证件号: "),
            App.AddEdit(("v" . guest["name"].replace(" ")) . " x+1 w150", 
                prevFailedList.value.Length == 0
                    ? ""
                    : prevFailedList.value.find(g => g["name"].replace(" ") == guest["name"].replace(" "))["idNum"]
            )
        )),
        App.AddButton("x20 w100 h30", "完 成").OnEvent("Click", submitUpdatedIdNums),
        App.Show()
    )
}
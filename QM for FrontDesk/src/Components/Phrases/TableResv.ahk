TableReserve(App){
	restaurantList := ["宏图府", "玉堂春暖", "风味餐厅", "流浮阁"]

	restaurant := signal("宏图府")
	date := signal(FormatTime(,"LongDate"))
	time := signal("")
	guests := signal("")
	staff := signal("")

	writeClipboard(*) {
		if (
			time.value = "" or
			guests.value = "" or
			staff.value = ""
		) {
			return
		}
        A_Clipboard := Format("已预订{1} {2}, {3}。 人数: {4}位，接订工号：{5}",
			restaurant.value,
			date.value,
			time.value,
			guests.value,
			staff.value 
		)
        MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	return (
        App.AddGroupBox("r7 w320", "Table Reserve - 餐饮预订"),
        App.AddText("xp+10 yp+20", "预订餐厅"),
        App.AddComboBox("w150 x+10 Choose1", restaurantList)
        	.OnEvent("Change", (c*) => restaurant.set(restaurantList[c[1].value])),

        App.AddText("xp-58.5 y+10", "预订日期"),
        App.AddDateTime("x+10 w150", "LongDate")
        	.OnEvent("Change", (d*) => time.set(FormatTime(d[1].value,"LongDate"))),

        App.AddText("xp-58.5 y+10", "预订时间"),
        App.AddEdit("x+10 w150", "")
        	.OnEvent("LoseFocus", (e*) => time.set(e[1].value)),

        App.AddText("xp-58.5 y+10", "用餐人数"),
        App.AddEdit("x+10 w150 Number", "")
        	.OnEvent("LoseFocus", (e*) => guests.set(e[1].value)),

        App.AddText("xp-58.5 y+10", "对方工号"),
        App.AddEdit("x+10 w150", "")
        	.OnEvent("LoseFocus", (e*) => staff.set(e[1].value)),

        App.AddButton("x+14 yp-120 w80 h50 ", "复制`nComment`nAlert")
        	.OnEvent("Click", writeClipboard)
	)
}

App()
F12:: Reload
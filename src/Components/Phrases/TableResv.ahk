TableReserve(props) {
	App := props.App
	commonStyle := props.commonStyle

	comp := Component(App, A_ThisFunc)
	
	restaurantList := ["宏图府", "玉堂春暖", "风味餐厅", "流浮阁"]
	tomorrow := FormatTime(DateAdd(A_Now, 1, "Days"), "yyyyMMdd")

	comp.writeClipboard := writeClipboard
	writeClipboard(*) {
		form := comp.submit()

		if (form.time = "" || form.accommodate = "" || form.staffId = "") {
			return
		}

        A_Clipboard := Format("已预订{1} {2}, {3}。 人数: {4}位，接订工号：{5}",
			restaurantList[form.restaurant],
			FormatTime(form.date, "MM月dd日"),
			form.time,
			form.accommodate,
			form.staffId
		)

        return MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	comp.render := (this) => this.Add(
		App.AddGroupBox("Section r7 " . commonStyle, "Table Reserve - 餐饮预订"),
		; restaurant
		App.AddText("xp+10 yp+30 h20 0x200", "预订餐厅"),
		App.AddDropDownList("vrestaurant w150 x+10 Choose1", restaurantList),
		; date
		App.AddText("xs10 y+10 h20 0x200", "预订日期"),
		App.AddDateTime("vdate x+10 w150 Choose" . tomorrow, "LongDate"),
		; time
		App.AddText("xs10 y+10 h20 0x200", "预订时间"),
		App.AddEdit("vtime x+10 w150 h20", ""),
		; accommodate
		App.AddText("xs10 y+10 h20 0x200", "用餐人数"),
		App.AddEdit("vaccommodate x+10 w150 h20 Number", ""),
		; staff-id
		App.AddText("xs10 y+10 h20 0x200", "对方工号"),
		App.AddEdit("vstaffId x+10 w150 h20", "")
	)

	return comp
}
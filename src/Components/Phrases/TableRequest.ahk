TableRequest(props) {
	App := props.App
	commonStyle := props.commonStyle

	comp := Component(App, A_ThisFunc)
	
	restaurantList := ["宏图府", "玉堂春暖", "风味餐厅", "流浮阁"]
	tomorrow := FormatTime(DateAdd(A_Now, 1, "Days"), "yyyyMMdd")

	comp.writeClipboard := writeClipboard
	writeClipboard(*) {
		form := comp.submit()
		for field, val in form.OwnProps() {
			if (field == "trTel" && !val) {
				form.trTel := "Call 房间"
				continue
			}

			if (!val) {
				return
			}
		}

        A_Clipboard := Format("请预订: {1}房-{2}({3}), {4} {5} {6} {7}位",
			form.trRoom,
			form.trGuestName,
			form.trTel,
			restaurantList[form.trRestaurant],
			FormatTime(form.trDate, "MM月dd日"),
			form.trTime,
			form.trAccommodate,
		)

        return MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	comp.render := (this) => this.Add(
		App.AddGroupBox("Section r10 " . commonStyle, "Table Reserve - 餐饮预订"),

		; room 
		App.AddText("xs10 yp+30 h20 0x200", "预订房号"),
		App.AddEdit("vtrRoom x+10 w150 h20", ""),

		; name
		App.AddText("xs10 yp+30 h20 0x200", "预订客人"),
		App.AddEdit("vtrGuestName x+10 w150 h20", ""),

		; tel
		App.AddText("xs10 yp+30 h20 0x200", "预留电话"),
		App.AddEdit("vtrTel x+10 w150 h20", ""),

		; restaurant
		App.AddText("xs10 yp+30 h20 0x200", "预订餐厅"),
		App.AddDropDownList("vtrRestaurant w150 x+10 Choose1", restaurantList),
		
		; date
		App.AddText("xs10 y+10 h20 0x200", "预订日期"),
		App.AddDateTime("vtrDate x+10 w150 Choose" . tomorrow, "LongDate"),
		
		; time
		App.AddText("xs10 y+10 h20 0x200", "预订时间"),
		App.AddEdit("vtrTime x+10 w150 h20", ""),
		
		; accommodate
		App.AddText("xs10 y+10 h20 0x200", "用餐人数"),
		App.AddEdit("vtrAccommodate x+10 w150 h20 Number", "")
	)

	return comp
}
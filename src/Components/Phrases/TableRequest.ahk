TableRequest(props) {
	App := props.App
	commonStyle := props.commonStyle

	comp := Component(App, A_ThisFunc)
	
	restaurantList := ["宏图府", "玉堂春暖", "风味餐厅", "流浮阁"]
	tomorrow := FormatTime(DateAdd(A_Now, 1, "Days"), "yyyyMMdd") . "080000"

	comp.writeClipboard := writeClipboard
	writeClipboard(*) {
		form := comp.submit()
		for field, val in form.OwnProps() {
			if (field == "trTel" && !val) {
				form.trTel := "Call 房间"
				continue
			}

			if (!val) {
				return 0
			}
		}

        A_Clipboard := Format("请预订: {1}房-{2}({3}), {4} {5} {6}位",
			form.trRoom,
			form.trGuestName,
			form.trTel,
			restaurantList[form.trRestaurant],
			FormatTime(form.trDate, "MM月dd日 HH:mm"),
			form.trAccommodate,
		)

        return MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	formDefault := {
		trRoom: "",
		trGuestName: "",
		trTel: "",
		trAccommodate: "",
		trRestaurant: restaurantList[1],
		trDate: FormatTime(DateAdd(A_Now, 1, "Days"), "yyyyMMdd") . "080000"
	}

	resetForm(*) {
		for name, val in formDefault.OwnProps() {
			if (name == "trRestaurant") {
				App[name].Choose(val)
			} else {
				App[name].Value := val
			}
		}
	}

	comp.render := (this) => this.Add(
		App.AddGroupBox("Section r9 " . commonStyle, "Table Reserve - 餐饮预订"),

		; room 
		App.AddText("xs10 yp+30 h25 0x200", "预订房号"),
		App.AddEdit("vtrRoom x+10 w150 h25", ""),

		; name
		App.AddText("xs10 yp+35 h25 0x200", "客人姓名"),
		App.AddEdit("vtrGuestName x+10 w150 h25", ""),

		; tel
		App.AddText("xs10 yp+35 h25 0x200", "预留电话"),
		App.AddEdit("vtrTel x+10 w150 h25", ""),

		; accommodate
		App.AddText("xs10 yp+35 h25 0x200", "用餐人数"),
		App.AddEdit("vtrAccommodate x+10 w150 h25 Number", ""),

		; restaurant
		App.AddText("xs10 yp+35 h25 0x200", "预订餐厅"),
		App.AddDropDownList("vtrRestaurant w150 x+10 Choose1", restaurantList),
		
		; date time
		App.AddText("xs10 yp+35 h25 0x200", "预订日期"),
		App.AddDateTime("vtrDate x+10 w150 Choose" . tomorrow, " MM月dd日 HH:mm"),

		App.ARButton("x270 y500 w90 h30", "清  空").OnEvent("Click", resetForm)
	)

	return comp
}

/**
 * @param {Svaner} App 
 * @param {Object} props 
 * @returns {Component} 
 */
TableRequest(App, props) {
	comp := Component(App, A_ThisFunc)

	restaurantList := ["宏图府", "玉堂春暖", "风味餐厅", "流浮阁"]

	comp.writeClipboard := writeClipboard
	writeClipboard(this, ctrl, _) {
		form := comp.submit()
		for field, val in form.OwnProps() {
			if (field == "trTel" && !val) {
				form.trTel := "Call 房间"
				continue
			}

			if (field != "trClerk" && !val) {
				return 
			}
		}

		; A_Clipboard := Format("请预订: {1}房-{3}({4}), {5} {6} {7}位",
		; 	(ctrl.name == "phrase-copy" ? "请" : "已"),
		; 	form.trRoom,
		; 	form.trGuestName,
		; 	form.trTel,
		; 	restaurantList[form.trRestaurant],
		; 	FormatTime(form.trDate, "MM月dd日 HH:mm"),
		; 	form.trAccommodate,
		; )

		bookedMsg := Format("
			(
				请预订：{1} {2}
				房号：{3}(#{4})
				客人：{5}
				人数：{6}
				时间：{7}
				电话：{8}

				↓复制此行粘贴用↓
				{5}`t{6}`t{7}`t{4}`t{3}`t{8}
			)",
			FormatTime(form.trDate, "MM月dd日"),
			restaurantList[form.trRestaurant],
			form.trRoom,
			form.trConf,
			form.trGuestName,
			form.trAccommodate,
			FormatTime(form.trDate, "HH:mm"),
			form.trTel
		)

		; ”2月3日 08:00 宏图府 3位 陈先生(34200342)
		bookedAlert := Format("已预订: {1} {2} {3}位 {4}({5})",
			FormatTime(form.trDate, "MM月dd日 HH:mm"),
			restaurantList[form.trRestaurant],
			form.trAccommodate,
			form.trGuestName,
			form.trTel,
		)

		A_Clipboard := ctrl.Text == "已预订..." ? bookedAlert : bookedMsg

		return MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	resetForm(*) {
		formDefault := {
			trRoom: "",
			trConf: "",
			trGuestName: "",
			trTel: "",
			trAccommodate: "",
			trRestaurant: restaurantList[1],
			trDate: A_Now.tomorrow("080000")
		}

		for name, val in formDefault.OwnProps() {
			if (name == "trRestaurant") {
				App["tr-restaurant"].Choose(val)
			} else {
				fieldName := name
				App[ctrl => ctrl.name == fieldName.replace("tr", "tr-").toLower()][1].Value := val
			}
		}
	}

	comp.render := (this) => this.Add(
		StackBox(App,
			{
				name: "table-request-stack-box",
				font: { options: "bold" },
				groupbox: {
					title: "Table Reserve - 餐饮预订",
					options: "Section h215 @use:phrase-box-xyw"
				}
			},
			() => [
				; room
				App.AddText("@use:phrases-text yp+25", "预订房号"),
				App.AddEdit("vtr-room @use:phrases-edit w50", ""),
				App.AddText("@use:phrases-text x+1 yp+0 w10 Right", "#"),
				App.AddEdit("vtr-conf @use:phrases-edit x+1 w89", ""),
				
				; name
				App.AddText("@use:phrases-text", "客人姓名"),
				App.AddEdit("vtr-guestname @use:phrases-edit", ""),
				
				; tel
				App.AddText("@use:phrases-text", "预留电话"),
				App.AddEdit("vtr-tel @use:phrases-edit", ""),
				
				; accommodate
				App.AddText("@use:phrases-text", "用餐人数"),
				App.AddEdit("vtr-accommodate @use:phrases-edit Number", ""),
				
				; restaurant
				App.AddText("@use:phrases-text", "预订餐厅"),
				App.AddDDL("vtr-restaurant w150 x+10 Choose1", restaurantList),
				
				; date time
				App.AddText("@use:phrases-text", "预订日期"),
				App.AddDateTime("vtr-date x+10 w150 Choose" . A_Now.tomorrow("080000"), " MM月dd日 HH:mm"),
				
				; btns
				App.AddButton("@align[wx]:phrase-copy @relative[y+5]:phrase-copy h30", "已预订...")
				   .onClick((ctrl, _) => writeClipboard(comp, ctrl, _)),
				App.AddButton("@align[wx]:phrase-copy @relative[y+40]:phrase-copy h30", "清  空")
				   .onClick(resetForm)
			]
		)
	)

	return comp
}
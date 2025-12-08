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

		A_Clipboard := Format("{1}预订: {2}房-{3}({4}), {5} {6} {7}位{8}",
			(ctrl.name == "phrase-copy" ? "请" : "已"),
			form.trRoom,
			form.trGuestName,
			form.trTel,
			restaurantList[form.trRestaurant],
			FormatTime(form.trDate, "MM月dd日 HH:mm"),
			form.trAccommodate,
			form.trClerk ? Format(", 接订员工: {}", form.trClerk) : ""
		)

		return MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	resetForm(*) {
		formDefault := {
			trRoom: "",
			trGuestName: "",
			trTel: "",
			trAccommodate: "",
			trRestaurant: restaurantList[1],
			trDate: A_Now.tomorrow("080000"),
			trClerk: ""
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

	App.defineDirectives(
		"@use:tr-text", "xs10 yp+35 h25 0x200",
		"@use:tr-edit", "x+10 w150 h25"
	)

	comp.render := (this) => this.Add(
		StackBox(App,
			{
				name: "table-request-stack-box",
				groupbox: {
					title: "Table Reserve - 餐饮预订",
					options: "Section r12 @use:phrase-box-xyw"
				}
			},
			() => [
				; room
				App.AddText("@use:tr-text yp+30", "预订房号"),
				App.AddEdit("vtr-room @use:tr-edit", ""),
				
				; name
				App.AddText("@use:tr-text", "客人姓名"),
				App.AddEdit("vtr-guestname @use:tr-edit", ""),
				
				; tel
				App.AddText("@use:tr-text", "预留电话"),
				App.AddEdit("vtr-tel @use:tr-edit", ""),
				
				; accommodate
				App.AddText("@use:tr-text", "用餐人数"),
				App.AddEdit("vtr-accommodate @use:tr-edit Number", ""),
				
				; restaurant
				App.AddText("@use:tr-text", "预订餐厅"),
				App.AddDDL("vtr-restaurant w150 x+10 Choose1", restaurantList),
				
				; date time
				App.AddText("@use:tr-text", "预订日期"),
				App.AddDateTime("vtr-date x+10 w150 Choose" . A_Now.tomorrow("080000"), " MM月dd日 HH:mm"),
				
				; clerk
				App.AddText("@use:tr-text", "接订员工"),
				App.AddEdit("vtr-clerk @use:tr-edit", ""),
				
				; btns
				App.AddButton("@align[wx]:phrase-copy @relative[y+5]:phrase-copy h30", "已预定...")
				   .onClick((ctrl, _) => writeClipboard(comp, ctrl, _)),
				App.AddButton("@align[wx]:phrase-copy @relative[y+40]:phrase-copy h30", "清  空")
				   .onClick(resetForm)
			]
		)
	)

	return comp
}
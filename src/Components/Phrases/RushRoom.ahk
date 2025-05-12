RushRoom(props) {
	App := props.App
	commonStyle := props.commonStyle
	; btnStyle := props.btnStyle

	comp := Component(App, A_ThisFunc)

	comp.writeClipboard := (*) {
		rushTime := App.getCtrlByName("rushTime").Value
		keyMade := App.getCtrlByName("made").Value

		if (!rushTime) {
			return
		}

		A_Clipboard := keyMade
			? Format("赶房 {1}, Key Keep L10", rushTime)
			: Format("赶房 {1}, 未做房卡", rushTime)
		
		return MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	comp.render := (this) => this.Add(
		App.AddGroupBox("Section r3 " . commonStyle, "Rush Room - 赶房与Key Keep"),
		App.AddText("xs10 yp+30 h20 0x200", "赶房时间"),
		App.AddEdit("vrushTime xp+60 w150 h20", "14:00"),

		App.AddRadio("vkeyMade xs10 y+10 h25 Checked", "已做卡"),
		App.AddRadio("xp+70 h25", "未做卡")
		; App.AddReactiveButton(btnStyle, "复制`nComment`nAlert")
		;    .OnEvent("Click", (*) => writeClipboard())
	)

	return comp
}
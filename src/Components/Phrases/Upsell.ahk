Upsell(App, props) {
	commonStyle := props.commonStyle

	comp := Component(App, A_ThisFunc)

	comp.writeClipboard := writeClipboard
	writeClipboard(*) {
		form := comp.submit()

		if (!form.upsType || !form.diff || !form.upsNts) {
			return 0
		}

		commentTemplate := form.upsIsChn
			? "另加{1}元每晚 升级到{2}，共{3}晚，合共另加{4}元。"
			: "Add RMB{1}(per night) upgrade to {2} for {3}Nights, total RMB{4} EXTRA"

		A_Clipboard := Format(commentTemplate, form.diff, form.upsType, form.upsNts, form.diff * form.upsNts)
		
		return MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	comp.render := (this) => this.Add(
		App.AddGroupBox("Section r6 " . commonStyle, "Upselling - 房间升级"),

		; room type
		App.AddText("xs10 yp+30 h20 0x200", "升级房型"),
		App.AddEdit("vupsType x+10 w150 h20"),

		; diff
		App.AddText("xs10 y+10 h20 0x200", "每晚差价"),
		App.AddEdit("vdiff Number x+10 w150 h20", ""),

		; nts
		App.AddText("xs10 y+10 h20 0x200", "升级晚数"),
		App.AddEdit("vupsNts Number x+10 w150 h20", ""),

		; comment lang
		App.AddRadio("vupsIsChn xs10 y+15 h20 Checked", "中文"),
		App.AddRadio("x+10 h20", "英文")
	)

	return comp
}
Upsell(App) {
	ups := Component(App, A_ThisFunc)
	ups.description := "Upselling - 房间升级"

	writeClipboard() {
		form := ups.submit()

		if (form.upsType = "" || form.diff = "" || form.upsNts = "") {
			return
		}

		commentTemplate := form.upsIsChn = true
			? "另加{1}元每晚 升级到{2}，共{3}晚，合共另加{4}元。"
			: "Add RMB{1}(per night) upgrade to {2} for {3}Nights, total RMB{4} EXTRA"

		A_Clipboard := Format(commentTemplate, form.diff, form.upsType, form.upsNts, form.diff * form.upsNts)
		MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	ups.render := (this) => this.Add(
		App.AddGroupBox("Section x30 y350 w350 r6", "Upselling - 房间升级"),
		; room type
		App.AddText("xs10 yp+30 h20 0x200", "升级房型"),
		App.AddEdit("vupsType x+10 w150 h20"),
		; diff
		App.AddText("xs10 y+10 h20 0x200", "每晚差价"),
		App.AddEdit("vdiff x+10 w150 h20", ""),
		; nts
		App.AddText("xs10 y+10 h20 0x200", "升级晚数"),
		App.AddEdit("vupsNts x+10 w150 h20", ""),
		; comment lang
		App.AddRadio("vupsIsChn xs10 y+15 h20 Checked", "中文"),
		App.AddRadio("x+10 h20", "英文"),
			
		App.AddReactiveButton("x270 y380 w90 h55", "复制`nComment`nAlert")
		.OnEvent("Click", (*) => this.writeClipboard(App))	
	)

	return ups
}
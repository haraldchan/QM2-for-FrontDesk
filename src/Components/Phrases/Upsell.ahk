Upsell(App){
	roomType := signal("")
	rateDiff := signal("")
	nts := signal("")
	lang := signal("C")

	writeClipboard(*) {
		if (
			roomType.value = "" or 
			rateDiff.value = "" or
			nts.value = ""
		) {
			return
		}

		A_Clipboard := lang.value = "C"
			? Format("另加{1}元每晚 升级到{2}，共{3}晚，合共另加{4}元。", rateDiff.value, roomType.value, nts.value, rateDiff.value * nts.value)
			: Format("Add RMB{1}(per night) upgrade to {2} for {3}Nights, total RMB{4} EXTRA", rateDiff.value, roomType.value, nts.value, rateDiff.value * nts.value)
		MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	return (
        App.AddGroupBox("w320 r6", "Upselling - 房间升级"),

		App.AddText("xp+10 yp+25", "升级房型"),
		App.AddEdit("x+10 w150", "").OnEvent("LoseFocus", (e*) => roomType.set(e[1].value))

        App.AddText("xp-58 y+10 ", "每晚差价"),
		App.AddEdit("x+10 w150", "").OnEvent("LoseFocus", (e*) => rateDiff.set(e[1].value))

        App.AddText("xp-58 y+10", "升级晚数"),
		App.AddEdit("x+10 w150", "").OnEvent("LoseFocus", (e*) => nts.set(e[1].value))
 
		App.AddRadio("xp-55 y+10 h20 Checked", "中文").OnEvent("Click", (*) => lang.set("C"))
		App.AddRadio("x+10 h20", "英文").OnEvent("Click", (*) => lang.set("E"))
	
        App.AddButton("xp+160 yp-90 w80 h50", "复制`nComment`nAlert").OnEvent("Click", writeClipboard)
	)
}
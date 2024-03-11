RushRoom(App){
	rushTime := signal("14:00")
	keyMade := signal(true)
	
	writeClipboard(*){
		if (rushTime.value = "") {
			return
		}
		A_Clipboard := keyMade.value = true
			? Format("赶房 {1}, Key Keep L10", rushTime.value)
			:Format("赶房 {1}, 未做房卡", rushTime.value)
		MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	return (
		App.AddGroupBox("w320 r3", "Rush Room - 赶房与Key Keep"),
		App.AddText("xp+10 yp+20 h20", "赶房时间"),
        
        AddReactiveEdit(App, "xp+60 w150 h20", "{1}", rushTime,, ["LoseFocus", (e*) => rushTime.set(e[1].value)]),
        AddReactiveRadio(App, "xp-60 y+10 h25 Checked", "已做卡", keyMade,, ["Click", (*) => keyMade.set(true)]),
        AddReactiveRadio(App, "xp+70 h25", "已做卡", keyMade,, ["Click", (*) => keyMade.set(false)]),

        App.AddButton("xp+150 yp-30 w80 h50", "复制`nComment`nAlert").OnEvent("Click", writeClipboard)
	)
}

App()
F12:: Reload
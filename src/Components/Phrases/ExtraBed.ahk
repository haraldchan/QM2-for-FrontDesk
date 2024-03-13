ExtraBed(App){
	extraBedCharge := [
		{ label: "345元", price: 345 },
		{ label: "575元", price: 575 },
		{ label: "免费", price: 0 },
	]

	charge := signal(345)
	nts := signal(1)
	approver := signal("Amy")
	lang := signal("C")

	writeClipboard(*) {
		switch charge.value {
			case 345:
				commentChn := Format("另加床{1}元/晚，共{2}晚，合共另加{3}元。 ", charge.value, nts.Value, charge.value * nts.value)
				commentEng := Format("Add extra-bed for RMB{1}net per night for {2} night(s), RMB{3}net Extra. ", charge.value, nts.Value, charge.value * nts.value)
			case 575:
				commentChn := Format("另加床{1}元/晚含一位行政酒廊待遇，共{2}晚，合共另加{3}元。 ", charge.value, nts.value, charge.value * nts.value)
				commentEng := Format("Add extra-bed for RMB{1}net per night(including ClubFloor benefits) for {2} night(s), RMB{3}net Extra.", charge.value, nts.value, charge.value * nts.value)
			case 0:
				commentChn := Format("免费加床 by {1}，共{2}晚。 ", approver.value, nts.value)
				commentEng := Format("Free extra bed by {1} for {2}night(s). ", approver.value, nts.value)
		}
		A_Clipboard := lang.value = "C"
			? commentChn
			: commentEng
        MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	radioStyle(index){
		return index = 1 ? "xp+30 h15 Checked" : "x+10 h15"
	}

	return (
		App.AddGroupBox("w320 r5", "Extra Bed - 加床"),

		App.AddText("xp10 yp+25", "价格"),

		extraBedCharge.map(item =>
			App.AddRadio(radioStyle(A_Index), item.label).OnEvent("Click", (*) => charge.set(item.price))
		),

		App.AddText("xp-160 y+15 h20", "批准人"),
		App.AddEdit("xp+45 h20 w40", "Amy").OnEvent("LoseFocus", (e*) => approver.set(e[1].value)),

		App.AddText("xp+55", "加床晚数"),
		App.AddEdit("xp+55 w40 Number", "1").OnEvent("LoseFocus", (e*) => nts.set(e[1].value))

		App.AddRadio("xp-150 y+15 h25 Checked", "中文").OnEvent("Click", (*) => lang.set("C")),
		App.AddRadio("x+10 h25", "英文").OnEvent("Click", (*) => lang.set("E")),

		App.AddButton("x+108 yp-65 w80 h50", "复制`nComment`nAlert").OnEvent("Click", writeClipboard)
	)
}
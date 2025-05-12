ExtraBed(props) {
	App := props.App
	commonStyle := props.commonStyle
	; btnStyle := props.btnStyle

	comp := Component(App, A_ThisFunc)

	charge := signal(345)
	ebCharge := [
		{ label: "345元", price: 345 },
		{ label: "575元", price: 575 },
		{ label: "免费", price: 0 },
	]

	comp.writeClipboard := (*) {
		form := comp.submit()
		commentParams := [charge.value, form.ebNts, charge.value * form.ebNts]

		switch charge.value {
			case 345:
				commentChn := Format("另加床{1}元/晚，共{2}晚，合共另加{3}元。 ", commentParams*)
				commentEng := Format("Add extra-bed for RMB{1}net per night for {2} night(s), RMB{3}net Extra. ", commentParams*)
			case 575:
				commentChn := Format("另加床{1}元/晚含一位行政酒廊待遇，共{2}晚，合共另加{3}元。 ", commentParams*)
				commentEng := Format("Add extra-bed for RMB{1}net per night(including ClubFloor benefits) for {2} night(s), RMB{3}net Extra.", commentParams*)
			case 0:
				commentChn := Format("免费加床 by {1}，共{2}晚。 ", form.approver, form.ebNts)
				commentEng := Format("Free extra bed by {1} for {2}night(s). ", form.approver, form.ebNts)
		}
			
		A_Clipboard := form.ebIsChn ? commentChn : commentEng
	    
		return MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	comp.render := (this) => this.Add(
		App.AddGroupBox("Section r5 " . commonStyle, "Extra Bed - 加床"),

		App.AddText("xs10 yp+30 h20 0x200", "价格"),

		ebCharge.map((item, index) =>
			App.AddReactiveRadio((index = 1 ? "xp+30 h15 Checked" : "x+10 h15"), item.label)
			   .OnEvent("Click", (*) => charge.set(item.price))
		),

		App.AddText("xs10 y+15 h20 0x200", "批准人"),
		App.AddEdit("vapprover xp+45 h20 w50", "Frankie"),

		App.AddText("xp+60 h20 0x200", "加床晚数"),
		App.AddEdit("vebNts xp+55 w40 Number", "1"),

		App.AddRadio("vebIsChn xs10 y+5 h25 Checked", "中文"),
		App.AddRadio("x+10 h25", "英文")

		; App.AddReactiveButton(btnStyle, "复制`nComment`nAlert")
		;    .OnEvent("Click", (*) => writeClipboard())
	)

	return comp
}
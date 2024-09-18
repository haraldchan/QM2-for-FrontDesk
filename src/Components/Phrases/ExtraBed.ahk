class ExtraBed extends Component {
	static name := "ExtraBed"
	static description := "Extra Bed - 加床"

	__New(App) {
		super.__New("ExtraBed")
		this.charge := signal(345)
		this.extraBedCharge := [
			{ label: "345元", price: 345 },
			{ label: "575元", price: 575 },
			{ label: "免费", price: 0 },
		]
		this.render(App)
	}

	writeClipboard(App) {
		approver := App.getCtrlByName("approver").Value
		nts := App.getCtrlByName("ebnts").Value
		chn := App.getCtrlByName("chn").Value
		commentParams := [this.charge.value, nts, this.charge.value * nts]

		switch this.charge.value {
			case 345:
				commentChn := Format("另加床{1}元/晚，共{2}晚，合共另加{3}元。 ", commentParams*)
				commentEng := Format("Add extra-bed for RMB{1}net per night for {2} night(s), RMB{3}net Extra. ", commentParams*)
			case 575:
				commentChn := Format("另加床{1}元/晚含一位行政酒廊待遇，共{2}晚，合共另加{3}元。 ", commentParams*)
				commentEng := Format("Add extra-bed for RMB{1}net per night(including ClubFloor benefits) for {2} night(s), RMB{3}net Extra.", commentParams*)
			case 0:
				commentChn := Format("免费加床 by {1}，共{2}晚。 ", approver, nts)
				commentEng := Format("Free extra bed by {1} for {2}night(s). ", approver, nts)
		}
			
		A_Clipboard := chn = true
			? commentChn
			: commentEng
	    MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	render(App){
		return super.Add(
			App.AddGroupBox("Section w350 x30 y350 r5", "Extra Bed - 加床"),

			App.AddText("xs10 yp+30 h20 0x200", "价格"),

			this.extraBedCharge.map((item, index) =>
				App.AddReactiveRadio((index = 1 ? "xp+30 h15 Checked" : "x+10 h15"), item.label)
				   .OnEvent("Click", (*) => this.charge.set(item.price))
				),

			App.AddText("xs10 y+15 h20 0x200", "批准人"),
			App.AddEdit("vapprover xp+45 h20 w50", "Frankie"),

			App.AddText("xp+60 h20 0x200", "加床晚数"),
			App.AddEdit("vebnts xp+55 w40 Number", "1"),

			App.AddRadio("vebchn xs10 y+5 h25 Checked", "中文"),
			App.AddRadio("x+10 h25", "英文"),

			App.AddReactiveButton("x270 y380 w90 h55", "复制`nComment`nAlert")
			   .OnEvent("Click", (*) => this.writeClipboard(App))
		)
	}
}
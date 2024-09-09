class RushRoom extends Component {
	static name := "RushRoom"
	__New(App) {
		super.__New("RushRoom")
		this.render(App)
	}

	writeClipboard(App){
		rushTime := App.getCtrlByName("rushTime").Value
		made := App.getCtrlByName("made").Value

		if (rushTime = "") {
			return
		}

		A_Clipboard := made = true
			? Format("赶房 {1}, Key Keep L10", rushTime)
			: Format("赶房 {1}, 未做房卡", rushTime)
		MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	render(App){
		return super.Add(
			App.AddGroupBox("Section x30 y350 w350 r3", "Rush Room - 赶房与Key Keep"),
			App.AddText("xs10 yp+30 h20 0x200", "赶房时间"),
			App.AddEdit("vrushTime xp+60 w150 h20", "14:00"),

			App.AddRadio("vmade xs10 y+10 h25 Checked", "已做卡"),
			App.AddRadio("xp+70 h25", "未做卡"),
        	App.AddReactiveButton("x270 y380 w90 h55", "复制`nComment`nAlert")
        	   .OnEvent("Click", (*) => this.writeClipboard(App))
        )
	}
}
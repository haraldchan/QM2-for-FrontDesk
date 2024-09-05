class TableReserve extends Component {
	static name := "TableResv"
	__New(App) {
		super.__New("TableResv")
		this.restaurantList := ["宏图府", "玉堂春暖", "风味餐厅", "流浮阁"]
		this.render(App)
	}

	writeClipboard(App) {
		restaurant := App.getCtrlByName("restaurant").Text
		date := FormatTime(App.getCtrlByName("date").Value, "LongDate")
		time := App.getCtrlByName("time").Value
		accommodate := App.getCtrlByName("accommodate").Value
		staffId := App.getCtrlByName("staffId").Value

		if (time = "" || accommodate = "" || staffId = "") {
			return
		}

        A_Clipboard := Format("已预订{1} {2}, {3}。 人数: {4}位，接订工号：{5}",
			restaurant,
			date,
			time,
			accommodate,
			staffId
		)
        MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	render(App) {
		return super.Add(
			App.AddGroupBox("x30 y350 r7 w350", "Table Reserve - 餐饮预订"),
			App.AddText("xp+10 yp+20 h20 0x200", "预订餐厅"),
			App.AddDropDownList("vrestaurant w150 x+10 Choose1", this.restaurantList),

			App.AddText("xp-58.5 y+10 h20 0x200", "预订日期"),
			App.AddDateTime("vdate x+10 w150", "LongDate"),

			App.AddText("xp-58.5 y+10 h20 0x200", "预订时间"),
			App.AddEdit("vtime x+10 w150 h20", ""),

			App.AddText("xp-58.5 y+10 h20 0x200", "用餐人数"),
			App.AddEdit("vaccommodate x+10 w150 h20 Number", ""),

			App.AddText("xp-58.5 y+10 h20 0x200", "对方工号"),
			App.AddEdit("vstaffId x+10 w150 h20", ""),

			App.AddReactiveButton("x270 y370 w90 h55 ", "复制`nComment`nAlert")
			   .OnEvent("Click", (*) => this.writeClipboard(App))
		)
	}
}
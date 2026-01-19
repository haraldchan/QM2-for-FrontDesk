/**
 * @param {Svaner} App 
 * @param {Object} props 
 * @returns {Component} 
 */
RushRoom(App, props) {	
	comp := Component(App, A_ThisFunc)

	comp.writeClipboard := writeClipboard
	writeClipboard(*) {
		rushTime := App["rush-time"].Value
		keyMade := App["key-made"].Value

		if (!rushTime) {
			return 0
		}

		A_Clipboard := keyMade
			? Format("赶房 {1}, Key Keep L10", rushTime)
			: Format("赶房 {1}, 未做房卡", rushTime)

		return MsgBox(A_Clipboard, "已复制信息", "T1")
	}

	comp.render := (this) => this.Add(
		StackBox(App, 
			{
				name: "rush-room-stack-box",
				groupbox: {
					title: "Rush Room - 赶房与Key Keep",
					options: "Section r4 @use:phrase-box-xyw"
				}
			},
			() => [
				App.AddText("@use:phrases-text yp+20", "赶房时间"),
				App.AddEdit("vrush-time @use:phrases-edit", "14:00"),
				App.AddText("@use:phrases-text ", "房卡情况"),
				App.AddRadio("vkey-made x+10 h20 Checked", "已做卡"),
				App.AddRadio("x+20 h20", "未做卡")
			]
		)
	)

	return comp
}
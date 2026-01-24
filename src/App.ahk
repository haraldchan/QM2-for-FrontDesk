#Include features\index.ahk

/**
 * @param {Svaner} App 
 */
App(App) {
	description := "
	(
		快捷键及对应功能：
		F9:        显示脚本选择窗
		F12:       强制停止脚本/重载
	)"

	curActiveTab := signal(1)

	onTabChange(tab3, _) {
		WinSetAlwaysOnTop(false, POPUP_TITLE)
		curActiveTab.set(tab3.Text)
	}

	return (
		; desc
		StrSplit(description, "`n").map(fragment => App.AddText("y+5", fragment)),
		
		; persist scripts
		PersistScriptsControl(App),

		; op action modules/ phrases/ report master
		App.AddTab3("w380 x15 Choose1", OrderedMap(
			"一键运行", () => OnePress(App),
			"常用语句", () => Phrases(App),
			"夜班报表", () => OverNightReports(App),
			"团单信息", () => OnDayGroupReports(App, curActiveTab),
			"其他报表", () => MiscReports(App),
		)).onChange(onTabChange)
	)
}

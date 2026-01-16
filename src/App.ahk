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

	tabTitles := ["一键运行", "常用语句", "夜班报表", "团单信息", "其他报表"]
	curActiveTab := signal(tabTitles[1])

	onTabChange(tab3, _) {
		WinSetAlwaysOnTop(false, POPUP_TITLE)
		curActiveTab.set(tab3.Text)
	}

	return (
		; desc
		StrSplit(description, "`n").map(fragment => App.AddText("y+5", fragment)),

		PersistScriptsControl(App),
		
		; Action Module Tabs
		Tab3 := App.AddTab3("w380 x15" . " Choose1", tabTitles).onChange(onTabChange),
		
		Tab3.UseTab("一键运行"),
		OnePress(App),

		Tab3.UseTab("常用语句"),
		Phrases(App),

		Tab3.UseTab("夜班报表"),
		OverNightReports(App)

		Tab3.UseTab("团单信息"),
		OnDayGroupReports(App, curActiveTab)

		Tab3.UseTab("其他报表"),

		Tab3.UseTab(),
		App["first-radio"].Focus()
	)
}

#Include "./TabPages/OnePress.ahk"
#Include "./TabPages/Phrases.ahk"

Tabs(App) {

	return (
		Tab3 := App.AddTab3("w380 x15" . " Choose1", ["一键运行", "报表保存", "常用语句"]),

		Tab3.UseTab(1),
		OnePress(App),

		Tab3.UseTab(2),
		ReportMasterNext(App),

		Tab3.UseTab(3),
		Phrases(App),

		Tab3.UseTab()
	)
}
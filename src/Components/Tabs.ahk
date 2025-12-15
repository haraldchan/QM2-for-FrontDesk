#Include tab-pages\one-press.ahk
#Include tab-pages\phrases.ahk

/**
 * @param {Svaner} App 
 */
Tabs(App) {

	return (
		Tab3 := App.AddTab3("w380 x15" . " Choose1", ["一键运行", "报表保存", "常用语句"])
		           .onChange((*) => WinSetAlwaysOnTop(false, POPUP_TITLE)),
		
		Tab3.UseTab(1),
		OnePress(App),

		Tab3.UseTab(2),
		ReportMasterNext(App),

		Tab3.UseTab(3),
		Phrases(App),

		; Tab3.UseTab(4),
		; InOutHelper(App),

		Tab3.UseTab()
	)
}
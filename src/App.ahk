#Include "./action-modules/action-module-index.ahk"
#Include "./components/tabs.ahk"
#Include "./persist-scripts/persist-scripts-control.ahk"

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

	return (
		; desc
		StrSplit(description, "`n").map(fragment => App.AddText("y+5", fragment)),

		PersistScriptsControl(App),
		
		; Action Module Tabs
		Tabs(App),
		App["firstRadio"].Focus()
	)
}

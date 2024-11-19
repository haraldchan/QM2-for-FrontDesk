#Include "../lib/LibIndex.ahk"
#Include "../src/ActionModules/ActionModuleIndex.ahk"
#Include "./Components/Tabs.ahk"
#Include "./PersistScripts/PersistScriptsControl.ahk"

App(App) {

	description := "
	(
		快捷键及对应功能：
		F9:        显示脚本选择窗
		F12:       强制停止脚本/重载
	)"

	return (
		StrSplit(description, "`n").map(fragment => App.AddText("y+5", fragment)),
		; PSC
		PersistScriptsControl(App),
		; Action Module Tabs
		Tabs(App)
	)
}

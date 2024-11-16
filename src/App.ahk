#Include "../lib/LibIndex.ahk"
#Include "../src/ActionModules/ActionModuleIndex.ahk"
#Include "./Components/Tabs.ahk"

App(App) {
	cityLedgerPersist := signal(false)

	description := "
	(
		快捷键及对应功能：
		F9:        显示脚本选择窗
		F12:       强制停止脚本/重载

		常驻脚本(按下即启动)
		Ctrl+O 或 鼠标中键:    CityLedger挂账
	)"

	(() => (
		HotIf((*) => cityLedgerPersist.value),
		Hotkey("^o", (*) => CityLedgerCo.USE()),
		Hotkey("MButton", (*) => CityLedgerCo.USE())
	))()
	
	return (
		StrSplit(description, "`n").map(fragment => App.AddText("y+5", fragment)),

		App.AddCheckbox("y+10 h25", "令 CityLedger 挂账保持常驻")
		   .OnEvent("Click", (*) => cityLedgerPersist.set(on => !on)),

		Tabs(App)
	)
}

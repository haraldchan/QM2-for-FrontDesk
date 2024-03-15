#Include "../lib/LibIndex.ahk"
#Include "../src/ActionModules/ActionModuleIndex.ahk"
#Include "./Components/Tabs.ahk"

cityLedgerPersist := signal(false)

App(QM) {
	useDesktopXl := signal(false)
	curSelectedScriptTab1 := signal(InhShare)
	curSelectedScriptTab2 := signal(GroupKeys)
	curTab := signal(1)

	runSelectedScript() {
		if (!WinExist("ahk_class SunAwtFrame")) {
			MsgBox("Opera PMS 未启动！", popupTitle, "4096 T2")
			return
		}

		QM.Hide()
		if (curTab.value = 1) {
			curSelectedScriptTab1.value.USE()
		} else if (curTab.value = 2) {
			curSelectedScriptTab2.value.USE(useDesktopXl.value)
		} else {
			return
		}
	}

	description := "
	(
		快捷键及对应功能：
		
		F9:        显示脚本选择窗
		F12:       强制停止脚本/重载
		
		常驻脚本(按下即启动)
		Ctrl+O 或 鼠标中键:    CityLedger挂账
	)"

	return (
		QM.AddText(, description),

		QM.AddCheckbox("y+10 h25", "令 CityLedger 挂账保持常驻")
			.OnEvent("Click", (*) => cityLedgerPersist.set(on => !on)),

		Tabs(QM, curTab, curSelectedScriptTab1, curSelectedScriptTab2, useDesktopXl),

		QM.AddButton("Default h40 w160", "启动脚本").OnEvent("Click", (*) => runSelectedScript()),
		QM.AddButton("h40 w160 x+28", "隐藏窗口").OnEvent("Click", (*) => QM.Hide())
	)
}
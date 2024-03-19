#Include "../lib/LibIndex.ahk"
#Include "../src/ActionModules/ActionModuleIndex.ahk"
#Include "./Components/Tabs.ahk"

cityLedgerPersist := signal(false)

App(QM) {
	useDesktopXl := signal(false)
	curSelectedScriptTab1 := signal(InhShare)
	curSelectedScriptTab2 := signal(GroupKeys)
	curTab := signal(1)

	suspendClipFLow(){
		ClipFlowPath := "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow\ClipFlow.ahk"

		DetectHiddenWindows true
		SetTitleMatchMode 2
		PostMessage 0x0111, 65305,,, ClipFlowPath . " - AutoHotkey"  ; Suspend.
	}

	runSelectedScript() {
		if (!WinExist("ahk_class SunAwtFrame")) {
			MsgBox("Opera PMS 未启动！", popupTitle, "4096 T2")
			return
		}
		suspendClipFLow()
		QM.Hide()

		if (curTab.value = 1) {
			curSelectedScriptTab1.value.USE()
		} else if (curTab.value = 2) {
			curSelectedScriptTab2.value.USE(useDesktopXl.value)
		} else {
			return
		}
		suspendClipFLow()
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
		; QM.AddText(, description),
		StrSplit(description, "`n").map(fragment => 
			QM.AddText("y+10 h25", fragment)
		)

		QM.AddCheckbox("y+10 h25", "令 CityLedger 挂账保持常驻")
			.OnEvent("Click", (*) => cityLedgerPersist.set(on => !on)),

		Tabs(QM, curTab, curSelectedScriptTab1, curSelectedScriptTab2, useDesktopXl),

		QM.AddButton("Default h40 w160", "启动脚本").OnEvent("Click", (*) => runSelectedScript()),
		QM.AddButton("h40 w160 x+28", "隐藏窗口").OnEvent("Click", (*) => QM.Hide())
	)
}
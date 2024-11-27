#Include "../lib/LibIndex.ahk"
#Include "../src/ActionModules/ActionModuleIndex.ahk"
#Include "./Components/Tabs.ahk"
#Include "./PersistScripts/PersistScriptsControl.ahk"

App(App) {
	U := useProfile()

	description := "
	(
		快捷键及对应功能：
		F9:        显示脚本选择窗
		F12:       强制停止脚本/重载
	)"

	return (
		; desc
		StrSplit(description, "`n").map(fragment => App.AddText("y+5", fragment)),
		
		; user profile
		App.AddCheckbox("", "当前用户").OnEvent("Click", (ctrl, _) => U.setUsing(ctrl.Value)),
		App.AddComboBox("w100 x+10", U.users.map(user => user["username"]))
		   .OnEvent("Change", (ctrl, _) => U.setUser(ctrl.Text)),
		
		App.AddButton("vshowUserInfo w60 h30 x+10", "查看")
		   .OnEvent("Click", (*) => (U.showUserInfo(App))),
		App.AddButton("vsubmitUserInfo w60 h30 x+10", "新建")
		   .OnEvent("Click", (*) => (U.showUserInfo(App, "new"))),
		; PSC
		PersistScriptsControl(App),
		
		; Action Module Tabs
		Tabs(App),
		App.getCtrlByName("firstRadio").Focus()
	)
}

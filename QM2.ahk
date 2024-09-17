#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "./src/App.ahk"
TraySetIcon A_ScriptDir . "\src\assets\QMTray.ico"
TrayTip "QM 2 运行中…按下 F9 开始使用脚本"
CoordMode "Mouse", "Screen"

; Initializing configuration
version := "2.3.0"
popupTitle := "QM2 for FrontDesk " . version
winGroup := ["ahk_class SunAwtFrame", "旅客信息", "ahk_class 360se6_Frame"]

; Gui
QM := Gui(, popupTitle)
QM.SetFont(, "微软雅黑")
App(QM)
QM.Show()
QM.OnEvent("Close", (*) => utils.quitApp("QM2", popupTitle, winGroup))

; hotkey setup
F9:: {
    QM.Show()
}
F12:: utils.cleanReload(winGroup)

#HotIf WinActive(popupTitle)
Esc:: QM.Hide()


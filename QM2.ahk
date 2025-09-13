#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "./src/App.ahk"
TraySetIcon A_ScriptDir . "\src\assets\QMTray.ico"
TrayTip "QM 2 运行中…按下 F9 开始使用脚本"
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

; global consts
VERSION := "2.7.0"
POPUP_TITLE := "QM2 for FrontDesk " . VERSION
WIN_GROUP := ["ahk_class SunAwtFrame", "旅客信息", "ahk_class 360se6_Frame"]
IMAGES := useImages(A_ScriptDir . "\src\Assets")

; Gui
QM := Gui(, POPUP_TITLE)
QM.SetFont(, "微软雅黑")
App(QM)
QM.Show()
QM.OnEvent("Close", (*) => utils.quitApp("QM2", POPUP_TITLE, WIN_GROUP))

; hotkey setup
F9:: QM.Show()
^F12:: utils.cleanReload(WIN_GROUP)

#HotIf WinActive(POPUP_TITLE)
Esc:: QM.Hide()

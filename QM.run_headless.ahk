; configs
#Requires AutoHotkey v2.0
#SingleInstance Off
; includes
#Include lib\lib-index.ahk
#Include src\App.ahk

; acquire admin
if (!A_IsAdmin) {
    Run("*RunAs " . A_ScriptFullPath)
    ExitApp()
}
; utils.clearExistInstances()

; global consts
CONFIG := useJsonConfig("./qm.config.json", "qm.config.json", A_AppData . "\QM2")
VERSION := CONFIG.read("version")
POPUP_TITLE := "QM2 for FrontDesk " . VERSION
WIN_GROUP := ["ahk_class SunAwtFrame", "旅客信息", "ahk_class 360se6_Frame"]
IMAGES := useImages(A_ScriptDir . "\assets")
FORCE_SUSPEND_MESSAGE := 0x2042
SUSPEND_CONTROLLER := SuspendController(FORCE_SUSPEND_MESSAGE)

; init setup
TraySetIcon(IMAGES["QMTray.ico"])
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")



; hotkey setup
^F12:: {
	if (FileExist(CONFIG.path)) {
		FileDelete(CONFIG.path)
	}
    CONFIG.createLocal()
    utils.cleanReload(WIN_GROUP)
}

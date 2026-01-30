; configs
#Requires AutoHotkey v2.0
#SingleInstance Force
; includes
#Include lib\lib-index.ahk
#Include src\App.ahk

; global consts
VERSION := "2.8.4"
POPUP_TITLE := "QM2 for FrontDesk " . VERSION
WIN_GROUP := ["ahk_class SunAwtFrame", "旅客信息", "ahk_class 360se6_Frame"]
IMAGES := useImages(A_ScriptDir . "\src\Assets")
CONFIG := useConfigJSON("./qm.config.json", "qm.config.json")

; init setup
TraySetIcon IMAGES["QMTray.ico"]
TrayTip "QM 2 运行中…按下 F9 开始使用脚本"
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

; attach App
QM := Svaner({
    gui: {
        title: POPUP_TITLE
    },
    font: {
        name: "微软雅黑"
    },
    events: {
        close: (*) => utils.quitApp("QM2", POPUP_TITLE, WIN_GROUP)
    },
    ; devOpt: { border: true }
})
App(QM)
QM.Show()

; hotkey setup
F9:: QM.Show()
^F12:: {
	if (FileExist(CONFIG.path)) {
		FileDelete(CONFIG.path)
	}
    CONFIG.createLocal()
    utils.cleanReload(WIN_GROUP)
}

#HotIf WinActive(POPUP_TITLE)
Esc:: QM.Hide()
; configs
#Requires AutoHotkey v2.0
#SingleInstance Force
; includes
#Include lib\lib-index.ahk
#Include src\App.ahk

; acquire admin
if (!A_IsAdmin) {
    Run("*RunAs " . A_ScriptFullPath)
}

; global consts
VERSION := "2.9.5"
POPUP_TITLE := "QM2 for FrontDesk " . VERSION
WIN_GROUP := ["ahk_class SunAwtFrame", "旅客信息", "ahk_class 360se6_Frame"]
IMAGES := useImages(A_ScriptDir . "\assets")
APP_DATA_DIR := A_AppData . "\QM2"
CONFIG := useJsonConfig("./qm.config.json", "qm.config.json", APP_DATA_DIR)
FORCE_SUSPEND_MESSAGE := 0x2042
SUSPEND_CONTROLLER := SuspendController(FORCE_SUSPEND_MESSAGE)

; init setup
TraySetIcon(IMAGES["QMTray.ico"])
TrayTip("QM 2 运行中…按下 F9 开始使用脚本")
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

; attach App
QM := Svaner({
    gui: {
        title: POPUP_TITLE
    },
    font: {
        name: "微软雅黑"
    },
    events: {
        close: (*) => utils.quitApp("QM2", POPUP_TITLE, WIN_GROUP),
        escape: app => app.Hide()
    },
    ; devOpt: { border: true }
})
App(QM)
QM.Show()

; hotkey setup
F9:: {
    QM.Show()
}
^F12:: {
	if (FileExist(CONFIG.path)) {
		FileDelete(CONFIG.path)
	}
    CONFIG.createLocal()
    utils.cleanReload(WIN_GROUP)
}

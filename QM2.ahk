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
VERSION := "2.9.0"
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
        close: (*) => utils.quitApp("QM2", POPUP_TITLE, WIN_GROUP)
    },
    ; devOpt: { border: true }
})
App(QM)
QM.Show()

; error logger
OnError(logError, false)
/**
 * @param {Error} err 
 */
logError(err, *) {
    if (!DirExist(A_ScriptDir . "\error-log")) {
        DirCreate(A_ScriptDir . "\error-log")
    }

    errTxt := A_ScriptDir . "\error-log\" . FormatTime(A_Now, "yyyyMMdd") . "txt"
    errLog := Format("
    (
        {1} line: {2}
        message: {3}
        error:   {4}`n`n
    )",
        FormatTime(A_Now, "yyyy/MM/dd HH:mm"),
        err.Line,
        err.Message,
        err.Extra
    )

    FileAppend(errLog, errTxt, "utf-8")
    	if (FileExist(CONFIG.path)) {
        FileDelete(CONFIG.path)
    }
    CONFIG.createLocal()
    
    utils.cleanReload(WIN_GROUP)
}

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

#HotIf WinActive(POPUP_TITLE)
Esc:: {
    QM.Hide()
}
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "./src/App.ahk"
TraySetIcon A_ScriptDir . "\src\assets\QMTray.ico"
TrayTip "QM 2 运行中…按下 F9 开始使用脚本"
CoordMode "Mouse", "Screen"

; Initializing configuration
version := "2.2.0"
popupTitle := "QM2 for FrontDesk " . version
winGroup := ["ahk_class SunAwtFrame", "旅客信息"]

; Gui
QM := Gui(, popupTitle)
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

#HotIf cityLedgerPersist.value
^o:: CityLedgerCo.USE()
MButton:: CityLedgerCo.USE()

#HotIf WinExist(CashieringScripts.popupTitle)
::pw:: {
    CashieringScripts.sendPassword()
}
::agd:: {
    CashieringScripts.agodaBalanceTransfer()
}
::blk:: {
    CashieringScripts.blockPmBilling()
}
!F11:: CashieringScripts.openBilling()
#F11:: CashieringScripts.depositEntry()
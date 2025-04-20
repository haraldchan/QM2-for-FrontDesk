#Include "./BalanceTransfer.ahk"
#Include "./CityLedgerCo.ahk"
#Include "./ScanInvoke.ahk"

PersistScriptsControl(App) {
	setHotkeys() {
		; City Ledger
		HotIf (*) => App.getCtrlByName("CityLedgerOn").Value
		Hotkey "^o", (*) => CityLedgerCo.USE()
		Hotkey "MButton", (*) => CityLedgerCo.USE()

		; Balance Transfer
		HotIf (*) => App.getCtrlByName("BalanceTransferOn").Value
		HotString "::bt", (*) => BalanceTransfer.USE()

		; Invoke Scan
		HotIf (*) => App.getCtrlByName("ScanInvoke").Value
		Hotkey "^+s", (*) => ScanInvoke()
	}

	openScanFolder(*) {
		Run "\\10.0.2.13\fd\01 FO PASSPORT SCANNING"
	}

	return (
		App.AddGroupBox("Section x15 y+10 w375 h100", "常驻脚本").SetFont("Bold"),

		; City Ledger
		App.AddCheckbox("vCityLedgerOn xs10 ys+20 w130 h25", "City Ledger"),
		App.AddText("w150 h25 x+10 0x200", "热键: Ctrl + O | 鼠标滚轮键"),
		
		; Balance Transfer
		App.AddCheckbox("vBalanceTransferOn xs10 yp+25 w130 h25 Checked", "Balance Transfer"),
		App.AddText("w150 h25 x+10 0x200", "输入: BT"),

		; Scan Invoke
		App.AddCheckbox("vScanInvoke xs10 yp+25 w130 h25 Checked", "启动扫描"),
		App.AddText("w110 h25 x+10 0x200", "热键: Ctrl+Shift+S"),
		App.AddButton("x+10 h23", "Scan 文件夹").OnEvent("Click", openScanFolder),

		; binding
		setHotkeys()
	)
}
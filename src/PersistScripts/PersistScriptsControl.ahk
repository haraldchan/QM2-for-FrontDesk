#Include "./BalanceTransfer.ahk"
#Include "./CityLedgerCo.ahk"

PersistScriptsControl(App) {
	setHotkeys() {
		; City Ledger
		HotIf (*) => App.getCtrlByName("CityLedgerOn").Value
		Hotkey "^o", (*) => CityLedgerCo.USE()
		Hotkey "MButton", (*) => CityLedgerCo.USE()
		; Balance Transfer
		HotIf (*) => App.getCtrlByName("BalanceTransferOn").Value
		HotString "::bt", (*) => BalanceTransfer.USE()
	}

	return (
		App.AddGroupBox("Section x15 y+10 w375 r2", "常驻脚本").SetFont("Bold"),

		; City Ledger
		App.AddCheckbox("vCityLedgerOn xs10 ys+20 w130 h25", "City Ledger"),
		App.AddText("w150 h25 x+10 0x200", "热键: Ctrl + O | 鼠标滚轮键"),
		
		; Balance Transfer
		App.AddCheckbox("vBalanceTransferOn xs10 y+0 w130 h25 Checked", "Balance Transfer"),
		App.AddText("w150 h25 x+10 0x200", "输入: BT"),

		; binding
		setHotkeys()
	)
}
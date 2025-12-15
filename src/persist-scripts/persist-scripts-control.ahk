#Include balance-transfer.ahk
#Include city-ledger-co.ahk
#Include scan-invoke.ahk
#Include deposit-entry.ahk

/**
 * @param {Svaner} App 
 */
PersistScriptsControl(App) {
	onMount() {
		; City Ledger
		HotIf (*) => App["city-ledger-on"].Value
		Hotkey("^o", (*) => CityLedgerCo.USE())
		Hotkey("MButton", (*) => CityLedgerCo.USE())

		; Invoke Scan
		HotIf (*) => App["scan-invoke-on"].Value
		Hotkey("^+s", (*) => ScanInvoke(), "On")

		; Balance Transfer
		HotIf (*) => App["balance-transfer-on"].Value
		HotString("::bt", (*) => BalanceTransfer.USE())

		; Deposit Entry
		OnClipboardChange((*) => DepositEntry.USE(App["deposit-entry-on"]))
	}

	App.defineDirectives(
		"@use:psc-label", "xs10 yp+25 w130 h25",
		"@use:psc-desc", "w150 h25 x+10 0x200",
		"@func:bold", ctrl => ctrl.SetFont("bold")
	)

	return (
		StackBox(
			App, 
			{
				name: "persist-scripts-stack-box",
				fontOptions: "bold",
				groupbox: {
					title: "常驻脚本",
					options: "Section x15 y+10 w375 h130",
				}
			},
			() => [
				; City Ledger
				App.AddCheckbox("vcity-ledger-on @use:psc-label", "City Ledger"),
				App.AddText("@use:psc-desc", "热键: Ctrl + O | 鼠标滚轮键"),
			
				; Scan Invoke
				App.AddCheckbox("vscan-invoke-on @use:psc-label Checked", "启动扫描"),
				App.AddText("@use:psc-desc", "热键: Ctrl+Shift+S"),
				App.AddLink("xp+105 yp+5 w80 @func:bold", "{1}", { text: "(Scan 文件夹)", href: "\\10.0.2.13\fd\01 FO PASSPORT SCANNING" }),
				; App.AddLink("xp+105 yp+5", "{1}", { text: "Scan 文件夹", href: "C:\Users\haraldchan\Code" }),
			
				; Balance Transfer
				App.AddCheckbox("vbalance-transfer-on @use:psc-label yp+20 Checked", "Balance Transfer"),
				App.AddText("@use:psc-desc", "输入: BT"),
			
				; Deposit Entry
				App.AddCheckbox("vdeposit-entry-on @use:psc-label Checked", "押金录入"),
				App.AddText("@use:psc-desc", "监听: 绿云复制卡号"),
			]
		),
		
		onMount()
	)
}

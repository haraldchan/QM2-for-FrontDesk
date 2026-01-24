#Include scripts\balance-transfer.ahk
#Include scripts\city-ledger-co.ahk
#Include scripts\scan-invoke.ahk
#Include scripts\deposit-entry.ahk

/**
 * @param {Svaner} App 
 */
PersistScriptsControl(App) {
	handleOpenScanFolder(*) {
		scanFolderPath := "\\10.0.2.13\fd\01 FO PASSPORT SCANNING"
		
		if (!DirExist(scanFolderPath)) {
			MsgBox(Format("证件扫描文件夹 <{1}> 未找到", scanFolderPath), POPUP_TITLE, "T5 0x10")
			return
		}

		Run(scanFolderPath)
	}

	handlePersistSwitch(cb, _) {
		CONFIG.write(cb.name.replace("-on", ""), cb.value)
	}

	onMount() {
		for script, enabled in CONFIG.read("persist-scripts-switch") {
			App[script . "-on"].Value := enabled
		}

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
		OnClipboardChange((*) => DepositEntry.copyFromMipay(App["deposit-entry-on"]))
	}

	App.defineDirectives(
		"@use:psc-label", "xs10 yp+25 w130 h20",
		"@use:psc-desc", "w150 h20 x+10 0x200",
		"@func:bold", ctrl => ctrl.SetFont("bold")
	)

	return (
		StackBox(
			App, 
			{
				name: "persist-scripts-stack-box",
				font: { 
					options: "bold"
				},
				groupbox: {
					title: "常驻脚本",
					options: "Section x15 y+10 w375 h130",
				}
			},
			() => [
				; City Ledger
				App.AddCheckbox("vcity-ledger-on @use:psc-label yp+20", "City Ledger").onClick(handlePersistSwitch),
				App.AddText("@use:psc-desc", "热键: Ctrl + O | 鼠标滚轮键"),
			
				; Scan Invoke
				App.AddCheckbox("vscan-invoke-on @use:psc-label", "启动扫描").onClick(handlePersistSwitch),
				App.AddText("@use:psc-desc", "热键: Ctrl+Shift+S"),
				App.AddButton("xp+105 w80 h20", "Scan 文件夹").onClick(handleOpenScanFolder),

				; Balance Transfer
				App.AddCheckbox("vbalance-transfer-on @use:psc-label", "Balance Transfer").onClick(handlePersistSwitch),
				App.AddText("@use:psc-desc", "输入: BT"),
			
				; Deposit Entry
				App.AddCheckbox("vdeposit-entry-on @use:psc-label", "押金录入").onClick(handlePersistSwitch),
				App.AddText("@use:psc-desc", "监听: 绿云复制卡号"),
			]
		),
		
		onMount()
	)
}

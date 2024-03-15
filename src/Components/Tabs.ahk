#Include "./TabPages/OnePress.ahk"
#Include "./TabPages/Xldp.ahk"
#Include "./Phrases/RushRoom.ahk"
#Include "./Phrases/Upsell.ahk"
#Include "./Phrases/ExtraBed.ahk"
#Include "./Phrases/TableResv.ahk"

Tabs(QM, curTab, curSelectedScriptTab1, curSelectedScriptTab2, useDesktopXl) {

	return (
		Tab3 := QM.AddTab3("w350 x15" . " Choose1", ["一键运行", "Excel 辅助", "常用语句"]),
		Tab3.OnEvent("Change", (t*) => curTab.set(t[1].value)),

		Tab3.UseTab(1),
		OnePress(QM, curSelectedScriptTab1),

		Tab3.UseTab(2),
		Xldp(QM, curSelectedScriptTab2, useDesktopXl),

		Tab3.UseTab(3),
		RushRoom(QM),
		QM.AddText("xp-230 y+12",""),
		Upsell(QM),
		QM.AddText("xp-232 y+72",""),
		ExtraBed(QM),
		QM.AddText("xp-232 y+50",""),
		TableReserve(QM),

		Tab3.UseTab()
	)
}
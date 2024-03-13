#Include "./reports.ahk"

class ReportMaster {
	static description := "报表保存 - Report Master"
	static popupTitle := "Report Master"
	static reportList := {
		onr: [{
			searchStr: "%complimentary",
			name: "Guest INH Complimentary",
			saveFn: comp
		}, {
			searchStr: "FI01",
			name: "NA02-Manager Flash",
			saveFn: mgrFlash
		}, {
			searchStr: "RS05",
			name: "RS05-（前后15天）History & Forecast",
			saveFn: hisFor15
		}, {
			searchStr: "RS05",
			name: "RS05-（FO当月）History & Forecast",
			saveFn: hisForThisMonth
		}, {
			searchStr: "RS05",
			name: "RS05-（FO次月）History & Forecast",
			saveFn: hisForNextMonth
		}, {
			searchStr: "FO01-VIP",
			name: "VIP Arrival (VIP Arr)",
			saveFn: vipArr
		}, {
			searchStr: "FO03",
			name: "FO03-VIP DEP",
			saveFn: vipDep
		}, {
			searchStr: "FO01",
			name: "FO01-Arrival Detailed",
			saveFn: arrAll
		}, {
			searchStr: "FO02",
			name: "FO02-Guests INH by Room",
			saveFn: inhAll
		}, {
			searchStr: "FO03",
			name: "FO03-Departures",
			saveFn: depAll
		}, {
			searchStr: "FO11",
			name: "FO11-Credit Limit",
			saveFn: creditLimit
		}, {
			searchStr: "FO13",
			name: "FO13-Package Forecast（仅早餐）",
			saveFn: bbf
		}, {
			searchStr: "%hkroomstatusperroom",
			name: "Rooms-housekeepingstatus",
			saveFn: rooms
		}, {
			searchStr: "HK03",
			name: "HK03-OOO",
			saveFn: ooo
		}, {
			searchStr: "gprpmlist",
			name: "Group Rooming List",
			saveFn: groupRoom
		}, {
			searchStr: "grpinhouse",
			name: "Group In House",
			saveFn: groupInh
		}, {
			searchStr: "FO08",
			name: "FO08-No Show",
			saveFn: noShow
		}, {
			searchStr: "rescancel",
			name: "Cancellations",
			saveFn: cancel
		}, {
			searchStr: "%guestinhw",
			name: "Guest In House w/o Due Out(VIP INH)",
			saveFn: vipInh
		},
		],
		misc: [{
			searchStr: "GRPRMLIST",
			name: "Group Arrival - 当天预抵团单",
			saveFn: arrivingGroups
		}, {
			searchStr: "Wshgz_special",
			name: "Specials - 当天水果5 报表",
			saveFn: special
		}, {
			searchStr: "pkgforecast",
			name: "Upselling - 当天 Upsell 报表",
			saveFn: upsellPkg
		}, {
			searchStr: "pkgforecast",
			name: "Afternoon Tea - 当天 大堂吧下午茶 报表",
			saveFn: lobbyBarAFT
		}, {
			searchStr: "pkgforecast",
			name: "Morning Tea - 宏图府早茶 报表",
			saveFn: hongtuMorningTea
		}, {
			searchStr: "pkgforecast",
			name: "Morning Tea - 丝绸之路早茶 报表",
			saveFn: silkroadMorningTea
		},
		]
	}


	static USE() {
		RM := Gui("", this.popupTitle)

		tab3 := RM.AddTab3("w300 h600", ["夜班报表", "其他报表"])
		tab3.UseTab(1)
		RM.AddText("xp+10 yp+35", "请选择需要保存的报表，日期设定为夜审后操作。`n`n（报表将保存至 开始菜单-文档）。")
		overNightReports := []
		for report in this.reportList.onr {
			overNightReports.Push(
				RM.AddCheckbox("Checked h15 xp y+12", report.name)
			)
		}
		for control in overNightReports {
			control.OnEvent("Click", checkIsSelectedAll)
		}
		tab3.UseTab(2)
		miscReports := []

		for report in this.reportList.misc {
			radioStyle := (A_Index = 1) ? "Checked h15 xp y+15" : "h15 xp y+15"
			miscReports.Push(
				RM.AddRadio(radioStyle, report.name)
			)
		}
		tab3.UseTab()

		footer := [
			RM.AddCheckbox("vselectAllBtn Checked h22 x15", "全选"),
			RM.AddDropDownList("vfileType w50 x+100 Choose1", ["PDF", "XML", "TXT", "XLS"]),
			RM.AddButton("w80 x+10 Default", "保存报表").OnEvent("Click", saveReports),
		]

		RM.Show()

		global isSelectedAll := true
		selectAllBtn := interface.getCtrlByName("selectAllBtn", footer)
		fileTypeBtn := interface.getCtrlByName("fileType", footer)

		selectAllBtn.OnEvent("Click", setSelectAll)

		checkIsSelectedAll(*) {
			selectAllBtn.Value := jsa.every((item) => item.Value = 1, overNightReports) ? 1 : 0
			global isSelectedAll := selectAllBtn.Value
		}

		setSelectAll(*) {
			global isSelectedAll := !isSelectedAll
			for control in overNightReports {
				control.Value := isSelectedAll
			}
		}

		saveReports(*) {
			savedReport := ""
			fileType := fileTypeBtn.Text

			if (tab3.Value = 1) {
				if (jsa.every(item => item.Value = 0, overNightReports)) {
					return
				}
				for checkbox in overNightReports {
					if (checkbox.Value = 1) {
						if (this.reportList.onr[A_Index].name = "RS05-（FO次月）History & Forecast") {
							if ((this.getLastDay() - A_DD) > 5) {
								continue
							}
						}
						reportFiling(this.reportList.onr[A_Index], fileType)
						savedReport .= this.reportList.onr[A_Index].name . "`n"
					}
				}
				if (jsa.every((item) => item.Value = 1, overNightReports)) {
					savedReport := "夜班报表"
				}
			} else {
				for checkbox in miscReports {
					if (checkbox.Value = 1) {
						savedReport := this.handleMiscReportOptions(this.reportList.misc[A_Index], fileType)
					}
				}
			}
			Sleep 1000
			this.openMyDocs(savedReport)
		}
	}

	static handleMiscReportOptions(reportInfoObj, fileType) {
		if (reportInfoObj.name = "Group Arrival - 当天预抵团单") {
			this.groupArrivingOptions(fileType)
		} else {
			reportFiling(reportInfoObj, fileType)
		} 
		return reportInfoObj.name
	}

	static openMyDocs(reportName) {
		WinSetAlwaysOnTop false
		myText := "已保存报表：`n`n" . reportName . "`n`n是否打开所在文件夹? "
		openFolder := MsgBox(myText, this.popupTitle, "OKCancel")
		if (openFolder = "OK") {
			Run A_MyDocuments
		} else {
			utils.cleanReload(winGroup)
		}
	}

	static getLastDay() {
		preAuditDate := DateAdd(A_Now, -1, "Days")
		preAuditMonth := FormatTime(preAuditDate, "MM")
		preAuditYear := FormatTime(preAuditDate, "yyyy")
		nextMonth := (preAuditMonth = 12) ? 1 : preAuditMonth + 1
		if (nextMonth < 10) {
			nextMonth := "0" . nextMonth
		}
		printYear := preAuditMonth = 12 ? preAuditYear + 1 : preAuditYear
		firstDayOfNextMonth := printYear . nextMonth . "01"
		return FormatTime(DateAdd(firstDayOfNextMonth, -1, "Days"), "dd")
	}

	static groupArrivingOptions(fileType) {
		reportName := "当天 Arrival 团单"
		onDayGroup := Format("\\10.0.2.13\fd\9-ON DAY GROUP DETAILS\{2}\{2}{3}\{1}Group ARR&DEP.xlsx", FormatTime(A_Now, "yyyyMMdd"), A_Year, A_MM)
		blockInfo := this.getBlockInfo(onDayGroup)
		blockInfoText := ""
		for blockName, blockCode in blockInfo {
			blockInfoText .= Format("{1}：{2}`n", blockName, blockCode)
		}
		rmListSaver := MsgBox(Format("
			(	
			请确认当天Arrival 团队信息：

			{1}

			是(Y)：自动保存上述团队团单
			否(N)：手动录入block code保存团单
			取消：退出脚本
			)", blockInfoText), this.popupTitle, "YesNoCancel")
		if (rmListSaver = "Yes") {
			this.saveGroupAll(blockinfo, fileType)
		} else if (rmListSaver = "No") {
			this.saveGroupRmList(fileType)
		} else {
			utils.cleanReload(winGroup)
		}
	}

	static getBlockInfo(fileName) {
		blockInfoMap := Map()
		Xl := ComObject("Excel.Application")
		OnDayGroupDetails := Xl.Workbooks.Open(fileName).Worksheets("Sheet1")
		loop {
			blockCodeReceived := OnDayGroupDetails.Cells(A_Index + 3, 1).Text
			blockNameReceived := OnDayGroupDetails.Cells(A_Index + 3, 2).Text
			if (blockCodeReceived = "" || blockCodeReceived = "Group StayOver") {
				break
			}
			blockInfoMap[blockNameReceived] := blockCodeReceived
		}
		Xl.Workbooks.Close()
		Xl.Quit()
		return blockInfoMap
	}

	static saveGroupRmList(fileType) {
		groups := []
		Loop {
			blocks := InputBox("
			(
			请输入blockcode，按下取消或Esc退出
			
			如需另外命名pdf 文件，请以“blockcode=文件名”形式输入
			如：20230901huaha=华海
			)", "Arr Group Rooming Lists")
			if (blocks.Result = "Cancel" || blocks.Value = "") {
				break
			}
			groups.push(blocks.Value)
		}
		BlockInput true
		WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
		For g in groups {
			if (InStr(g, "=")) {
				g := StrSplit(g, "=")
				this.reportList.misc[1].blockCode := g[1]
				this.reportList.misc[1].blockName := g[2]
			} else {
				this.reportList.misc[1].blockCode := g
				this.reportList.misc[1].blockName := g
			}
			reportFiling(this.reportList.misc[1], fileType)
		}
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
		BlockInput false
	}

	static saveGroupAll(blockInfo, fileType) {
		BlockInput true
		WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
		for blockName, blockCode in blockInfo {
			this.reportList.misc[1].blockCode := blockCode
			this.reportList.misc[1].blockName := blockName
			reportFiling(this.reportList.misc[1], fileType)
		}
		WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
		BlockInput false
	}
}
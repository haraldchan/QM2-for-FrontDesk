/**
 * @param {Svaner} App 
 */
MiscReports(App) {
    miscReports := Map(
        "FO13 - Packages", (*) => MR_PackageSpecialOptions(App, { reportType: "packages", groupboxTitle: "FO13 - Packages" }),
        "WSHGZ - Specials", (*) => MR_PackageSpecialOptions(App, { reportType: "specials", groupboxTitle: "WSHGZ - Specials" }),
        "预抵消费券 - ArrivingCoupons", (*) => MR_Optionless(App),
        "当天夜退房间 - OnDayLateOut", (*) => MR_Optionless(App),
        "昨日住房国籍数量 - CountryByDate", (*) => MR_Optionless(App),
        "Market Segment - MarketStats", (*) => MR_MarketSegmentOptions(App),
        "可售房型余量 - DetailedAvailability", (*) => MR_Optionless(App),
    )

    selectedMiscReport := signal(miscReports.keys()[1])

    defineReportDescriptor() {
        prefix := selectedMiscReport.value.split(" - ").at(-1).toLower()

        reportDescriptor := ReportMaster_Action.miscReports.find(r => r.name == selectedMiscReport.value)

        if (selectedMiscReport.value.includes("Market Segment")) {
            groupBy := App["market-segment-groupby"].Text
            reportDate := FormatTime(App["market-segment-date"].Value, "yyyyMMdd")

            if (DateDiff(reportDate, FormatTime(A_Now, "yyyyMMdd"), "Days") >= 0) {
                MsgBox("Market Segment 报表日期必须早于今日", POPUP_TITLE, "4096 iconi")
                return
            }

            reportDescriptor.name := reportDate "-MarketSegment by " groupBy
            reportDescriptor.args := [groupBy, reportDate]
        }
        else if (selectedMiscReport.value == "FO13 - Packages" || selectedMiscReport.value == "WSHGZ - Specials") {
            reportDescriptor.name := App[prefix . "-save-filename"].Value.trim() || App[prefix . "-presets"].Text.replace("自定义", App[prefix . "-codes"].Value.trim())
            reportDescriptor.args := [
                App[prefix . "-codes"].Value.trim(),
                App[prefix . "-save-filename"].Value.trim() || App[prefix . "-presets"].Text.replace("自定义", App[prefix . "-codes"].Value.trim()),
                App[prefix . "-fr-date"].Value,
                App[prefix . "-to-date"].Value,
            ]

            if (prefix == "packages") {
                reportDescriptor.args.Push(App["group-by-pkg"].Value)
            }
        }

        return reportDescriptor
    }

    saveReport(*) {
        reportDescriptor := defineReportDescriptor()
        if (!reportDescriptor) {
            return
        }

        if (reportDescriptor.hasOwnProp("args") && !reportDescriptor.args[1]) {
            return
        }

        ReportMaster_Action.start()
        savedFiledName := ReportMaster_Action.reportFiling(reportDescriptor, App["misc-file-type"].Text)
        ReportMaster_Action.end()

        WinSetAlwaysOnTop(false, "ahk_class SunAwtFrame")
        saveText := "已保存报表：`n`n" . Format("{1}-{2}", FormatTime(A_Now, "yyyyMMdd"), reportDescriptor.name) . "`n`n是否打开所在文件夹? "
        if (MsgBox(saveText, POPUP_TITLE, "OKCancel 4096") == "OK") {
            Run(Format('explorer /select, "{1}"', A_MyDocuments . "\" . savedFiledName))
        } else {
            utils.cleanReload(WIN_GROUP)
        }
    }

    render() {
        App.AddListBox("vmisc-list x30 y+15 w260 r8 Choose1", miscReports.keys())
            .onChange((ctrl, _) => selectedMiscReport.set(ctrl.Text))
        App.AddListBox("vmisc-file-type @align[y]:misc-list x+10 w80 r5 Choose1", ["PDF", "XML", "TXT", "HTML", "XLS"])
        App.AddButton("vmisc-report-save @align[x]:misc-file-type y+16 h25 w80 Default", "保存报表")
            .onClick(saveReport)
        ; options
        Dynamic(App, selectedMiscReport, miscReports)
    }

    return render()
}


/**
 * @param {Svaner} App 
 */
MR_PackageSpecialOptions(App, props) {
    comp := Component(App, props.reportType . "_" . props.reportType.toUpper())

    productCodePresets := OrderedMap("自定义", "")
    for preset, codes in CONFIG.read(["report-master", "misc-reports", props.reportType, "presets"]) {
        productCodePresets[preset] := codes
    }

    selectedPreset := signal("")

    handleSetPreset(ctrl, _) {
        selectedPreset.set(productCodePresets[ctrl.Text])
    }

    handleSaveCustomPresetInput(ctrl, _) {
        if (App[props.reportType . "-presets"].Text != "自定义") {
            return
        }

        productCodePresets["自定义"] := ctrl.Value.trim()
    }

    comp.render := this => this.Add(
        StackBox(
            App, {
                name: Format("mr-{1}-options", props.reportType),
                font: { options: "bold" },
                groupbox: {
                    title: props.groupboxTitle,
                    options: "Section x30 @relative[y+15]:misc-list w350 " . (props.reportType == "packages" ? "h155" : "h130")
                }
            },
            () => [
                ; date range
                App.AddText("xs10 yp+30 w100 h20 0x200", "报表日期范围"),
                App.AddDateTime("v" . props.reportType . "-fr-date x+10 h20 w100"),
                App.AddDateTime("v" . props.reportType . "-to-date x+10 h20 w100"),
                ; codes
                App.AddText("xs10 yp+30 w100 h20 0x200", "Code(空格分隔)"),
                App.AddEdit("v" . props.reportType . "-codes x+10 w145 h20 ", "{1}", selectedPreset)
                .onBlur(handleSaveCustomPresetInput),
                App.AddDDL("v" . props.reportType . "-presets x+5 w60 Choose1", productCodePresets.keys())
                .onChange(handleSetPreset),
                ; save file name
                App.AddText("xs10 yp+30 w100 h20 0x200", "保存文件名"),
                App.AddEdit("v" . props.reportType . "-save-filename x+10 h20 w210"),
                ; groupby option for packages
                props.reportType == "packages" && App.AddCheckBox("vgroup-by-pkg xs10 yp+35 h20 0x200 Checked", "按 Package Code 分组")
            ]
        )
    )

    return comp
}

/**
 * @param {Svaner} App 
 */
MR_Optionless(App) {
    comp := Component(App, A_ThisFunc)

    comp.render := this => this.Add(
        StackBox(
            App, {
                font: { options: "bold" },
                groupbox: {
                    title: "(无可用选项)",
                    options: "Section x30 @relative[y+15]:misc-list w350 h35"
                }
            },
            () => []
        )
    )

    return comp
}


/**
 * @param {Svaner} App 
 */
MR_MarketSegmentOptions(App) {
    comp := Component(App, "Market Segment")

    comp.render := this => this.Add(
        StackBox(
            App, {
                name: Format("mr-{1}-options", "Market Segment"),
                font: { options: "bold" },
                groupbox: {
                    title: "Market Segment",
                    options: "Section x30 @relative[y+15]:misc-list w350 h100"
                }
            },
            () => [
                ; date range
                App.AddText("xs10 yp+30 w100 h20 0x200", "报表日期"),
                App.AddDateTime("vmarket-segment-date x+10 h20 w210"),
                ; codes
                App.AddText("xs10 yp+30 w100 h20 0x200", "归类选项"),
                App.AddDDL("vmarket-segment-groupby x+10 w210 Choose1", ["MarketCode", "SourceCode"]),
            ]
        )
    )

    return comp
}
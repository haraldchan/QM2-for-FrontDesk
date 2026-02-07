/**
 * @param {Svaner} App 
 */
MiscReports(App) {
    miscReports := Map(
        "FO13 - Packages", (*) => MiscReportOptions(App, { reportType: "packages", groupboxTitle: "FO13 - Packages" }),
        "WSHGZ - Specials", (*) => MiscReportOptions(App, { reportType: "specials", groupboxTitle: "WSHGZ - Specials" }),
    )

    selectedMiscReport := signal(miscReports.keys()[1])

    defineReportInfo() {
        prefix := selectedMiscReport.value.split(" - ").at(-1)

        searchStr := match(selectedMiscReport.value, Map(
            "FO13 - Packages", "pkgforecast",
            "WSHGZ - Specials", "Wshgz_special"
        ))

        return {
            searchStr: searchStr,
            name: App[prefix . "-save-filename"].Value.trim() || App[prefix . "-presets"].Text.replace("自定义", App[prefix . "-codes"].Value.trim()),
            saveFn: ReportMaster_Action.%prefix%,
            args: [
                App[prefix . "-codes"].Value.trim(),
                App[prefix . "-save-filename"].Value.trim() || App[prefix . "-presets"].Text.replace("自定义", App[prefix . "-codes"].Value.trim()),
                App[prefix . "-fr-date"].Value.toFormat("MMddyyyy"),
                App[prefix . "-to-date"].Value.toFormat("MMddyyyy"),
            ]
        }
    }

    saveReports(*) {
        reportInfo := defineReportInfo()

        if (!reportInfo.args[1]) {
            return
        }

        ; MsgBox JSON.stringify(reportInfo)

        ReportMaster_Action.start()
        ReportMaster_Action.reportFiling(reportInfo, App["misc-file-type"].Text)
        ReportMaster_Action.end()

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        saveText := "已保存报表：`n`n" . Format("{1}-{2}", FormatTime(A_Now, "yyyyMMdd"), reportInfo.name) . "`n`n是否打开所在文件夹? "
        if (MsgBox(saveText, POPUP_TITLE, "OKCancel 4096") == "OK") {
            Run Format(
                'explorer /select, "{1}"',
                A_MyDocuments . Format("\{1}-{2}.{3}", FormatTime(A_Now, "yyyyMMdd"), reportInfo.name, App["misc-file-type"].Text)
            )
        } else {
            utils.cleanReload(WIN_GROUP)
        }
    }

    return (
        App.AddListBox("vmisc-list x30 y+15 w260 r4 Choose1", miscReports.keys())
        .onChange((ctrl, _) => selectedMiscReport.set(ctrl.Text)),
        App.AddDDL("vmisc-file-type @align[y]:misc-list x+10 w80 Choose1", ["PDF", "XML", "TXT", "XLS"]),
        App.AddButton("vmisc-report-save @align[x]:misc-file-type y+16 h25 w80 Default", "保存报表")
        .onClick(saveReports),
        ; options
        Dynamic(App, selectedMiscReport, miscReports)
    )
}

/**
 * @param {Svaner} App 
 */
MiscReportOptions(App, props) {
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
                groupbox: {
                    title: props.groupboxTitle,
                    options: "Section x30 @relative[y+15]:misc-list w350 h130 @use:bold"
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
                App.AddEdit("v" . props.reportType . "-save-filename x+10 h20 w210")
            ]
        )
    )

    return comp
}
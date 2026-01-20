/**
 * @param {Svaner} App 
 */
MiscReports(App) {
    miscReports := Map(
        "FO13 - Packages", MR_Packages_Options,
        "WSHGZ - Specials", MR_Specials_Options,
    )

    selectedMiscReport := signal(miscReports.keys()[1])

    saveReports(*) {
        reportInfo := match(selectedMiscReport.value, Map(
            "FO13 - Packages", 
            {
                searchStr: "pkgforecast",
                name: App["pkg-save-filename"].Value.trim(),
                saveFn: ReportMaster_Action.packages,
                args: [
                    App["pkg-codes"].Value.trim(),
                    App["pkg-save-filename"].Value.trim()
                    App["pkg-fr-date"].Value,
                    App["pkg-to-date"].Value,
                ]
            },
            "WSHGZ - Specials",
            {
                searchStr: "Wshgz_special",
                name: App["sp-save-filename"].Value.trim(),
                saveFn: ReportMaster_Action.specials,
                args: [
                    App["sp-codes"].Value.trim(), 
                    App["sp-save-filename"].Value.trim()
                ]
            },
        ))

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
        App.AddButton("vmisc-report-save @align[x]:misc-file-type y+16 h25 w80 Default", "保存报表"),
       
        ; options
        Dynamic(App, selectedMiscReport, miscReports)
    )
}

/**
 * @param {Svaner} App 
 */
MR_Packages_Options(App, props) {
    comp := Component(App, A_ThisFunc)

    pkgCodePresets := OrderedMap(
        "自定义", "",
        "早餐", "BFNP BFPP BFC",
        "Upsell", "%UP",
        "一盅两件", "DXTC DXTCF",
    )

    selectedPkgPreset := signal("")
    
    handleSetPkgPreset(ctrl, _) {
        selectedPkgPreset.set(pkgCodePresets[ctrl.Text])
    }

    handleSaveCustomPresetInput(ctrl, _) {
        if (App["pkg-presets"].Text != "自定义") {
            return
        }

        pkgCodePresets["自定义"] := ctrl.Value.trim()
    }

    comp.render := this => this.Add(
        StackBox(
            App, {
                name: "mr-packages-options",
                groupbox: {
                    title: "Packages 报表选项",
                    options: "Section vmr-pkg-options x30 y+15 w350 h130"
                }
            },
            () => [
                ; date range
                App.AddText("xs10 yp+30 w100 h20 0x200", "报表日期范围"),
                App.AddDateTime("vpkg-fr-date x+10 h20 w100"),
                App.AddDateTime("vpkg-to-date x+10 h20 w100"),
                ; pkg codes
                App.AddText("xs10 yp+30 w100 h20 0x200", "Pkg.Code(空格分隔)"),
                App.AddEdit("vpkg-codes x+10 w145 h20 ", "{1}", selectedPkgPreset)
                   .onBlur(handleSaveCustomPresetInput),
                App.AddDDL("vpkg-presets x+5 w60 Choose1", pkgCodePresets.keys())
                   .onChange(handleSetPkgPreset),
                ; save file name
                App.AddText("xs10 yp+30 w100 h20 0x200", "保存文件名"),
                App.AddEdit("vpkg-save-filename x+10 h20 w210")
            ]
        )
    )

    return comp
}

/**
 * @param {Svaner} App 
 */
MR_Specials_Options(App, props) {
    comp := Component(App, A_ThisFunc)

    comp.render := this => this.Add(
        StackBox(
            App, {
                name: "mr-specials-options",
                groupbox: {
                    title: "Specials 报表选项",
                    options: "Section @align[xy]:mr-pkg-options w350 h100"
                }
            },
            () => [
                ; special codes
                App.AddText("xs10 yp+30 w100 h20 0x200", "Sp.Code(空格分隔)"),
                App.AddEdit("vsp-codes x+10 h20 w210"),
                ; save file name
                App.AddText("xs10 yp+30 w100 h20 0x200", "保存文件名"),
                App.AddEdit("vsp-save-filename x+10 h20 w210")
            ]
        )
    )

    return comp
}
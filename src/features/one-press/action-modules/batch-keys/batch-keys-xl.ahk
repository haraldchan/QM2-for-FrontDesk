#Include "./batch-keys-action.ahk"

BatchKeysXl(App, props){
    comp := Component(App, A_ThisFunc)
    xlPath := signal(A_ScriptDir . "\src\Excel\GroupKeys.xls")

    handleSelectXl(*) {
        App.Opt("+OwnDialogs")
        selectedFile := FileSelect(3, , "请选择 Excel 文件", "Excel files(*.xls; *.xlsx; *.xlsm)")
        if (!selectedFile) {
            MsgBox("请选择文件")
            return
        }
        xlPath.set(selectedFile)
    }

    handleToogleDesktopMode(ctrl, _) {
        isEnabled := ctrl.Value

        App["file-path"].Enabled := !isEnabled
        App["select-xl-btn"].Enabled := !isEnabled

        if (isEnabled) {
            if (!FileExist(A_Desktop . "\GroupKeys.xls")) {
                FileCopy(A_ScriptDir . "\src\Excel\GroupKeys.xls", A_Desktop . "\Groupkeys.xls")
            }
            xlPath.set(A_Desktop . "\GroupKeys.xls")
        } else {
            xlPath.set(A_ScriptDir . "\src\Excel\GroupKeys.xls")
        }
    }

    action(*) {
        BatchKeysXl_Action.USE(
            xlPath.value, 
            App["co-datetime-xl"].Value, 
            App["enable-28f-xl"].Value, 
            App["use-desktop-xl"].Value
        )
    }

    comp.render := (this) => this.Add(
        StackBox(App,
            {
                name: "batch-keys-xl-stack-box",
                groupbox: {
                    options: "Section r9 @use:box",
                    title: "批量房卡制作（Excel 表辅助）"
                }
            },
            () => [
                ; xl file selector
                App.AddEdit("vfile-path xs10 yp+30 h25 w150 ReadOnly", "{1}", xlPath),
                App.AddButton("vselect-xl-btn h25 w70 x+10", "选择文件")
                   .onClick(handleSelectXl),
                App.AddButton("vopen-xl-btn h25 w70 x+10", "打开表格")
                   .onClick((*) => Run(xlPath.value)),
                App.AddCheckBox("vuse-desktop-xl h25 xs10 y+10", "使用桌面文件模式")
                   .onClick(handleToogleDesktopMode),

                ; default date-time
                App.AddText("xs10 yp+40 w100 h25 0x200", "退房日期、时间："),
                App.AddDateTime("vco-datetime-xl x+15 w200 Choose" . A_Now.tomorrow("130000"), "yyyy-MM-dd HH:mm"),

                ; btns
                App.AddButton("vbatchkeysxl-action xs10 y+10 w100", "开始制卡")
                   .onClick(action),
                App.AddCheckBox("venable-28f-xl x+15 h30", "可开启28楼电梯")
            ]
        )
    )

    return comp
}

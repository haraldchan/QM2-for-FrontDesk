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

    App.defineDirectives(
        "@use:bkx-text", "xs10 yp+30 w100 h25 0x200",
        "@use:bkx-edit", "w200 x+10 h25 0x200"
    )

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
                App.AddText("@use:bkx-text yp+25", "Excel 表格位置"),
                App.AddEdit("vfile-path x+10 h25 w130 ReadOnly", "{1}", xlPath),
                App.AddButton("vselect-xl-btn h25 w40 x+5", "选择")
                   .onClick(handleSelectXl),
                App.AddButton("vopen-xl-btn h25 w40 x+5", "打开")
                   .onClick((*) => Run(xlPath.value)),
                ; desktop mode
                App.AddText("@use:bkx-text", "桌面文件模式"),
                App.AddCheckBox("vuse-desktop-xl h25 x+10", "使用桌面 Group Keys.xls")
                   .onClick(handleToogleDesktopMode),

                ; divider
                App.AddText("@use:bkx-text w330 h0 0x10", ""),
                ; default date-time
                App.AddText("@use:bkx-text yp+10 w330 h25", "表格中未设定日期时间，将使用以下设置").SetFont("bold"),
                App.AddText("@use:bkx-text", "退房日期及时间"),
                App.AddDateTime("vco-datetime-xl x+10 w200 Choose" . A_Now.tomorrow("130000"), "yyyy-MM-dd HH:mm"),

                ; btns
                App.AddButton("vbatchkeysxl-action xs10 y+10 w100", "开始制卡")
                   .onClick(action),
                App.AddCheckBox("venable-28f-xl x+15 @align[h]:batchkeysxl-action", "可开启28楼电梯")
            ]
        )
    )

    return comp
}

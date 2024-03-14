Xldp(QM, curSelectedScriptTab2, useDesktopXl) {
    modules := [
        GroupKeys,
        GroupProfilesModify,
        PsbBatchCO,
    ]

    xlPath := signal([
        GroupKeys.defaultPath,
        GroupProfilesModify.defaultPath,
        PsbBatchCO.defaultPath
    ])

    radioStyle(index) {
        return index = 1 ? "Checked x30 y+10 h25" : "x30 y+10 h25"
    }

    handleSelect(ctrls, thisRadio, thisModule,*) {
        for ctrlArray in ctrls {
            ctrlArray[1].setValue(0)
        }
        thisRadio.value := 1
        curSelectedScriptTab2.set(thisModule)
    }

    selectNewXl(index,*) {
        QM.Opt("+OwnDialogs")
        selectedFile := FileSelect(3, , "请选择 Excel 文件")
        if (selectedFile = "") {
            MsgBox("请选择文件")
            return
        }
        xlPath.set(xlPath.value.with(index, selectedFile))
    }

    toggleDesktopMode(ctrlGroups) {
        useDesktopXl.set(use => !use)
        for ctrlArray in ctrlGroups {
            for ctrl in ctrlArray {
                if (ctrl is Gui.Control) {
                    ctrl.Enabled := !useDesktopXl.value
                } else {
                    ctrl.disable(!useDesktopXl.value)
                }
            }
        }

    }


    xldpNotifier := "
    (
        功能说明：
            
        启动脚本前，必须先将对应的数据从 Opera PMS 导出的报
            
        表中复制到 Excel 表中，才能实现功能。
            
            
        桌面文件模式：
            
        选中“使用桌面文件模式”后，脚本将只会从本机桌面读取

        相应文件名的 Excel 表。 请直接在桌面操作所需 Excel

        工作表。
 
    )"

    return (
        ctrls := modules.map((module, index) => [
            AddReactiveRadio(QM, radioStyle(A_Index), module.description, curSelectedScriptTab2,,
                ["Click", (r*) => handleSelect(ctrls, r[1], module)]),

            AddReactiveEdit(QM, "x30 y+10 h25 w150  ReadOnly", "{1}", xlPath, A_Index),

            AddReactiveButton(QM, "h25 w70 x+10", "选择文件", xlPath,,
                ["Click", (*) => selectNewXl(index)]),

            AddReactiveButton(QM, "h25 w70 x+10", "打开表格", xlPath,,
                ["Click", (*) => Run(xlPath.value[index])]),
        ]),
        QM.AddCheckbox("h25 x30 y+10", "使用桌面文件模式").OnEvent("Click", (*) => toggleDesktopMode(ctrls)),
        QM.AddText("y+25", xldpNotifier)
    )
}
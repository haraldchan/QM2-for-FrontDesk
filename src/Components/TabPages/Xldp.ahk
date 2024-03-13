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
        return index = 1 ? "Checked h25" : "h25 y+10"
    }

    handleSelect(ctrls, thisRadio, thisModule) {
        for ctrl in ctrls {
            ctrl[1].Enabled := false
        }
        thisRadio.Enabled := true
        curSelectedScriptTab2.set(thisModule)
    }

    selectNewXl(index) {
        QM.Opt("+OwnDialogs")
        selectedFile := FileSelect(3, , "请选择 Excel 文件")
        if (selectedFile = "") {
            MsgBox("请选择文件")
            return
        }
        xlPath.set(xlPath.set(xlPath.value.with(index, selectedFile)))
    }

    toggleDesktopMode(ctrls) {
        useDesktopXl.set(use => !use)
        for ctrlGroup in ctrls {
            for ctrl in ctrlGroup {
                if (ctrl is Gui.Control) {
                    ctrl.Enabled := useDesktopXl.value
                } else {
                    ctrl.disable(useDesktopXl.value)
                }
            }
        }
    }

    return (
        ctrls := modules.map(module =>
            QM.AddRadio(radioStyle(A_Index), module.description).OnEvent("Click", (r*) => handleSelect(ctrls, r[1], module))
            AddReactiveEdit(QM, "h25 w150 x20 y+10 ReadOnly", "{1}", xlPath, A_Index)
            QM.AddButton("h25 w70 x+20", "选择文件").OnEvent("Click", (*) => selectNewXl(A_Index))
            QM.AddButton("h25 w70 x+10", "打开表格")).OnEvent("Click", (*) => Run(xlPath.value[A_Index]))
        QM.AddCheckbox("h25 x20 y+10", "使用桌面文件模式").OnEvent("Click", (*) => toggleDesktopMode(ctrls))
        QM.AddText("y+25", "
            (
            功能说明：
            
            启动脚本前，必须先将对应的数据从 Opera PMS 导出的报
            
            表中复制到 Excel 表中，才能实现功能。
            
            
            桌面文件模式：
            
            选中“使用桌面文件模式”后，脚本将只会从本机桌面读取相
            
            应文件名的 Excel 表。 请直接在桌面操作所需 Excel 表。
            )")
    )
}
#Include "./BatchKeys_Action.ahk"

BatchKeys(props){
    App := props.App, 
    styles := props.styles

    bk := Component(App, A_ThisFunc)
    xlPath := signal(A_ScriptDir . "\src\Excel\GroupKeys.xls")

    handleSelectXl(App) {
        App.Opt("+OwnDialogs")
        selectedFile := FileSelect(3, , "请选择 Excel 文件")
        if (selectedFile = "") {
            MsgBox("请选择文件")
            return
        }
        xlPath.set(selectedFile)
    }

    handleToogleDesktopMode(App, isEnabled) {
        App.getCtrlByName("filePath").Enabled := isEnabled
        App.getCtrlByName("selectXlBtn").Enabled := isEnabled

        if (isEnabled = false) {
            if (!FileExist(A_Desktop . "\GroupKeys.xls")) {
                FileCopy(A_ScriptDir . "\src\Excel\GroupKeys.xls", A_Desktop . "\Groupkeys.xls")
            }
            xlPath.set(A_Desktop . "\GroupKeys.xls")
        } else {
            xlPath.set(A_ScriptDir . "\src\Excel\GroupKeys.xls")
        }
    }

    bk.render := (this) => this.Add(
        App.AddGroupBox("Section r5 " . styles.xPos . styles.yPos . styles.wide, "批量房卡制作（Excel 表辅助）"),
        App.AddReactiveEdit("vfilePath xs10 yp+30 h25 w150  ReadOnly", "{1}", xlPath),
        App.AddReactiveButton("vselectXlBtn h25 w70 x+10", "选择文件")
           .OnEvent("Click", (*) => handleSelectXl(App)),
        App.AddReactiveButton("vopenXlBtn h25 w70 x+10", "打开表格")
           .OnEvent("Click", (*) => Run(xlPath.value)),
        App.AddReactiveCheckbox("vuseDesktopXl h25 xs10 y+10", "使用桌面文件模式")
           .OnEvent("Click", (ctrl, _) => handleToogleDesktopMode(App, !ctrl.Value)),
        App.AddReactiveButton("vBatchKeysAction xs10 y+10 w100", "启 动")
           .OnEvent("Click", (*) => BatchKeys_Action.USE(xlPath.value, App.getCtrlByName("useDesktopXl").Value)
        ) 
    ) 

    return bk
}

#Include "./BatchKeys_Action.ahk"

BatchKeysXl(App, props){
    styles := props.styles

    comp := Component(App, A_ThisFunc)
    xlPath := signal(A_ScriptDir . "\src\Excel\GroupKeys.xls")

    handleSelectXl(App) {
        App.Opt("+OwnDialogs")
        selectedFile := FileSelect(3, , "请选择 Excel 文件")
        if (!selectedFile) {
            MsgBox("请选择文件")
            return
        }
        xlPath.set(selectedFile)
    }

    handleToogleDesktopMode(App, isEnabled) {
        App.getCtrlByName("filePath").Enabled := isEnabled
        App.getCtrlByName("selectXlBtn").Enabled := isEnabled

        if (!isEnabled) {
            if (!FileExist(A_Desktop . "\GroupKeys.xls")) {
                FileCopy(A_ScriptDir . "\src\Excel\GroupKeys.xls", A_Desktop . "\Groupkeys.xls")
            }
            xlPath.set(A_Desktop . "\GroupKeys.xls")
        } else {
            xlPath.set(A_ScriptDir . "\src\Excel\GroupKeys.xls")
        }
    }

    comp.render := (this) => this.Add(
        App.AddGroupBox("Section r8 " . styles.xPos . styles.yPos . styles.wide, "批量房卡制作（Excel 表辅助）"),
        ; xl file selector
        App.AREdit("vfilePath xs10 yp+30 h25 w150  ReadOnly", "{1}", xlPath),
        App.ARButton("vselectXlBtn h25 w70 x+10", "选择文件")
           .OnEvent("Click", (*) => handleSelectXl(App)),
        App.ARButton("vopenXlBtn h25 w70 x+10", "打开表格")
           .OnEvent("Click", (*) => Run(xlPath.value)),
        App.ARCheckBox("vuseDesktopXl h25 xs10 y+10", "使用桌面文件模式")
           .OnEvent("Click", (ctrl, _) => handleToogleDesktopMode(App, !ctrl.Value)),

        ; default date-time
        App.AddText("xs10 yp+40 w100 h25 0x200", "退房日期、时间："),
        App.AddDateTime("vcoDateTimeXl x+15 w200 Choose" . A_Now.tomorrow("130000"), "yyyy-MM-dd HH:mm"),

        ; btns
        App.ARButton("vBatchKeysXlAction xs10 y+10 w100", "开始制卡")
           .OnEvent("Click", (*) => BatchKeysXl_Action.USE(xlPath.value, App["coDateTimeXl"].Value, App["enable28fXl"].Value, App["useDesktopXl"].Value)
        ),
        App.AddCheckBox("venable28fXl x+15 h30", "可开启28楼电梯")
    ) 

    return comp
}

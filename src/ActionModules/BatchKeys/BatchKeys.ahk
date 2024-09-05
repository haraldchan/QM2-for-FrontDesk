#Include "./BatchKeys_Action.ahk"

class BatchKeys extends Component {
    static name := "BatchKeys"
    static description := "批量房卡制作（Excel 表辅助）"

    __New(App) {
        super.__New("BatchKeys")
        this.App := App
        this.xlPath := signal(A_ScriptDir . "\src\Excel\GroupKeys.xls")
        this.render(App)
    }

    handleSelectXl(App) {
        App.Opt("+OwnDialogs")
        selectedFile := FileSelect(3, , "请选择 Excel 文件")
        if (selectedFile = "") {
            MsgBox("请选择文件")
            return
        }
        this.xlPath.set(selectedFile)
    }

    handleToogleDesktopMode(App, isEnabled) {
        App.getCtrlByName("filePath").Enabled := isEnabled
        App.getCtrlByName("selectXlBtn").Enabled := isEnabled
        App.getCtrlByName("openXlBtn").Enabled := isEnabled
    }

    action(){
        BatchKeys_Action.USE(this.xlPath.value, this.App.getCtrlByName("useDesktopXl").Value)
    }

    render(App) {
        return super.Add(
            App.AddGroupBox("Section w350 x30 y400 r5", "批量房卡制作（Excel 表辅助）"),
            App.AddReactiveEdit("vfilePath xs10 yp+30 h25 w150  ReadOnly", "{1}", this.xlPath),
            App.AddReactiveButton("vselectXlBtn h25 w70 x+10", "选择文件")
               .OnEvent("Click", (*) => this.handleSelectXl(App)),
            App.AddReactiveButton("vopenXlBtn h25 w70 x+10", "打开表格")
               .OnEvent("Click", (*) => Run(this.xlPath.value)),
            App.AddReactiveCheckbox("vuseDesktopXl h25 xs10 y+10", "使用桌面文件模式")
               .OnEvent("Click", (ctrl, _) => this.handleToogleDesktopMode(App, !ctrl.Value)),
            App.AddReactiveButton("vBatchKeysAction xs10 y+10 w100", "启 动")
               .OnEvent("Click", (*) => this.action())
        )
    }
}
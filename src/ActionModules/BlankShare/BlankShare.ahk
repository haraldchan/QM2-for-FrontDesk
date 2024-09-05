#Include "./BlankShare_Action.ahk"

class BlankShare extends Component {
    static name := "BlankShare"
    static description := "生成空白(NRR) Share"

    __New(App) {
        super.__New("BlankShare")
        this.App := App
        this.render(App)
    }

    getFormData(App){
        return {
            checkin: App.getCtrlByName("checkin").Value,
            shareQty: App.getCtrlByName("shareQty").Value,
        }
    }

    action(){
        form := this.getFormData(this.App)
        BlankShare_Action.USE(form.checkIn, form.shareQty)
    }

    render(App) {
        return super.Add(
            App.AddGroupBox("Section w350 x30 y400 r4", "生成空白(NRR) Share"),
            App.AddCheckBox("vcheckin Checked xs10 yp+30 h20 0x200", "是否 Check In  / "),
            App.AddText("x+10 h20 0x200", "空白 Share 数量"),
            App.AddEdit("vshareQty x+5 w50 h20 0x200", "1"),
            App.AddReactiveButton("vBlankShareAction Default xs10 y+20 w100", "生成 Share")
               .OnEvent("Click", (*) => this.action())
        )
    }
}
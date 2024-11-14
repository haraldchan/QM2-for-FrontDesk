#Include "./BlankShare_Action.ahk"

BlankShare(props) {
    App := props.App, 
    styles := props.styles

    bs := Component(App, A_ThisFunc)
    bs.description := "生成空白(NRR) Share"

    action() {
        form := bs.submit()
        BlankShare_Action.USE(form.checkIn, form.shareQty)
        App.getCtrlByName("shareQty").Value := 1
    }

    bs.render := (this) => this.Add(
        App.AddGroupBox("Section r4 " . styles.xPos . styles.yPos . styles.wide, "生成空白(NRR) Share"),
        App.AddCheckBox("vcheckin Checked xs10 yp+30 h20 0x200", "是否 Check In  / "),
        App.AddText("x+10 h20 0x200", "空白 Share 数量"),
        App.AddEdit("vshareQty x+5 w50 h20 0x200", "1"),
        App.AddReactiveButton("vBlankShareAction Default xs10 y+20 w100", "生成 Share")
        .OnEvent("Click", (*) => action())
    )

    return bs
}

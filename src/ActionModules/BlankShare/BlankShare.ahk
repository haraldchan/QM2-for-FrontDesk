#Include "./BlankShare_Action.ahk"

BlankShare(props) {
    App := props.App
    
    bs := Component(App, A_ThisFunc, props)

    s := useProps(props.styles, {
        xPos: "x30 ",
        yPos: "y460 ",
        wide: "w350 "
    })

    ( !props.HasOwnProp("form") && props.form := {} )
    f := useProps(props.form, {
        shareRoomNums: "",
        shareQty: "1",
        checkIn: false
    })

    action() {
        form := bs.submit()
        BlankShare_Action.USE(form)
        App.getCtrlByName("shareRoomNums").Value := ""
        App.getCtrlByName("checkIn").Value := 1
        App.getCtrlByName("shareQty").Value := 1
    }

    bs.render := (this) => this.Add(
        App.AddGroupBox("Section r6 " . s.xPos . s.yPos . s.wide, "生成空白(NRR) Share"),

        ; room number(s)
        App.AddText("xs10 w100 h20 0x200 yp+30", "房号 (空格分割)"),
        App.AddEdit("vshareRoomNums x+5 w200 h20 0x200", f.shareRoomNums),
        
        ; share qty
        App.AddText("xs10 w100 h20 yp+30 0x200", "空白 Share 数量"),
        App.AddEdit("vshareQty x+5 w200 h20 0x200", f.shareQty),
        
        ; is checkin
        App.AddCheckBox("vcheckIn xs10 h20 yp+30 0x200 " . (f.checkIn ? "Checked" : ""), "是否 Check In"),
        bs.children.Call(),
   
        App.AddReactiveButton("vBlankShareAction xs10 y+10 w100", "生成 Share")
           .OnEvent("Click", (*) => action())
    )

    return bs
}
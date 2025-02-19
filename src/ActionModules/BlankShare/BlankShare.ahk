#Include "./BlankShare_Action.ahk"

BlankShare(props) {
    App := props.App, 
    s := useProps(props.styles, {
        xPos: "x30 ",
        yPos: "y460 ",
        wide: "w350 "
    })

    bs := Component(App, A_ThisFunc)

    action() {
        form := bs.submit()
        BlankShare_Action.USE(form.checkIn, Trim(form.shareQty), Trim(form.shareRoomNums))
        App.getCtrlByName("shareRoomNums").Value := ""
        App.getCtrlByName("checkIn").Value := 1
        App.getCtrlByName("shareQty").Value := 1
    }

    bs.render := (this) => this.Add(
        App.AddGroupBox("Section r6 " . s.xPos . s.yPos . s.wide, "生成空白(NRR) Share"),

        ; room number(s)
        App.AddText("xs10 w100 h20 0x200 yp+30", "房号 (空格分割)"),
        App.AddEdit("vshareRoomNums x+5 w100 h20 0x200", ""),
        
        ; share qty
        App.AddText("xs10 w100 h20 yp+30 0x200", "空白 Share 数量"),
        App.AddEdit("vshareQty x+5 w100 h20 0x200", "1"),
        
        ; is checkin
        App.AddCheckBox("vcheckIn Checked xs10 h20 yp+30 0x200", "是否 Check In"),
   
        App.AddReactiveButton("vBlankShareAction Default xs10 y+10 w100", "生成 Share")
        .OnEvent("Click", (*) => action())
    )

    return bs
}
BatchKeys2(props) {
    App := props.App
    styles := props.styles

    bk := Component(App, A_ThisFunc)

    action() {
        roomsStr := Trim(App.getCtrlByName("rooms").Value)
        roomsArr := InStr(roomsStr, " ") ? StrSplit(roomsStr, " ") : [roomsStr]

        coDateTime := App.getCtrlByName("coDateTime").Value
        coDate := FormatTime(coDateTime, "ShortDate")
        etd := FormatTime(coDateTime, "HH:mm")

        confNum := Trim(App.getCtrlByName("confNum").Value) 

        formData := {
            rooms: roomsArr,
            coDate: coDate,
            etd: etd,
            confNum: confNum
        }
        
        MsgBox JSON.stringify(formData)
    }

    textStyle := "xs10 w100 h25 0x200"
    editStyle := "w200 x+10 h25 0x200"
    bk.render := (this) => this.Add(
        App.AddGroupBox("Section r5 " . styles.xPos . styles.yPos . styles.wide, "批量房卡制作"),
        
        ; form
        App.AddText(textStyle, "房号："),
        App.AddEdit("vrooms " . editStyle , ""),
        App.AddText(textStyle, "退房日期时间："),
        App.AddDateTime("vcoDateTime x+10 w150", "yyyy-MM-dd HH:mm"),
        App.AddText(textStyle, "确认号："),
        App.AddEdit("vconfNum " . editStyle , ""),

        ; bts
        App.AddReactiveButton("vBatchKeys2 xs10 y+10 w100", "开始制卡")
           .OnEvent("Click", (*) => action())
    )

    return bk
}
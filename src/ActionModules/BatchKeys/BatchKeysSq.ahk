#Include "./BatchKeys_Action.ahk"

BatchKeysSq(props) {
    App := props.App
    styles := props.styles

    bk := Component(App, A_ThisFunc)

    action() {
        for ctrl in bk.ctrls {
            if (ctrl is Gui.Edit && ctrl.Value == "") {
                return
            }
        }

        roomsStr := Trim(App.getCtrlByName("rooms").Value)
        roomsArr := InStr(roomsStr, " ") ? StrSplit(roomsStr, " ") : [roomsStr]

        coDateTime := App.getCtrlByName("coDateTime").Value
        coDate := FormatTime(coDateTime, "ShortDate")
        etd := FormatTime(coDateTime, "HH:mm")

        confNum := Trim(App.getCtrlByName("cpbNum").Value) 

        formData := {
            rooms: roomsArr,
            coDate: coDate,
            etd: etd,
            confNum: confNum
        }
        
        BatchKeysSq_Action.USE(formData)
    }

    textStyle := "xs10 yp+30 w100 h25 0x200"
    editStyle := "w200 x+10 h25 0x200"
    stdCheckout := FormatTime(DateAdd(A_Now, 1, "Days"), "yyyyMMdd") . "130000"

    bk.render := (this) => this.Add(
        App.AddGroupBox("Section r6 " . styles.xPos . styles.yPos . styles.wide, "批量房卡制作（连续输入）"),
        
        ; form
        App.AddText(textStyle, "房号 (空格分隔)："),
        App.AddEdit("vrooms " . editStyle , ""),
        App.AddText(textStyle, "退房日期、时间："),
        App.AddDateTime("vcoDateTime x+10 w200 Choose" . stdCheckout, "yyyy-MM-dd HH:mm"),
        App.AddText(textStyle, "确认号/Party号："),
        App.AddEdit("vcpbNum " . editStyle , ""),

        ; bts
        App.AddReactiveButton("vBatchKeysSqAction xs10 y+10 w100", "开始制卡")
           .OnEvent("Click", (*) => action())
    )

    return bk
}
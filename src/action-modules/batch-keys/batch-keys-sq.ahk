#Include batch-keys-action.ahk

/**
 * @param {Svaner} App 
 * @param {Object} [props] 
 * @returns {Component} 
 */
BatchKeysSq(App, props) {
    comp := Component(App, A_ThisFunc)

    action(*) {
        for ctrl in comp.ctrls {
            if (ctrl is Gui.Edit && !ctrl.Value) {
                return
            }
        }

        roomsStr := Trim(App["rooms"].Value)
        roomsArr := InStr(roomsStr, " ") ? StrSplit(roomsStr, " ") : [roomsStr]

        coDateTime := App["co-datetime"].Value
        coDate := FormatTime(coDateTime, "ShortDate")
        etd := FormatTime(coDateTime, "HH:mm")

        confNum := Trim(App["cpb-num"].Value) 

        formData := {
            rooms: roomsArr,
            coDate: coDate,
            etd: etd,
            confNum: confNum,
            enable28f: App["enable-28f"].Value
        }
        MsgBox(JSON.stringify(formData))
        BatchKeysSq_Action.USE(formData)
    }

    stdCheckout := FormatTime(DateAdd(A_Now, 1, "Days"), "yyyyMMdd") . "130000"

    App.defineDirectives(
        "@use:bks-text", "xs10 yp+30 w100 h25 0x200",
        "@use:bks-edit", "w200 x+10 h25 0x200"
    )

    comp.render := (this) => this.Add(
        StackBox(App,
            {
                name: "batch-keys-sq",
                groupbox: {
                    options: "Section r7 @use:box-xyw",
                    title: "批量房卡制作（连续输入）"
                }
            },
            () => [
                ; form
                App.AddText("@use:bks-text", "房号 (空格分隔)："),
                App.AddEdit("vrooms @use:bks-edit" , ""),
                App.AddText("@use:bks-text", "退房日期、时间："),
                App.AddDateTime("vco-datetime x+10 w200 Choose" . stdCheckout, "yyyy-MM-dd HH:mm"),
                App.AddText("@use:bks-text", "确认号/Party号："),
                App.AddEdit("vcpb-num @use:bks-edit" , ""),

                ; bts
                App.AddButton("vbatchkeyssq-action xs10 y+10 w100", "开始制卡").onClick(action),
                App.AddCheckBox("venable-28f x+15 h30 0x200", "可开启28楼电梯")
            ]
        )
    )

    return comp
}
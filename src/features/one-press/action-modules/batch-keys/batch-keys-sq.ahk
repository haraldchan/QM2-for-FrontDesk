#Include batch-keys-action.ahk

/**
 * @param {Svaner} App 
 * @param {Object} [props] 
 * @returns {Component} 
 */
BatchKeysSq(App, props) {
    comp := Component(App, A_ThisFunc)

    /**
     * Splits room number string with space and comma
     * @param roomNums 
     * @returns {Array<String>} 
     */
    roomNumSplitPipe(roomNums) {
        return pipe(
            i => StrSplit(i, ","),
            i => i.map(item => Trim(item)),
            i => i.map(item => StrSplit(item, " ")),
            i => i.flat()
        )(roomNums)
    }

    action(*) {
        for ctrl in comp.ctrls {
            if (ctrl is Gui.Edit && !ctrl.Value) {
                return
            }
        }

        roomNums := roomNumSplitPipe(App["rooms"].Value.trim())
        coDateTime := App["co-datetime"].Value
        coDate := FormatTime(coDateTime, "ShortDate")
        etd := FormatTime(coDateTime, "HH:mm")

        confNum := Trim(App["cpb-num"].Value)

        formData := {
            rooms: roomNums,
            coDate: coDate,
            etd: etd,
            confNum: confNum,
            enable28f: App["enable-28f"].Value
        }

        BatchKeysSq_Action.USE(formData)
    }

    stdCheckout := FormatTime(DateAdd(A_Now, 1, "Days"), "yyyyMMdd") . "130000"

    comp.render := (this) => this.Add(
        StackBox(App, {
            name: "batch-keys-sq",
            font: { options: "bold" },
            groupbox: {
                options: "Section h170 @use:box",
                title: "批量房卡制作（连续输入）"
            }
        },
            () => [
                ; form
                App.AddText("@use:form-text yp+25", "房号(空格/逗号分隔)"),
                App.AddEdit("vrooms @use:form-edit", ""),
                App.AddText("@use:form-text", "退房日期、时间"),
                App.AddDateTime("vco-datetime x+10 w200 Choose" . stdCheckout, "yyyy-MM-dd HH:mm"),
                App.AddText("@use:form-text", "确认号/Party号"),
                App.AddEdit("vcpb-num @use:form-edit", ""),
                ; bts
                App.AddButton("vbatch-keys-sq-action xs10 y+20 w100", "开始制卡").onClick(action),
                App.AddCheckBox("venable-28f x+15 h20 0x200 @align[h]:batch-keys-sq-action", "可开启28楼电梯")
            ]
        )
    )

    return comp
}
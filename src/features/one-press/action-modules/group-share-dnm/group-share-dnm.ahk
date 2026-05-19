#Include group-share-dnm-action.ahk

/**
 * @param {Svaner} App 
 * @param {Object} [props] 
 * @returns {Component} 
 */
GroupShareDnm(App, props) {
    comp := Component(App, A_ThisFunc)
    rateCode := signal("TGDA")

    handleUseRateCode(ctrl, _) {
        useRatecode := ctrl.Value
        
        ratecodeField := App["ratecode-field"]
        ratecodeField.Enabled := useRatecode
        ratecodeField.Value := useRatecode ? rateCode.value : ""
    }

    handleDisableUseRateCode(ctrl, _) {
        App["ratecode-field"].Enabled := !(ctrl.Name == "gsd-dnm-only" || ctrl.Name == "gsd-dnm-remove")
        App["use-rc"].Enabled := !(ctrl.Name == "gsd-dnm-only" || ctrl.Name == "gsd-dnm-remove")
    }

    onMount() {
        radios := App[ctrl => (ctrl.name.includes("gsd") && ctrl is Gui.Radio)]
        radios.forEach(radio => radio.onClick(handleDisableUseRateCode))
    }

    action(*) {
        form := comp.submit()
        if (!form.gsdRmQty) {
            MsgBox("请输入需要处理的房间数量", POPUP_TITLE, "4096 T1")
            App["gsd-rm-qty"].Focus()
            return
        }

        GroupShareDnm_Action.USE(form)
    }

    comp.render := (this) => this.Add(
        StackBox(App,
            {
                name: "group-share-dnm-stack-box",
                font: { options: "bold" },
                groupbox: {
                    title: "预抵房间批量 Share/DoNotMove",
                    options: "Section h230 @use:box",
                }
            },
            () => [
                ; room Qty
                App.AddText("xs10 yp+25 w100 h20 Checked 0x200", "批量处理房间数量"),
                App.AddEdit("vgsd-rm-qty x+5 h20 0x200 w100", ""),

                ; rate code
                App.AddCheckBox("vuse-rc xs10 y+10 w100 h20 Checked 0x200", "指定 Ratecode")
                   .onCLick(handleUseRateCode),
                App.AddEdit("vratecode-field x+5 h20 0x200 w100", "{1}", rateCode).bind(),

                ; both/share/dnm
                App.AddRadio("vgsd-share-dnm xs10 y+10 h20 Checked 0x200", "Share 及 DoNotMove"),
                App.AddRadio("vgsd-share-only xs10 y+5 h20 0x200", "仅做 Share"),
                App.AddRadio("vgsd-dnm-only xs10 y+5 h20 0x200", "仅做 DoNotMove"),
                App.AddRadio("vgsd-dnm-remove xs10 y+5 h20 0x200", "解除 DoNotMove(主管权限)"),
                App.AddButton("vgroup-share-dnm-action Default xs10 y+10 w100", "启 动")
                   .onClick(action),
                onMount()
            ]
        )
    )

    return comp
}

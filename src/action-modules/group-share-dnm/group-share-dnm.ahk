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

    action(*) {
        form := comp.submit()
        if (!form.gsdRmQty) {
            MsgBox("请输入需要处理的房间数量", POPUP_TITLE, "4096 T1")
            App["gsd-rm-qty"].Focus()
            return
        }

        GroupShareDnm_Action.USE(form.gsdRmQty, form.useRc, form.shareDnm, form.shareOnly, form.dnmOnly)
    }

    comp.render := (this) => this.Add(
        StackBox(App,
            {
                name: "group-share-dnm-stack-box",
                groupbox: {
                    title: "预抵房间批量 Share/DoNotMove",
                    options: "Section r9 @use:box-xyw",
                }
            },
            () => [
                ; room Qty
                App.AddText("xs10 yp+30 w100 h20 Checked 0x200", "批量处理房间数量"),
                App.AddEdit("vgsd-rm-qty x+5 h20 0x200 w100", ""),

                ; rate code
                App.AddCheckBox("vuse-rc xs10 y+10 w100 h20 Checked 0x200", "指定 Ratecode")
                   .onCLick(handleUseRateCode),
                App.AddEdit("vratecode-field x+5 h20 0x200 w100", "{1}", rateCode).bind(),

                ; both/share/dnm
                App.AddRadio("vshare-dnm xs10 y+10 h20 Checked 0x200", "Share 及 DoNotMove"),
                App.AddRadio("vshare-only xs10 y+5 h20 0x200", "仅做 Share"),
                App.AddRadio("vdnm-only xs10 y+5 h20 0x200", "仅做 DoNotMove"),
                App.AddButton("vgroupsharednm-action Default xs10 y+10 w100", "启 动")
                   .onClick(action)
            ]
        )
    )

    return comp
}

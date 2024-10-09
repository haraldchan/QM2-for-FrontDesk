#Include "./GroupShareDnm_Action.ahk"

GroupShareDnm(App) {
    gsd := Component(App, A_ThisFunc)
    gsd.description := "预抵房间批量 Share/DoNotMove"
    rateCode := signal("TGDA")

    handleUseRateCode(isUse) {
        rc := App.getCtrlByName("rc")
        rc.Enabled := isUse
        rc.Value := isUse = true ? rateCode.value : ""
    }

    action() {
        form := gsd.submit()
        if (form.gsdRmQty = "") {
            MsgBox("请输入需要处理的房间数量", popupTitle, "4096 T1")
            App.getCtrlByName("gsdRmQty").Focus()
            return
        }

        GroupShareDnm_Action.USE(form.gsdRmQty, form.rc, form.sharednm, form.shareOnly, form.dnmOnly)
    }

    gsd.render := (this) => this.Add(
        App.AddGroupBox("Section w350 x30 y400 r8", "预抵房间批量 Share/DoNotMove"),
        ; room Qty
        App.AddText("xs10 yp+30 h20 Checked 0x200", "批量处理房间数量    "),
        App.AddEdit("vgsdRmQty x+5 h20 0x200 w100", ""),
        ; rate code
        App.AddReactiveCheckBox("vuseRc xs10 y+10 h20 Checked 0x200", "指定 Ratecode ")
           .OnEvent("Click", (ctrl, _) => handleUseRateCode(ctrl.Value)),
        App.AddReactiveEdit("vrc x+5 h20 0x200 w100", "TGDA")
           .OnEvent("LoseFocus", (ctrl, _) => rateCode.set(ctrl.Value)),
        ; both/share/dnm
        App.AddRadio("vsharednm xs10 y+10 h20 Checked 0x200", "Share 及 DoNotMove"),
        App.AddRadio("vshareOnly xs10 y+5 h20 0x200", "仅做 Share "),
        App.AddRadio("vdnmOnly xs10 y+5 h20 0x200", "仅做 DoNotMove "),
        App.AddReactiveButton("vGroupShareDnmAction Default xs10 y+10 w100", "启 动")
           .OnEvent("Click", (*) => action())
    )

    return gsd
}
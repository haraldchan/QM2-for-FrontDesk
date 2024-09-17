#Include "./GroupShareDnm_Action.ahk"

class GroupShareDnm extends Component {
    static name := "GroupShareDnm"
    static description := "预抵房间批量 Share/DoNotMove"

    __New(App) {
        super.__New("GroupShareDnm")
        this.App := App
        this.rateCode := "TGDA"
        this.render(App)
    }

    handleUseRateCode(isUse) {
        rc := this.App.getCtrlByName("rc")
        rc.Enabled := isUse
        rc.Value := isUse = true ? this.rateCode : ""
    }

    action() {
        form := this.App.submitComponent("$$GroupShareDnm")
        if (form.gsdRmQty = "") {
            MsgBox("请输入需要处理的房间数量", popupTitle, "4096 T1")
            this.App.getCtrlByName("gsdRmQty").Focus()
            return
        }

        GroupShareDnm_Action.USE(form.gsdRmQty, form.rc, form.sharednm, form.shareOnly, form.dnmOnly)
    }

    render(App) {
        super.Add(
            App.AddGroupBox("Section w350 x30 y400 r8", "预抵房间批量 Share/DoNotMove"),
            ; room Qty
            App.AddText("xs10 yp+30 h20 Checked 0x200", "批量处理房间数量    "),
            App.AddEdit("vgsdRmQty x+5 h20 0x200 w100", ""),
            ; rate code
            App.AddReactiveCheckBox("vuseRc xs10 y+10 h20 Checked 0x200", "指定 Ratecode ")
               .OnEvent("Click", (ctrl, _) => this.handleUseRateCode(ctrl.Value)),
            App.AddReactiveEdit("vrc x+5 h20 0x200 w100", "TGDA")
               .OnEvent("LoseFocus", (ctrl, _) => this.rateCode := ctrl.Value),
            ; both/share/dnm
            App.AddRadio("vsharednm xs10 y+10 h20 Checked 0x200", "Share 及 DoNotMove"),
            App.AddRadio("vshareOnly xs10 y+5 h20 0x200", "仅做 Share "),
            App.AddRadio("vdnmOnly xs10 y+5 h20 0x200", "仅做 DoNotMove "),
            App.AddReactiveButton("vGroupShareDnmAction Default xs10 y+10 w100", "启 动")
               .OnEvent("Click", (*) => this.action())
        )
    }
}